import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/providers.dart';

class CustomerSelector extends ConsumerWidget {
  final String? selectedCustomerId;
  final String searchQuery;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(String) onCustomerSelected;
  final VoidCallback onClearSelection;

  const CustomerSelector({
    Key? key,
    required this.selectedCustomerId,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCustomerSelected,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: customersAsync.when(
        data: (customers) {
          final filteredCustomers = searchQuery.isEmpty
              ? []
              : customers
                  .where((c) =>
                      c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                  .take(3)
                  .toList();

          final selected = customers.where((c) => c.id == selectedCustomerId);
          final selectedCustomer = selected.isNotEmpty ? selected.first : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  if (selectedCustomer != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'SELECTED',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: selectedCustomer != null
                      ? selectedCustomer.name
                      : 'Search customer for this bill',
                  prefixIcon: const Icon(Icons.person_search_rounded),
                  suffixIcon: searchQuery.isNotEmpty || selectedCustomerId != null
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: onClearSelection,
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.indigo, width: 2),
                  ),
                ),
                onChanged: onSearchChanged,
              ),
              if (filteredCustomers.isNotEmpty && selectedCustomerId == null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ...filteredCustomers.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        onCustomerSelected(c.id);
                        searchController.text = c.name;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.indigo.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                c.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Due: ₹${c.totalDue.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.indigo,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, __) => Text(
          'Error loading customers: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
