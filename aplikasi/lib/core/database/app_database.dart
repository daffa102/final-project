import 'package:drift/drift.dart';
import 'connection.dart' 
  if (dart.library.io) 'native_connection.dart'
  if (dart.library.html) 'web_connection.dart';

part 'app_database.g.dart';

@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get createdAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductData')
class Products extends Table {
  IntColumn get id => integer()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get buyingPrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get stock => integer()();
  IntColumn get minStock => integer().withDefault(const Constant(5))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get createdAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get invoiceNumber => text()();
  TextColumn get paymentMethod => text()();
  RealColumn get totalAmount => real()();
  RealColumn get amountPaid => real()();
  RealColumn get changeAmount => real()();
  RealColumn get profit => real()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  TextColumn get createdAt => text()();
}

@DataClassName('TransactionItemData')
class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get sellingPrice => real()();
  RealColumn get subtotal => real()();
}

@DataClassName('SyncLogData')
class SyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get payload => text()();
  TextColumn get status => text()(); 
  TextColumn get createdAt => text()();
}

@DataClassName('ManualTransactionData')
class ManualTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); 
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  TextColumn get createdAt => text()();
}

@DriftDatabase(tables: [
  Categories, 
  Products, 
  Transactions, 
  TransactionItems, 
  SyncLogs, 
  ManualTransactions
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
