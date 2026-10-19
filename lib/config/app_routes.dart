import 'package:flutter/material.dart';

// Import all screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/email_verify_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/transactions/edit_transaction_screen.dart';
import '../screens/transactions/transaction_details_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/categories/add_category_screen.dart';
import '../screens/categories/edit_category_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/budget/add_budget_screen.dart';
import '../screens/budget/budget_details_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/analytics/spending_trends_screen.dart';
import '../screens/analytics/category_breakdown_screen.dart';
import '../screens/analytics/income_expense_screen.dart';
import '../screens/ai_insights/insights_screen.dart';
import '../screens/ai_insights/spending_alerts_screen.dart';
import '../screens/ai_insights/recommendations_screen.dart';
import '../screens/ai_insights/unusual_spending_screen.dart';
import '../screens/savings/savings_goals_screen.dart';
import '../screens/savings/add_savings_goal_screen.dart';
import '../screens/savings/savings_details_screen.dart';
import '../screens/recurring/recurring_transactions_screen.dart';
import '../screens/recurring/add_recurring_transaction_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/reports/export_report_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/security_settings_screen.dart';
import '../screens/settings/about_screen.dart';

/// Centralised route names and route generator.
/// Usage: Navigator.pushNamed(context, AppRoutes.dashboard);
class AppRoutes {
  AppRoutes._();

  // ── Route Name Constants ──────────────────────

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerify = '/email-verify';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction';
  static const String transactionDetails = '/transaction-details';
  static const String categories = '/categories';
  static const String addCategory = '/add-category';
  static const String editCategory = '/edit-category';
  static const String budget = '/budget';
  static const String addBudget = '/add-budget';
  static const String budgetDetails = '/budget-details';
  static const String analytics = '/analytics';
  static const String spendingTrends = '/spending-trends';
  static const String categoryBreakdown = '/category-breakdown';
  static const String incomeExpense = '/income-expense';
  static const String insights = '/insights';
  static const String spendingAlerts = '/spending-alerts';
  static const String recommendations = '/recommendations';
  static const String unusualSpending = '/unusual-spending';
  static const String savingsGoals = '/savings-goals';
  static const String addSavingsGoal = '/add-savings-goal';
  static const String savingsDetails = '/savings-details';
  static const String recurring = '/recurring';
  static const String addRecurring = '/add-recurring';
  static const String reports = '/reports';
  static const String exportReport = '/export-report';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String security = '/security';
  static const String about = '/about';

  // ── Route Generator ───────────────────────────

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      // Auth
      case splash:
        return _page(const SplashScreen(), routeSettings);
      case onboarding:
        return _page(const OnboardingScreen(), routeSettings);
      case login:
        return _page(const LoginScreen(), routeSettings);
      case register:
        return _page(const RegisterScreen(), routeSettings);
      case forgotPassword:
        return _page(const ForgotPasswordScreen(), routeSettings);
      case emailVerify:
        return _page(const EmailVerifyScreen(), routeSettings);

      // Dashboard
      case dashboard:
        return _page(const DashboardScreen(), routeSettings);

      // Transactions
      case transactions:
        return _page(const TransactionsScreen(), routeSettings);
      case addTransaction:
        return _page(const AddTransactionScreen(), routeSettings);
      case editTransaction:
        return _page(const EditTransactionScreen(), routeSettings);
      case transactionDetails:
        return _page(const TransactionDetailsScreen(), routeSettings);

      // Categories
      case categories:
        return _page(const CategoriesScreen(), routeSettings);
      case addCategory:
        return _page(const AddCategoryScreen(), routeSettings);
      case editCategory:
        return _page(const EditCategoryScreen(), routeSettings);

      // Budget
      case budget:
        return _page(const BudgetScreen(), routeSettings);
      case addBudget:
        return _page(const AddBudgetScreen(), routeSettings);
      case budgetDetails:
        return _page(const BudgetDetailsScreen(), routeSettings);

      // Analytics
      case analytics:
        return _page(const AnalyticsScreen(), routeSettings);
      case spendingTrends:
        return _page(const SpendingTrendsScreen(), routeSettings);
      case categoryBreakdown:
        return _page(const CategoryBreakdownScreen(), routeSettings);
      case incomeExpense:
        return _page(const IncomeExpenseScreen(), routeSettings);

      // AI Insights
      case insights:
        return _page(const InsightsScreen(), routeSettings);
      case spendingAlerts:
        return _page(const SpendingAlertsScreen(), routeSettings);
      case recommendations:
        return _page(const RecommendationsScreen(), routeSettings);
      case unusualSpending:
        return _page(const UnusualSpendingScreen(), routeSettings);

      // Savings
      case savingsGoals:
        return _page(const SavingsGoalsScreen(), routeSettings);
      case addSavingsGoal:
        return _page(const AddSavingsGoalScreen(), routeSettings);
      case savingsDetails:
        return _page(const SavingsDetailsScreen(), routeSettings);

      // Recurring
      case recurring:
        return _page(const RecurringTransactionsScreen(), routeSettings);
      case addRecurring:
        return _page(const AddRecurringTransactionScreen(), routeSettings);

      // Reports
      case reports:
        return _page(const ReportsScreen(), routeSettings);
      case exportReport:
        return _page(const ExportReportScreen(), routeSettings);

      // Notifications
      case notifications:
        return _page(const NotificationsScreen(), routeSettings);

      // Profile
      case profile:
        return _page(const ProfileScreen(), routeSettings);
      case editProfile:
        return _page(const EditProfileScreen(), routeSettings);

      // Settings
      case settings:
        return _page(const SettingsScreen(), routeSettings);
      case security:
        return _page(const SecuritySettingsScreen(), routeSettings);
      case about:
        return _page(const AboutScreen(), routeSettings);

      // Fallback
      default:
        return _page(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
          routeSettings,
        );
    }
  }

  /// Helper: wraps a widget in a MaterialPageRoute with fade transition.
  static MaterialPageRoute _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => child,
      settings: settings,
    );
  }
}
