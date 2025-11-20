import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTransactionPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> transaction;

  const EditTransactionPage({
    super.key,
    required this.token,
    required this.transaction,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController categoryController;
  late TextEditingController methodController;
  late TextEditingController amountController;

  late String selectedType;
  late DateTime selectedDate;
  bool isLoading = false;

  // Base API URL
  final String baseUrl = "http://192.168.56.1:5291/api/transactions";

  @override
  void initState() {
    super.initState();
    // 1. Pre-fill controllers with existing data
    titleController = TextEditingController(text: widget.transaction['title']);
    categoryController = TextEditingController(
      text: widget.transaction['category'],
    );
    // 'method' might not be in the list view map, handle gracefully if missing
    methodController = TextEditingController(
      text: widget.transaction['method'] ?? "",
    );
    amountController = TextEditingController(
      text: widget.transaction['amount'].toString(),
    );

    // 2. Convert boolean isExpense back to String for Dropdown
    selectedType = widget.transaction['isExpense'] ? "Expense" : "Income";

    selectedDate = widget.transaction['date'];
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    methodController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final double? amount = double.tryParse(amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid amount"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // 3. Construct Body matching your C# Model
      final body = json.encode({
        "id": widget.transaction['id'],
        "title": titleController.text,
        "category": categoryController.text,
        "method": methodController.text,
        "type": selectedType,
        "amount": amount,
        "date": selectedDate.toIso8601String(),
      });

      // 4. Send PUT Request
      final response = await http.put(
        Uri.parse("$baseUrl/${widget.transaction['id']}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction Updated!"),
              backgroundColor: Color(0xFF00D284),
            ),
          );
          Navigator.pop(context, true); // Return true to refresh Home
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Update Failed: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
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
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Transaction",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabel("Title"),
                _buildTextField(titleController, "e.g. Grocery Shopping"),

                _buildLabel("Category"),
                _buildTextField(categoryController, "e.g. Food, Rent"),

                _buildLabel("Method"),
                _buildTextField(methodController, "e.g. Cash, Card"),

                _buildLabel("Type"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      dropdownColor: const Color(0xFF1F2937),
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      items: ["Income", "Expense"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) =>
                          setState(() => selectedType = newValue!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel("Amount"),
                _buildTextField(
                  amountController,
                  "0.00",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                _buildLabel("Date"),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Update Transaction",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6C63FF)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
