import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../core/db/providers.dart';
import '../widgets/transaction_card.dart';
import 'billing_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    // Check for store name in metadata first, then fallback to email
    final storeName = user?.userMetadata?['display_name'] as String?;
    final userName = storeName ?? (user?.email?.split('@').first ?? 'User');
    
    final transactionsAsync = ref.watch(allTransactionsStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: Color(0xFF6366F1)),
                    ),
                    onSelected: (value) {
                      if (value == 'logout') {
                        ref.read(supabaseClientProvider).auth.signOut();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: "Today's Sales",
                      valueAsync: transactionsAsync.whenData((transactions) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final todaySales = transactions
                            .where((t) => t.transaction.timestamp.isAfter(today) &&
                                          t.transaction.itemsJson.isNotEmpty)
                            .fold(0.0, (sum, t) => sum + t.transaction.totalAmount);
                        return '₹${todaySales.toStringAsFixed(0)}';
                      }),
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: "Pending Credit",
                      valueAsync: customersAsync.whenData((customers) {
                        final totalDue = customers.fold(
                          0.0,
                              (sum, c) => sum + (c.totalDue > 0 ? c.totalDue : 0),
                        );
                        return '₹${totalDue.toStringAsFixed(0)}';
                      }),
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // New Bill Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Create New Bill',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BigActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BillingScreen()));
                          },
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade100),
                        _BigActionButton(
                          icon: Icons.edit_note_rounded,
                          label: 'Manual',
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BillingScreen()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 1;
                    },
                    child: const Text('See All', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: transactionsAsync.when(
                  data: (transactions) {
                    final recent = transactions.take(10).toList();
                    if (recent.isEmpty) {
                      return Center(
                        child: Text('No transactions yet', style: TextStyle(color: Colors.grey.shade500)),
                      );
                    }
                    return ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        return TransactionCard(transactionWithCustomer: recent[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final AsyncValue<String> valueAsync;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.valueAsync,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          valueAsync.when(
            data: (val) => Text(
              val,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            loading: () => const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Text('Error'),
          ),
        ],
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
