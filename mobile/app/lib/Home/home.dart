// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:app/Transactions/add.dart';
import 'package:app/Transactions/edit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../login/login.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data State
  List<Map<String, dynamic>> transactions = [];
  double income = 0;
  double expense = 0;
  double balance = 0;
  String userName = "User"; // Default username

  // UI State
  bool isLoading = true;
  String? error;

  // Filters
  String? typeFilter;
  DateTime? fromDate;
  DateTime? toDate;

  // Base API URL
  final String baseUrl = "http://192.168.56.1:5291/api/transactions";

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _applyFilters();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load username saved during login
      userName = prefs.getString('username') ?? "";
    });
  }

  // ---------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------

  void _applyFilters() {
    fetchSummary();
    fetchTransactions();
  }

  void _clearFilters() {
    setState(() {
      typeFilter = null;
      fromDate = null;
      toDate = null;
    });
    _applyFilters();
  }

  // ---------------------------------------------------
  // API CALLS
  // ---------------------------------------------------

  Future<void> fetchSummary() async {
    try {
      String url = "$baseUrl/summary?";
      List<String> queryParams = [];
      if (fromDate != null) {
        queryParams.add("from=${fromDate!.toIso8601String()}");
      }
      if (toDate != null) queryParams.add("to=${toDate!.toIso8601String()}");

      final fullUri = Uri.parse(url + queryParams.join("&"));
      final response = await http.get(
        fullUri,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            income = (data['income'] ?? data['Income'] ?? 0).toDouble();
            expense = (data['expense'] ?? data['Expense'] ?? 0).toDouble();
            balance = (data['balance'] ?? data['Balance'] ?? 0).toDouble();
          });
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      debugPrint("Summary fetch error: $e");
    }
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      String url = "$baseUrl/filter?";
      List<String> queryParams = [];
      if (typeFilter != null) queryParams.add("type=$typeFilter");
      if (fromDate != null) {
        queryParams.add("from=${fromDate!.toIso8601String()}");
      }
      if (toDate != null) queryParams.add("to=${toDate!.toIso8601String()}");

      final fullUri = Uri.parse(url + queryParams.join("&"));
      final response = await http.get(
        fullUri,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (mounted) {
          setState(() {
            transactions = data.map((e) {
              return {
                "id": e['id'], // Capture ID
                "title": e['title'],
                "category": e['category'],
                "method": e['method'], // Capture method
                "amount": double.tryParse(e['amount'].toString()) ?? 0,
                "isExpense": e['type'].toString().toLowerCase() == "expense",
                "date": DateTime.parse(e['date']),
              };
            }).toList();
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        if (mounted) {
          setState(() {
            error = "Failed to fetch transactions: ${response.statusCode}";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Connection error: $e";
          isLoading = false;
        });
      }
    }
  }

  // 🔹 DELETE API CALL
  Future<void> _deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _applyFilters(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction deleted successfully"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
      }
    }
  }

  // ---------------------------------------------------
  // AUTH & NAVIGATION
  // ---------------------------------------------------

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void logout() async {
    _handleUnauthorized();
  }

  // ---------------------------------------------------
  // DATE PICKERS & FILTERS
  // ---------------------------------------------------

  Future<void> selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            onPrimary: Colors.white,
            surface: Color(0xFF1C2236),
            onSurface: Colors.white,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => fromDate = picked);
      _applyFilters();
    }
  }

  Future<void> selectToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            onPrimary: Colors.white,
            surface: Color(0xFF1C2236),
            onSurface: Colors.white,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => toDate = picked);
      _applyFilters();
    }
  }

  void selectTypeFilter(String? type) {
    setState(() => typeFilter = type);
    _applyFilters();
  }

  // ---------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2236),
        elevation: 0,
        title: const Text(
          "Expense Tracker",
          style: TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // 1. USERNAME DISPLAY
          Center(
            child: Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 15),

          // 2. LOGOUT BUTTON
          TextButton(
            onPressed: logout,
            style: TextButton.styleFrom(
              // ignore: duplicate_ignore
              // ignore: deprecated_member_use
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Summary Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _summaryCard(
                  "Income",
                  "\$${income.toStringAsFixed(2)}",
                  const Color(0xFF00D284),
                  Icons.arrow_upward,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  "Expense",
                  "\$${expense.toStringAsFixed(2)}",
                  const Color(0xFFFF4D4D),
                  Icons.arrow_downward,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  "Balance",
                  "\$${balance.toStringAsFixed(2)}",
                  const Color(0xFF5E85F8),
                  Icons.account_balance_wallet,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2236),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: typeFilter,
                    hint: const Text(
                      "All Types",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    underline: Container(),
                    items: ["Income", "Expense"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: selectTypeFilter,
                    dropdownColor: const Color(0xFF2D3348),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: selectFromDate,
                    icon: Icon(
                      Icons.calendar_today,
                      color: fromDate != null
                          ? const Color(0xFF6C63FF)
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: selectToDate,
                    icon: Icon(
                      Icons.event_busy,
                      color: toDate != null
                          ? const Color(0xFF6C63FF)
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  if (typeFilter != null || fromDate != null || toDate != null)
                    IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transaction List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  )
                : error != null
                ? Center(
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : transactions.isEmpty
                ? const Center(
                    child: Text(
                      "No transactions found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) =>
                        _transactionItem(transactions[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(token: widget.token),
            ),
          );
          if (result == true) _clearFilters();
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _summaryCard(String title, String amount, Color color, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2236),
        borderRadius: BorderRadius.circular(16),
        // ignore: duplicate_ignore
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Icon(icon, color: color.withOpacity(0.7), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(Map<String, dynamic> tx) {
    String dateString =
        "${tx['date'].day}/${tx['date'].month}/${tx['date'].year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2236),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================== HEADER ROW (Icon, text, price) ====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tx['isExpense']
                      ? const Color(0xFFFF4D4D).withOpacity(0.1)
                      : const Color(0xFF00D284).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tx['isExpense']
                      ? Icons.shopping_bag_outlined
                      : Icons.attach_money,
                  color: tx['isExpense']
                      ? const Color(0xFFFF4D4D)
                      : const Color(0xFF00D284),
                ),
              ),

              const SizedBox(width: 8),

              // Title + category/date expand
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tx['category'],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "• $dateString",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price (always stays at right)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "${tx['isExpense'] ? '-' : '+'}\$${tx['amount'].toStringAsFixed(2)}",
                  style: TextStyle(
                    color: tx['isExpense']
                        ? const Color(0xFFFF4D4D)
                        : const Color(0xFF00D284),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          // ===================== BUTTONS WITH WRAP ====================
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTransactionPage(
                          token: widget.token,
                          transaction: tx,
                        ),
                      ),
                    );
                    if (result == true) _applyFilters();
                  },
                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                ),
              ),

              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1F2937),
                        title: const Text(
                          "Delete?",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          "Are you sure you want to delete this transaction?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteTransaction(tx['id']);
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
