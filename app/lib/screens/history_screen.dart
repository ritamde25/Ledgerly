import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/db/providers.dart';
import '../widgets/transaction_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getWeekRangeText(int weekOffset) {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final startOfCurrentMonday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    
    final startOfTargetWeek = startOfCurrentMonday.subtract(Duration(days: 7 * weekOffset));
    final endOfTargetWeek = weekOffset == 0 
        ? now 
        : startOfTargetWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    if (weekOffset == 0) {
      return "This Week (${DateFormat('dd MMM').format(startOfCurrentMonday)} - Today)";
    } else if (weekOffset == 1) {
      return "Last Week (${DateFormat('dd MMM').format(startOfTargetWeek)} - ${DateFormat('dd MMM').format(endOfTargetWeek)})";
    }
    return "${DateFormat('dd MMM').format(startOfTargetWeek)} - ${DateFormat('dd MMM').format(endOfTargetWeek)}";
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final weekOffset = ref.watch(historyWeekOffsetProvider);
    final selectedFilter = ref.watch(historyFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Bills',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF1F2937)),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isSearchFocused ? 0.06 : 0.03),
                        blurRadius: _isSearchFocused ? 15 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search by customer name...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                      suffixIcon: _isSearchFocused 
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                              setState(() {
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter Selector Panel
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _buildFilterOption(context, ref, 'All', TransactionFilter.all, selectedFilter),
                    _buildFilterOption(context, ref, 'Payment', TransactionFilter.payment, selectedFilter),
                    _buildFilterOption(context, ref, 'Purchase', TransactionFilter.purchase, selectedFilter),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: transactionsAsync.when(
                  data: (transactions) {
                    final filteredTransactions = transactions.where((t) {
                      final matchesSearch = t.customer.name.toLowerCase().contains(searchQuery.toLowerCase());
                      final isPayment = t.transaction.itemsJson.isEmpty;
                      
                      bool matchesFilter = true;
                      if (selectedFilter == TransactionFilter.payment) {
                        matchesFilter = isPayment;
                      } else if (selectedFilter == TransactionFilter.purchase) {
                        matchesFilter = !isPayment;
                      }
                      
                      return matchesSearch && matchesFilter;
                    }).toList();

                    if (filteredTransactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              searchQuery.isEmpty ? Icons.history_rounded : Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty 
                                  ? (weekOffset == 0 ? 'No transactions this week' : 'No transactions for this period')
                                  : 'No matching records',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            if (weekOffset > 0 && searchQuery.isEmpty)
                              TextButton(
                                onPressed: () => ref.read(historyWeekOffsetProvider.notifier).state = 0,
                                child: const Text('Back to This Week', style: TextStyle(color: Color(0xFF6366F1))),
                              ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: filteredTransactions.length,
                      padding: const EdgeInsets.only(bottom: 100, top: 8, left: 16, right: 16),
                      itemBuilder: (context, index) {
                        return TransactionCard(transactionWithCustomer: filteredTransactions[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
          
          // Sticky Floating Week Selector
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      onPressed: () => ref.read(historyWeekOffsetProvider.notifier).state++,
                      color: Colors.indigo,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _getWeekRangeText(weekOffset),
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onPressed: weekOffset > 0 
                          ? () => ref.read(historyWeekOffsetProvider.notifier).state-- 
                          : null,
                      color: weekOffset > 0 ? Colors.indigo : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, WidgetRef ref, String label, TransactionFilter filter, TransactionFilter selectedFilter) {
    final isSelected = filter == selectedFilter;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(historyFilterProvider.notifier).state = filter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
