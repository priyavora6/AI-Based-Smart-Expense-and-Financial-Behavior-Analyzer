import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/insights_provider.dart';
import '../../models/transaction_model.dart';
import '../../widgets/custom_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _balanceVisible = true;
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().startRealtimeUpdates();
      context.read<TransactionProvider>().startRealtimeUpdates();
      context.read<InsightsProvider>().startRealtimeUpdates();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadData() async {
    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    await Future.wait([
      dashboardProvider.loadDashboardData(),
      transactionProvider.loadRecentTransactions(),
    ]);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##,##0', 'en_IN').format(amount)}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final userName = authProvider.userName.split(' ').first;
    final totalBalance = dashboardProvider.totalBalance;
    final totalIncome = dashboardProvider.totalIncome;
    final totalExpense = dashboardProvider.totalExpense;
    final recentTransactions = transactionProvider.recentTransactions;
    final categoryBreakdown = dashboardProvider.categoryBreakdown;
    final spendingCategories = _categoryData(categoryBreakdown);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: RefreshIndicator(
                color: AppColors.teal,
                onRefresh: _loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ══════════════════════════════════
                    // HEADER: Greeting + Avatar
                    // ══════════════════════════════════
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Greeting
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navyDark,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                // Profile Avatar
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, AppRoutes.profile),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.mint,
                                      border: Border.all(
                                        color: AppColors.teal.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        userName.isEmpty
                                            ? 'U'
                                            : userName[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ══════════════════════════════════
                    // TOTAL BALANCE CARD
                    // ══════════════════════════════════
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.navyDark,
                                  AppColors.primary,
                                  AppColors.navyLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navyDark.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Label + Eye toggle
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Balance',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() =>
                                          _balanceVisible = !_balanceVisible),
                                      child: Icon(
                                        _balanceVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Balance Amount
                                Text(
                                  _balanceVisible
                                      ? _formatCurrency(totalBalance)
                                      : '₹ ••••••',
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ══════════════════════════════════
                    // INCOME + EXPENSE CARDS
                    // ══════════════════════════════════
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.7),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                          child: Row(
                            children: [
                              // Income
                              Expanded(
                                child: _buildStatCard(
                                  label: 'Income',
                                  amount: totalIncome,
                                  icon: Icons.arrow_upward_rounded,
                                  iconColor: AppColors.success,
                                  bgColor: AppColors.success.withOpacity(0.08),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Expenses
                              Expanded(
                                child: _buildStatCard(
                                  label: 'Expenses',
                                  amount: totalExpense,
                                  icon: Icons.arrow_downward_rounded,
                                  iconColor: AppColors.expense,
                                  bgColor: AppColors.expense.withOpacity(0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ══════════════════════════════════
                    // SPENDING OVERVIEW (Donut Chart)
                    // ══════════════════════════════════
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.4),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Spending Overview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDark,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (spendingCategories.isEmpty)
                                  _buildEmptyOverview()
                                else
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        height: 110,
                                        child: CustomPaint(
                                          painter: _DonutChartPainter(
                                            categories: spendingCategories,
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _balanceVisible
                                                      ? _formatCurrency(
                                                          totalExpense)
                                                      : '••••',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.navyDark,
                                                  ),
                                                ),
                                                Text(
                                                  'spent',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color:
                                                        AppColors.secondaryText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          children: spendingCategories
                                              .take(5)
                                              .map((cat) =>
                                                  _buildLegendItem(cat))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ══════════════════════════════════
                    // MONEY MANAGEMENT SHORTCUTS
                    // ══════════════════════════════════
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Manage your money',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.2,
                              children: [
                                _buildShortcut(
                                  context,
                                  'Budget',
                                  Icons.account_balance_wallet_outlined,
                                  AppRoutes.budget,
                                ),
                                _buildShortcut(
                                  context,
                                  'Analytics',
                                  Icons.bar_chart_rounded,
                                  AppRoutes.analytics,
                                ),
                                _buildShortcut(
                                  context,
                                  'Savings',
                                  Icons.savings_outlined,
                                  AppRoutes.savingsGoals,
                                ),
                                _buildShortcut(
                                  context,
                                  'Recurring',
                                  Icons.repeat_rounded,
                                  AppRoutes.recurring,
                                ),
                                _buildShortcut(
                                  context,
                                  'Reports',
                                  Icons.description_outlined,
                                  AppRoutes.reports,
                                ),
                                _buildShortcut(
                                  context,
                                  'Notifications',
                                  Icons.notifications_none_rounded,
                                  AppRoutes.notifications,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ══════════════════════════════════
                    // RECENT TRANSACTIONS HEADER
                    // ══════════════════════════════════
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                                letterSpacing: 0.3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.transactions),
                              child: Text(
                                'View all',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ══════════════════════════════════
                    // RECENT TRANSACTIONS LIST
                    // ══════════════════════════════════
                    if (recentTransactions.isEmpty)
                      SliverToBoxAdapter(child: _buildEmptyState())
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = recentTransactions[index];
                            return _buildTransactionItem(tx);
                          },
                          childCount: recentTransactions.length > 5
                              ? 5
                              : recentTransactions.length,
                        ),
                      ),

                    // Bottom spacing for nav bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // ══════════════════════════════════
      // BOTTOM NAVIGATION BAR
      // ══════════════════════════════════
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  // ─────────────────────────────────────
  // STAT CARD (Income / Expense)
  // ─────────────────────────────────────
  Widget _buildShortcut(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pushNamed(context, route),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.teal, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navyDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _balanceVisible ? _formatCurrency(amount) : '₹ ••••',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // LEGEND ITEM
  // ─────────────────────────────────────
  Widget _buildLegendItem(Map<String, dynamic> cat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cat['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cat['name'] as String,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${cat['percent']}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // TRANSACTION ITEM
  // ─────────────────────────────────────
  Widget _buildTransactionItem(TransactionModel tx) {
    final isExpense = tx.type == 'expense';
    final color = isExpense ? AppColors.expense : AppColors.success;
    final sign = isExpense ? '− ' : '+ ';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.transactionDetails,
          arguments: tx,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getCategoryColor(tx.categoryName).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(tx.categoryName),
                  size: 20,
                  color: _getCategoryColor(tx.categoryName),
                ),
              ),
              const SizedBox(width: 12),

              // Title + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.categoryName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Amount + Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${_formatCurrency(tx.amount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTxDate(tx.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.secondaryText.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add your first one',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add transaction'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOverview() {
    return Column(
      children: [
        Icon(
          Icons.pie_chart_outline_rounded,
          size: 48,
          color: AppColors.secondaryText.withOpacity(0.45),
        ),
        const SizedBox(height: 10),
        Text(
          'Your spending breakdown will appear here',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Add an expense to start tracking categories.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────
  String _formatTxDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(date.year, date.month, date.day);

    if (txDay == today) return 'Today';
    if (txDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
      case 'utilities':
        return Icons.receipt_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
        return AppColors.catFood;
      case 'transport':
      case 'transportation':
        return AppColors.catTransport;
      case 'shopping':
        return AppColors.catShopping;
      case 'bills':
      case 'utilities':
        return AppColors.catBills;
      case 'health':
        return AppColors.catHealth;
      case 'education':
        return AppColors.catEducation;
      default:
        return AppColors.catOthers;
    }
  }

  List<Map<String, dynamic>> _categoryData(Map<String, double> spending) {
    final total = spending.values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return const [];

    return spending.entries.map((entry) {
      final percent = (entry.value / total) * 100;
      return <String, dynamic>{
        'name': entry.key,
        'percent': percent,
        'color': _getCategoryColor(entry.key),
      };
    }).toList();
  }
}

// ═══════════════════════════════════════════
// DONUT CHART PAINTER
// ═══════════════════════════════════════════
class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;

  _DonutChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 18.0;
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (final cat in categories) {
      final percent = (cat['percent'] as num).toDouble();
      final sweepAngle = (percent / 100) * 2 * 3.14159;
      final paint = Paint()
        ..color = cat['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle - 0.05, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
