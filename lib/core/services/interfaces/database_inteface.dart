abstract class DatabaseService<T> {
  /// Creates a new record at the specified location or table.
  ///
  /// The [location] parameter is interpreted as a table name for SQL databases
  /// and as a path for Firebase.
  /// The [data] map contains the fields to be stored.
  /// Throws an [Exception] if the creation fails.
  Future<void> create({
    required String location,
    required Map<String, dynamic> data,
  });

  /// Reads a record from the specified location or table.
  /// The [location] parameter is interpreted as a table name for SQL databases
  /// and as a path for Firebase.
  /// Returns a [T] object if the read is successful, or null if the read fails.
  Future<T?> read({required String location});

  Future<void> update({
    required String location,
    required Map<String, dynamic> data,
  });

  Future<void> delete({required String location});

  /// Lists all records at the specified location.
  Future<T?> list({required String location});
}
