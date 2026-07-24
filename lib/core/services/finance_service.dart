import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction_model.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../../models/budget_model.dart';
import '../../models/recurring_transaction_model.dart';

/// Serviço centralizado para todas as operações de finanças no Firestore.
///
/// Estrutura do Firestore:
/// /users/{userId}/transactions/{id}
/// /users/{userId}/accounts/{id}
/// /users/{userId}/assets/{id}
/// /users/{userId}/budgets/{id}
/// /users/{userId}/recurringTransactions/{id}
class FinanceService {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ─── Transactions ─────────────────────────────────────────────────

  CollectionReference get _transactionsCollection =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  Stream<QuerySnapshot> getTransactionsStream() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots();
  }

  TransactionModel _transactionFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Outros',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      accountId: data['accountId'],
    );
  }

  Map<String, dynamic> _transactionToMap(TransactionModel t) {
    return {
      'title': t.title,
      'category': t.category,
      'amount': t.amount,
      'type': t.isIncome ? 'income' : 'expense',
      'date': Timestamp.fromDate(t.date),
      'accountId': t.accountId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsCollection.doc(transaction.id).set(
      _transactionToMap(transaction),
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final data = _transactionToMap(transaction);
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _transactionsCollection.doc(transaction.id).update(data);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsCollection.doc(transactionId).delete();
  }

  // ─── Accounts ──────────────────────────────────────────────────────

  CollectionReference get _accountsCollection =>
      _firestore.collection('users').doc(_userId).collection('accounts');

  Stream<QuerySnapshot> getAccountsStream() {
    return _accountsCollection.snapshots();
  }

  AccountModel _accountFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] != null
          ? AccountType.values.firstWhere(
              (t) => t.name == data['type'],
              orElse: () => AccountType.corrente,
            )
          : AccountType.corrente,
      initialBalance: (data['initialBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> _accountToMap(AccountModel a) {
    return {
      'name': a.name,
      'type': a.type.name,
      'initialBalance': a.initialBalance,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> addAccount(AccountModel account) async {
    await _accountsCollection.doc(account.id).set(_accountToMap(account));
  }

  Future<void> updateAccount(AccountModel account) async {
    final data = _accountToMap(account);
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _accountsCollection.doc(account.id).update(data);
  }

  Future<void> deleteAccount(String accountId) async {
    await _accountsCollection.doc(accountId).delete();
  }

  // ─── Assets ────────────────────────────────────────────────────────

  CollectionReference get _assetsCollection =>
      _firestore.collection('users').doc(_userId).collection('assets');

  Stream<QuerySnapshot> getAssetsStream() {
    return _assetsCollection.snapshots();
  }

  AssetModel _assetFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] != null
          ? AssetType.values.firstWhere(
              (t) => t.name == data['type'],
              orElse: () => AssetType.cash,
            )
          : AssetType.cash,
      currentValue: (data['currentValue'] as num?)?.toDouble() ?? 0,
      notes: data['notes'],
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _assetToMap(AssetModel a) {
    return {
      'name': a.name,
      'type': a.type.name,
      'currentValue': a.currentValue,
      'notes': a.notes,
      'updatedAt': Timestamp.fromDate(a.updatedAt),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> addAsset(AssetModel asset) async {
    await _assetsCollection.doc(asset.id).set(_assetToMap(asset));
  }

  Future<void> updateAsset(AssetModel asset) async {
    final data = _assetToMap(asset);
    data['updatedAt'] = Timestamp.fromDate(asset.updatedAt);
    await _assetsCollection.doc(asset.id).update(data);
  }

  Future<void> deleteAsset(String assetId) async {
    await _assetsCollection.doc(assetId).delete();
  }

  // ─── Budgets ───────────────────────────────────────────────────────

  CollectionReference get _budgetsCollection =>
      _firestore.collection('users').doc(_userId).collection('budgets');

  Stream<QuerySnapshot> getBudgetsStream() {
    return _budgetsCollection.snapshots();
  }

  BudgetModel _budgetFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      category: data['category'] ?? '',
      monthlyLimit: (data['monthlyLimit'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> _budgetToMap(BudgetModel b) {
    return {
      'category': b.category,
      'monthlyLimit': b.monthlyLimit,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _budgetsCollection.doc(budget.id).set(_budgetToMap(budget));
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final data = _budgetToMap(budget);
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _budgetsCollection.doc(budget.id).update(data);
  }

  Future<void> deleteBudget(String budgetId) async {
    await _budgetsCollection.doc(budgetId).delete();
  }

  // ─── Recurring Transactions ────────────────────────────────────────

  CollectionReference get _recurringCollection =>
      _firestore.collection('users').doc(_userId).collection('recurringTransactions');

  Stream<QuerySnapshot> getRecurringStream() {
    return _recurringCollection.snapshots();
  }

  RecurringTransactionModel _recurringFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecurringTransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Outros',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      accountId: data['accountId'],
      dayOfMonth: data['dayOfMonth'] ?? 1,
      active: data['active'] ?? true,
      lastGeneratedMonth: data['lastGeneratedMonth'] != null
          ? (data['lastGeneratedMonth'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> _recurringToMap(RecurringTransactionModel r) {
    return {
      'title': r.title,
      'category': r.category,
      'amount': r.amount,
      'type': r.type == TransactionType.income ? 'income' : 'expense',
      'accountId': r.accountId,
      'dayOfMonth': r.dayOfMonth,
      'active': r.active,
      'lastGeneratedMonth': r.lastGeneratedMonth != null
          ? Timestamp.fromDate(r.lastGeneratedMonth!)
          : null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> addRecurring(RecurringTransactionModel recurring) async {
    await _recurringCollection.doc(recurring.id).set(_recurringToMap(recurring));
  }

  Future<void> updateRecurring(RecurringTransactionModel recurring) async {
    final data = _recurringToMap(recurring);
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _recurringCollection.doc(recurring.id).update(data);
  }

  Future<void> deleteRecurring(String recurringId) async {
    await _recurringCollection.doc(recurringId).delete();
  }

  // ─── Helper: fetch all transactions once (for summaries) ───────────

  Future<List<TransactionModel>> getAllTransactions() async {
    final snapshot = await _transactionsCollection
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => _transactionFromDoc(doc)).toList();
  }

  Future<List<AccountModel>> getAllAccounts() async {
    final snapshot = await _accountsCollection.get();
    return snapshot.docs.map((doc) => _accountFromDoc(doc)).toList();
  }

  Future<List<AssetModel>> getAllAssets() async {
    final snapshot = await _assetsCollection.get();
    return snapshot.docs.map((doc) => _assetFromDoc(doc)).toList();
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final snapshot = await _budgetsCollection.get();
    return snapshot.docs.map((doc) => _budgetFromDoc(doc)).toList();
  }

  Future<List<RecurringTransactionModel>> getAllRecurring() async {
    final snapshot = await _recurringCollection.get();
    return snapshot.docs.map((doc) => _recurringFromDoc(doc)).toList();
  }
}

