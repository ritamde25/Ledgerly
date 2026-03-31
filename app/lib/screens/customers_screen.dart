import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../core/db/drift_database.dart';
import '../core/db/providers.dart';
import '../core/utils/csv_transfer_service.dart';
import '../core/utils/send_sms.dart';
import '../widgets/common/animated_search_field.dart';
import '../widgets/customers/total_due_banner.dart';
import '../widgets/popups/customer_tile.dart';
import '../widgets/popups/add_customer_dialog.dart';

enum _CustomersMenuAction {
  add,
  importCsv,
  exportCsv,
}

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String searchQuery = "";
  String selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  Future<void> _handleMenuAction(_CustomersMenuAction action) async {
    if (action == _CustomersMenuAction.add) {
      await AddCustomerDialog.show(context);
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to use CSV import/export.')),
      );
      return;
    }

    final csvService = CsvTransferService(
      db: ref.read(databaseProvider),
      userId: user.id,
    );

    try {
      if (action == _CustomersMenuAction.exportCsv) {
        final fileName = await csvService.exportCustomersToCsv();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customers CSV exported: $fileName')),
        );
        return;
      }

      final result = await csvService.importCustomersFromCsv();
      ref.read(syncServiceProvider).syncAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toSummary('Customers'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customers CSV action failed: $e')),
      );
    }
  }

  Future<void> _notifyAllDueCustomers(List<Customer> customers) async {
    final dueCustomers = customers
        .where((c) => c.totalDue > 0 && c.phone.trim().isNotEmpty)
        .toList();

    if (dueCustomers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No due customers with valid phone numbers.')),
      );
      return;
    }

    final user = ref.read(userProvider);
    final storeName = (user?.userMetadata?['display_name'] as String?)?.trim().isNotEmpty == true
        ? (user!.userMetadata?['display_name'] as String).trim()
        : 'Your Store';

    final phones = dueCustomers.map((c) => c.phone).toList();

    final opened = await SmsReminderService.sendGenericReminderToAll(
      phones: phones,
      storeName: storeName,
    );

    if (!mounted) return;

    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening one SMS draft for ${dueCustomers.length} customers.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open SMS app.')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF1F2937)),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<_CustomersMenuAction>(
            tooltip: 'More options',
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _CustomersMenuAction.add,
                child: Text('Add Customer'),
              ),
              PopupMenuItem(
                value: _CustomersMenuAction.importCsv,
                child: Text('Import CSV'),
              ),
              PopupMenuItem(
                value: _CustomersMenuAction.exportCsv,
                child: Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: customersAsync.when(
        data: (customers) {
          final totalDue = customers.fold<double>(
            0,
            (sum, item) => sum + ((item.totalDue > 0) ? item.totalDue : 0),
          );

          var filteredCustomers = customers.where((c) {
            final matchesSearch = c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                 c.phone.contains(searchQuery);
            if (!matchesSearch) return false;

            if (selectedFilter == "Due") return c.totalDue > 0;
            if (selectedFilter == "Paid") return c.totalDue <= 0;
            return true;
          }).toList();

          if (selectedFilter == "Due") {
            filteredCustomers.sort((a, b) {
              final byAmount = b.totalDue.compareTo(a.totalDue);
              if (byAmount != 0) {
                return byAmount;
              }
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });
          } else if (selectedFilter == "Paid") {
            filteredCustomers.sort((a, b) {
              final bAbsNegative = b.totalDue.abs();
              final aAbsNegative = a.totalDue.abs();
              final byAmount = bAbsNegative.compareTo(aAbsNegative);
              if (byAmount != 0) {
                return byAmount;
              }
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });
          } else {
            filteredCustomers.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          }

          return Column(
            children: [
              TotalDueBanner(
                isHidden: _isSearchFocused,
                totalDue: totalDue,
                onNotifyAll: () => _notifyAllDueCustomers(customers),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSearchField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  isFocused: _isSearchFocused,
                  hintText: 'Search by name or phone...',
                  onChanged: (value) => setState(() => searchQuery = value),
                  onClear: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ["All", "Due", "Paid"].map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedFilter = filter);
                        },
                        selectedColor: const Color(0xFF6366F1),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.shade200,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No customers found',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24, top: 8),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return CustomerTile(
                            customer: customer,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
