import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/saving_goal.dart';
import '../../core/services/logger_service.dart';

class TransactionRepository {
  static const String _transactionsKey = 'transactions_data';
  static const String _budgetsKey = 'budgets_data';
  static const String _savingGoalsKey = 'saving_goals_data';

  // 거래 내역 관리
  Future<List<Transaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString(_transactionsKey);
      
      if (transactionsJson != null) {
        final List<dynamic> transactionsList = json.decode(transactionsJson);
        return transactionsList
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (error) {
      LoggerService.error('거래 내역 로드 실패: $error');
      return [];
    }
  }

  Future<void> saveTransaction(Transaction transaction) async {
    try {
      final transactions = await getTransactions();
      transactions.add(transaction);
      await _saveTransactionsList(transactions);
      LoggerService.info('거래 저장 완료: ${transaction.description}');
    } catch (error) {
      LoggerService.error('거래 저장 실패: $error');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (index != -1) {
        transactions[index] = updatedTransaction;
        await _saveTransactionsList(transactions);
      }
    } catch (error) {
      LoggerService.error('거래 수정 실패: $error');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactions = await getTransactions();
      transactions.removeWhere((t) => t.id == transactionId);
      await _saveTransactionsList(transactions);
    } catch (error) {
      LoggerService.error('거래 삭제 실패: $error');
      rethrow;
    }
  }

  Future<void> _saveTransactionsList(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, json.encode(transactionsJson));
  }

  // 예산 관리
  Future<List<Budget>> getBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getString(_budgetsKey);
      
      if (budgetsJson != null) {
        final List<dynamic> budgetsList = json.decode(budgetsJson);
        return budgetsList
            .map((json) => Budget.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (error) {
      LoggerService.error('예산 로드 실패: $error');
      return [];
    }
  }

  Future<void> saveBudget(Budget budget) async {
    try {
      final budgets = await getBudgets();
      budgets.add(budget);
      await _saveBudgetsList(budgets);
      LoggerService.info('예산 저장 완료: ${budget.name}');
    } catch (error) {
      LoggerService.error('예산 저장 실패: $error');
      rethrow;
    }
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    try {
      final budgets = await getBudgets();
      final index = budgets.indexWhere((b) => b.id == updatedBudget.id);
      if (index != -1) {
        budgets[index] = updatedBudget;
        await _saveBudgetsList(budgets);
      }
    } catch (error) {
      LoggerService.error('예산 수정 실패: $error');
      rethrow;
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      final budgets = await getBudgets();
      budgets.removeWhere((b) => b.id == budgetId);
      await _saveBudgetsList(budgets);
    } catch (error) {
      LoggerService.error('예산 삭제 실패: $error');
      rethrow;
    }
  }

  Future<void> _saveBudgetsList(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_budgetsKey, json.encode(budgetsJson));
  }

  // 절약 목표 관리
  Future<List<SavingGoal>> getSavingGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_savingGoalsKey);
      
      if (goalsJson != null) {
        final List<dynamic> goalsList = json.decode(goalsJson);
        return goalsList
            .map((json) => SavingGoal.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (error) {
      LoggerService.error('절약 목표 로드 실패: $error');
      return [];
    }
  }

  Future<void> saveSavingGoal(SavingGoal goal) async {
    try {
      final goals = await getSavingGoals();
      goals.add(goal);
      await _saveSavingGoalsList(goals);
      LoggerService.info('절약 목표 저장 완료: ${goal.name}');
    } catch (error) {
      LoggerService.error('절약 목표 저장 실패: $error');
      rethrow;
    }
  }

  Future<void> updateSavingGoal(SavingGoal updatedGoal) async {
    try {
      final goals = await getSavingGoals();
      final index = goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        goals[index] = updatedGoal;
        await _saveSavingGoalsList(goals);
      }
    } catch (error) {
      LoggerService.error('절약 목표 수정 실패: $error');
      rethrow;
    }
  }

  Future<void> deleteSavingGoal(String goalId) async {
    try {
      final goals = await getSavingGoals();
      goals.removeWhere((g) => g.id == goalId);
      await _saveSavingGoalsList(goals);
    } catch (error) {
      LoggerService.error('절약 목표 삭제 실패: $error');
      rethrow;
    }
  }

  Future<void> _saveSavingGoalsList(List<SavingGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((g) => g.toJson()).toList();
    await prefs.setString(_savingGoalsKey, json.encode(goalsJson));
  }

  // 데이터 연동 계산 메서드들
  Future<Budget> updateBudgetSpending(String budgetId) async {
    final budget = (await getBudgets()).firstWhere((b) => b.id == budgetId);
    final transactions = await getTransactions();
    
    // 해당 예산 카테고리의 지출 계산
    final spent = transactions
        .where((t) => 
            t.type == TransactionType.expense && 
            t.category == budget.category &&
            t.date.isAfter(budget.startDate) &&
            t.date.isBefore(budget.endDate.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final updatedBudget = budget.copyWith(spent: spent);
    await updateBudget(updatedBudget);
    return updatedBudget;
  }

  Future<SavingGoal> updateGoalProgress(String goalId) async {
    final goal = (await getSavingGoals()).firstWhere((g) => g.id == goalId);
    final transactions = await getTransactions();
    
    // 절약 거래들로부터 현재 저축액 계산
    final savedAmount = transactions
        .where((t) => 
            t.type == TransactionType.saving &&
            t.date.isAfter(goal.createdAt) &&
            t.date.isBefore(goal.targetDate.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final updatedGoal = goal.copyWith(currentAmount: savedAmount);
    await updateSavingGoal(updatedGoal);
    return updatedGoal;
  }

  // 모든 예산의 지출 업데이트
  Future<List<Budget>> updateAllBudgetSpending() async {
    final budgets = await getBudgets();
    final updatedBudgets = <Budget>[];
    
    for (final budget in budgets) {
      if (budget.isActive) {
        final updated = await updateBudgetSpending(budget.id);
        updatedBudgets.add(updated);
      } else {
        updatedBudgets.add(budget);
      }
    }
    
    return updatedBudgets;
  }

  // 모든 목표의 진행률 업데이트
  Future<List<SavingGoal>> updateAllGoalProgress() async {
    final goals = await getSavingGoals();
    final updatedGoals = <SavingGoal>[];
    
    for (final goal in goals) {
      if (!goal.isCompleted) {
        final updated = await updateGoalProgress(goal.id);
        updatedGoals.add(updated);
      } else {
        updatedGoals.add(goal);
      }
    }
    
    return updatedGoals;
  }
}