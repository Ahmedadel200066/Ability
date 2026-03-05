import 'fake_database.dart';

class FieldValue {
  static DateTime serverTimestamp() {
    return DateTime.now();
  }
}

class SetOptions {
  final bool merge;

  SetOptions({this.merge = false});
}

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic> data;

  DocumentSnapshot({required this.id, required this.data});
}

class QuerySnapshot {
  final List<DocumentSnapshot> docs;

  QuerySnapshot({required this.docs});
}

class DocumentReference {
  final String id;
  final String collection;

  DocumentReference(this.collection, this.id);

  Future<void> set(Map<String, dynamic> data) async {
    // Mock set
    FakeDatabase.createRide({...data, 'id': id});
  }

  Future<void> update(Map<String, dynamic> data) async {
    // Mock update
    FakeDatabase.updateRide(id, data);
  }

  Stream<DocumentSnapshot> snapshots() {
    // Mock stream
    return Stream.value(DocumentSnapshot(id: id, data: {'status': 'mock'}));
  }
}

class CollectionReference {
  final String collection;

  CollectionReference(this.collection);

  Future<DocumentReference> add(Map<String, dynamic> data) async {
    String id = 'mock_id_${DateTime.now().millisecondsSinceEpoch}';
    FakeDatabase.createRide({...data, 'id': id});
    return DocumentReference(collection, id);
  }

  DocumentReference doc(String id) {
    return DocumentReference(collection, id);
  }

  Stream<QuerySnapshot> snapshots() {
    // Mock stream
    List<DocumentSnapshot> docs = FakeDatabase.getRides().map((ride) => DocumentSnapshot(id: ride['id'], data: ride)).toList();
    return Stream.value(QuerySnapshot(docs: docs));
  }

  Query where(String field, {dynamic isEqualTo}) {
    return Query(this, field, isEqualTo);
  }
}

class Query {
  final CollectionReference collectionRef;
  final String field;
  final dynamic value;

  Query(this.collectionRef, this.field, this.value);

  Stream<QuerySnapshot> snapshots() {
    // Mock filtered stream
    List rides = FakeDatabase.getRides().where((ride) => ride[field] == value).toList();
    List<DocumentSnapshot> docs = rides.map((ride) => DocumentSnapshot(id: ride['id'], data: ride)).toList();
    return Stream.value(QuerySnapshot(docs: docs));
  }
}

class FirebaseFirestore {
  static final FirebaseFirestore _instance = FirebaseFirestore._internal();

  factory FirebaseFirestore() {
    return _instance;
  }

  FirebaseFirestore._internal();

  static FirebaseFirestore get instance => _instance;

  CollectionReference collection(String collection) {
    return CollectionReference(collection);
  }
}