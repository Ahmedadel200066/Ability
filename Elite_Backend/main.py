import math
import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# بياناتك اللي بعتيها
SUPABASE_URL = "https://njsxgrexdgekelyxwgang.supabase.co"
SUPABASE_KEY = "sb_publishable_Oa46cKc_bMs8Mzxlxad1zw_H0QOANIg"

# هيدرز الاتصال
HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

class UserSignup(BaseModel):
    full_name: str
    phone_number: str
    user_type: str

@app.post("/signup")
async def signup(user: UserSignup):
    async with httpx.AsyncClient() as client:
        # إرسال البيانات لجدول users
        response = await client.post(
            f"{SUPABASE_URL}/rest/v1/users",
            headers=HEADERS,
            json=user.dict()
        )
        if response.status_code >= 400:
            raise HTTPException(status_code=400, detail=response.text)

        data = response.json()
        user_id = data[0]['id']

        if user.user_type == 'driver':
            await client.post(
                f"{SUPABASE_URL}/rest/v1/drivers_details",
                headers=HEADERS,
                json={"driver_id": user_id}
            )

        return {"status": "success", "user_id": user_id}

@app.get("/")
def home():
    return {"message": "Elite Ride Server is Running (Light Mode)!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)