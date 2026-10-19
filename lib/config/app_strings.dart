/// All user-facing text strings in one place.
/// Makes it easy to translate the app later (Hindi, Gujarati, etc.).
class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────

  static const String appName = 'Neospend';
  static const String appTagline = 'Smart Expense & Financial Behaviour Analyzer';
  static const String tagline = appTagline;

  // ── Auth ──────────────────────────────────────

  static const String login = 'Log In';
  static const String signup = 'Sign Up';
  static const String logout = 'Log Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String verifyEmail = 'Verify Your Email';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = 'Already have an account? ';
  static const String loginSuccess = 'Welcome back!';
  static const String signupSuccess = 'Account created successfully!';
  static const String logoutConfirm = 'Are you sure you want to log out?';

  // ── Onboarding ────────────────────────────────

  static const String onboardingTitle1 = 'Track Every Rupee';
  static const String onboardingDesc1 =
      'Record your income and expenses effortlessly.';
  static const String onboardingTitle2 = 'AI-Powered Insights';
  static const String onboardingDesc2 =
      'Let machine learning categorize and analyze your spending.';
  static const String onboardingTitle3 = 'Smart Predictions';
  static const String onboardingDesc3 =
      'Know your future expenses before they happen.';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';

  // ── Dashboard ─────────────────────────────────

  static const String dashboard = 'Dashboard';
  static const String totalIncome = 'Total Income';
  static const String totalExpense = 'Total Expense';
  static const String totalBalance = 'Balance';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';
  static const String noTransactions = 'No transactions yet. Tap + to add one!';
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';

  // ── Transactions ──────────────────────────────

  static const String transactions = 'Transactions';
  static const String addTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String deleteTransaction = 'Delete Transaction';
  static const String amount = 'Amount';
  static const String description = 'Description';
  static const String date = 'Date';
  static const String category = 'Category';
  static const String paymentMethod = 'Payment Method';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String cash = 'Cash';
  static const String upi = 'UPI';
  static const String debitCard = 'Debit Card';
  static const String creditCard = 'Credit Card';
  static const String transactionAdded = 'Transaction added!';
  static const String transactionUpdated = 'Transaction updated!';
  static const String transactionDeleted = 'Transaction deleted!';
  static const String deleteConfirm =
      'Are you sure you want to delete this transaction?';

  // ── Categories ────────────────────────────────

  static const String categories = 'Categories';
  static const String addCategory = 'Add Category';
  static const String editCategory = 'Edit Category';
  static const String food = 'Food';
  static const String groceries = 'Groceries';
  static const String transport = 'Transport';
  static const String shopping = 'Shopping';
  static const String bills = 'Bills';
  static const String health = 'Health';
  static const String education = 'Education';
  static const String entertainment = 'Entertainment';
  static const String salary = 'Salary';
  static const String freelance = 'Freelance';
  static const String other = 'Other';

  // ── Budget ────────────────────────────────────

  static const String budget = 'Budget';
  static const String addBudget = 'Add Budget';
  static const String monthlyBudget = 'Monthly Budget';
  static const String remaining = 'Remaining';
  static const String spent = 'Spent';
  static const String budgetExceeded = 'Budget Exceeded!';
  static const String budgetWarning = 'You have used %d%% of your %s budget.';
  static const String noBudget = 'No budget set. Tap + to create one.';

  // ── Analytics ─────────────────────────────────

  static const String analytics = 'Analytics';
  static const String spendingTrends = 'Spending Trends';
  static const String categoryBreakdown = 'Category Breakdown';
  static const String incomeVsExpense = 'Income vs Expense';
  static const String thisMonth = 'This Month';
  static const String lastMonth = 'Last Month';
  static const String thisWeek = 'This Week';
  static const String increased = 'increased';
  static const String decreased = 'decreased';
  static const String noData = 'Not enough data to show analytics.';

  // ── AI Insights ───────────────────────────────

  static const String insights = 'AI Insights';
  static const String spendingAlerts = 'Spending Alerts';
  static const String recommendations = 'Recommendations';
  static const String unusualSpending = 'Unusual Spending';
  static const String unusualDetected =
      'This expense is unusually high for this category.';
  static const String aiSummary = 'Monthly AI Summary';
  static const String generatingInsights = 'Generating insights...';
  static const String noInsights = 'Add more transactions to see AI insights.';

  // ── Savings ───────────────────────────────────

  static const String savings = 'Savings';
  static const String savingsGoals = 'Savings Goals';
  static const String addGoal = 'Add Goal';
  static const String targetAmount = 'Target Amount';
  static const String savedSoFar = 'Saved So Far';
  static const String targetDate = 'Target Date';
  static const String goalReached = 'Goal Reached! 🎉';

  // ── Recurring ─────────────────────────────────

  static const String recurring = 'Recurring';
  static const String recurringTransactions = 'Recurring Transactions';
  static const String addRecurring = 'Add Recurring Transaction';
  static const String frequency = 'Frequency';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String yearly = 'Yearly';

  // ── Reports ───────────────────────────────────

  static const String reports = 'Reports';
  static const String exportReport = 'Export Report';
  static const String exportCsv = 'Export as CSV';
  static const String exportPdf = 'Export as PDF';
  static const String reportGenerated = 'Report generated successfully!';

  // ── Profile & Settings ────────────────────────

  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  static const String security = 'Security';
  static const String about = 'About';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String currency = 'Currency';
  static const String notifications = 'Notifications';
  static const String deleteAccount = 'Delete Account';
  static const String version = 'Version 1.0.0';

  // ── Errors ────────────────────────────────────

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection.';
  static const String errorEmptyField = 'This field cannot be empty.';
  static const String errorInvalidEmail = 'Please enter a valid email.';
  static const String errorShortPassword = 'Password must be at least 6 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorInvalidAmount = 'Please enter a valid amount.';

  // ── Common ────────────────────────────────────

  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String search = 'Search';
  static const String filter = 'Filter';
}