import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/ad_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/services/user_service.dart';
import '../../domain/services/ad_service.dart';
import '../../core/services/ai_coaching_service.dart';
import 'home_viewmodel.dart';

// Repository providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final adRepositoryProvider = Provider<AdRepository>((ref) {
  return AdRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Service providers
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.read(userRepositoryProvider));
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService(
    ref.read(adRepositoryProvider),
    ref.read(userServiceProvider),
  );
});

final aiCoachingServiceProvider = Provider<AiCoachingService>((ref) {
  return AiCoachingService();
});

// ViewModel provider
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    ref.read(userServiceProvider),
    ref.read(adServiceProvider),
    ref.read(aiCoachingServiceProvider),
    ref.read(transactionRepositoryProvider),
  );
});