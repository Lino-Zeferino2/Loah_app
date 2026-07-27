import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Central service for Firebase Analytics event tracking.
///
/// Provides a unified API for logging events across the app.
/// Automatically handles debug vs production mode.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// The FirebaseAnalyticsObserver for use with MaterialApp's navigatorObservers.
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a screen view event.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Screen: $screenName');
      return;
    }
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] Error logging screen: $e');
    }
  }

  /// Log a custom event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Event: $name $parameters');
      return;
    }
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] Error logging event: $e');
    }
  }

  // ─── Predefined events ─────────────────────────────────────────

  /// Log when a user completes onboarding.
  Future<void> logOnboardingComplete() async {
    await logEvent(name: 'onboarding_complete');
  }

  /// Log when a user signs up or logs in.
  Future<void> logLogin({required String method}) async {
    await logEvent(name: 'login', parameters: {'method': method});
  }

  /// Log when a user signs up.
  Future<void> logSignUp({required String method}) async {
    await logEvent(name: 'sign_up', parameters: {'method': method});
  }

  /// Log when a task is created.
  Future<void> logTaskCreated({String? category}) async {
    await logEvent(name: 'task_created', parameters: {
      if (category != null) 'category': category,
    });
  }

  /// Log when a task is completed.
  Future<void> logTaskCompleted({String? category}) async {
    await logEvent(name: 'task_completed', parameters: {
      if (category != null) 'category': category,
    });
  }

  /// Log when a goal is created.
  Future<void> logGoalCreated({String? category, String? term}) async {
    await logEvent(name: 'goal_created', parameters: {
      if (category != null) 'category': category,
      if (term != null) 'term': term,
    });
  }

  /// Log when a goal progress is updated.
  Future<void> logGoalProgress({required String goalId, required double progress}) async {
    await logEvent(name: 'goal_progress', parameters: {
      'goal_id': goalId,
      'progress': progress,
    });
  }

  /// Log when a transaction is added.
  Future<void> logTransactionAdded({required String type, String? category}) async {
    await logEvent(name: 'transaction_added', parameters: {
      'type': type,
      if (category != null) 'category': category,
    });
  }

  /// Log when a contact is created.
  Future<void> logContactCreated() async {
    await logEvent(name: 'contact_created');
  }

  /// Log when a contact interaction is logged.
  Future<void> logContactInteraction({required String type}) async {
    await logEvent(name: 'contact_interaction', parameters: {
      'type': type,
    });
  }

  /// Log when a budget is created or updated.
  Future<void> logBudgetUpdated({required String category, required double limit}) async {
    await logEvent(name: 'budget_updated', parameters: {
      'category': category,
      'limit': limit,
    });
  }

  /// Log errors.
  Future<void> logError({
    required String message,
    String? stackTrace,
  }) async {
    await logEvent(name: 'app_error', parameters: {
      'message': message,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  /// Set user properties for analytics (e.g., role, preferences).
  Future<void> setUserProperty({required String name, required String value}) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] Error setting user property: $e');
    }
  }

  /// Set the user ID for analytics (use Firebase Auth UID).
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] Error setting user ID: $e');
    }
  }
}

