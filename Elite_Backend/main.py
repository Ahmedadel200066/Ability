import psycopg2
import math
from fastapi import FastAPI
from pydantic import BaseModel
from psycopg2.extras import RealDictCursor

app = FastAPI()

# --- إعدادات الاتصال ---
DB_CONFIG = {
    "dbname": "elite_db",
    "user": "postgres",
    "password": "15102020", 
    "host": "127.0.0.1",
    "port": "5432"
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

# --- دالة حساب المسافة بين نقطتين بالكيلومتر ---
def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # نصف قطر الأرض بالكيلومتر
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

# --- نماذج البيانات ---
class UserSignup(BaseModel):
    full_name: str
    phone_number: str
    user_type: str 

class LocationUpdate(BaseModel):
    driver_id: int
    lat: float
    lng: float

class RideRequest(BaseModel):
    rider_id: int
    pickup_lat: float
    pickup_lng: float
    destination_lat: float
    destination_lng: float
    vehicle_type: str

# --- المسارات ---

@app.get("/")
def home():
    return {"message": "Elite Ride Server is Running!"}

@app.post("/signup")
async def signup(user: UserSignup):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO users (full_name, phone_number, user_type) VALUES (%s, %s, %s) RETURNING id;", 
                    (user.full_name, user.phone_number, user.user_type))
        user_id = cur.fetchone()['id']
        if user.user_type == 'driver':
            cur.execute("INSERT INTO drivers_details (driver_id) VALUES (%s)", (user_id,))
        conn.commit()
        return {"status": "success", "user_id": user_id}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.post("/update_location")
async def update_location(data: LocationUpdate):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("UPDATE drivers_details SET current_lat=%s, current_lng=%s, is_available=TRUE, last_update=NOW() WHERE driver_id=%s",
                    (data.lat, data.lng, data.driver_id))
        conn.commit()
        return {"status": "success"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

# --- أهم جزء: طلب رحلة والبحث عن أقرب سائق ---
@app.post("/request_ride")
async def request_ride(ride: RideRequest):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # 1. جلب كل السائقين المتاحين حالياً
        cur.execute("SELECT driver_id, current_lat, current_lng FROM drivers_details WHERE is_available = TRUE")
        drivers = cur.fetchall()

        nearest_driver = None
        min_distance = 5.0  # نبحث في نطاق 5 كيلومتر فقط

        # 2. حلقة لفحص المسافة لكل سائق
        for driver in drivers:
            dist = calculate_distance(ride.pickup_lat, ride.pickup_lng, driver['current_lat'], driver['current_lng'])
            if dist < min_distance:
                min_distance = dist
                nearest_driver = driver['driver_id']

        if nearest_driver:
            # 3. إذا وجدنا سائق، ننشئ الرحلة ونربطها به
            cur.execute("""
                INSERT INTO trips (rider_id, driver_id, pickup_location_text, status) 
                VALUES (%s, %s, %s, %s) RETURNING id;
            """, (ride.rider_id, nearest_driver, f"{ride.pickup_lat},{ride.pickup_lng}", "accepted"))
            trip_id = cur.fetchone()['id']
            conn.commit()
            return {"status": "success", "driver_id": nearest_driver, "trip_id": trip_id, "message": "تم العثور على سائق قريب!"}
        else:
            return {"status": "no_drivers", "message": "للأسف لا يوجد سائقين متاحين حالياً في منطقتك"}

    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.0", port=8000)