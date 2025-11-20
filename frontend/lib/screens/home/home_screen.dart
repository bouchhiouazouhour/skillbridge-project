import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _currentCityController = TextEditingController();
  final _contactNumberController = TextEditingController();

  String? _selectedPayment;
  String? _selectedCountryCode = "+1";
  String? _fileName;

  @override
  void dispose() {
    _fullNameController.dispose();
    _currentCityController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Optimize Your CV", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// FILE UPLOAD
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description, size: 40, color: Colors.black),
                      const SizedBox(height: 8),
                      Text(
                        _fileName ?? "Upload your CV",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// FULL NAME
              const Text("Full Name", style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),

              /// CITY
              const Text("Current City", style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentCityController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),

              /// CONTACT NUMBER
              const Text("Contact Number", style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        items: const [
                          DropdownMenuItem(value: "+1", child: Text("+1")),
                          DropdownMenuItem(value: "+216", child: Text("+216")),
                          DropdownMenuItem(value: "+33", child: Text("+33")),
                          DropdownMenuItem(value: "+971", child: Text("+971")),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCountryCode = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Phone number",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// PAYMENT
              const Text("Preferred Payment", style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPayment,
                items: const [
                  DropdownMenuItem(value: "credit", child: Text("Credit Card")),
                  DropdownMenuItem(value: "debit", child: Text("Debit Card")),
                  DropdownMenuItem(value: "paypal", child: Text("PayPal")),
                  DropdownMenuItem(value: "bank", child: Text("Bank Transfer")),
                ],
                onChanged: (v) => setState(() => _selectedPayment = v),
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 32),

              /// NEXT BUTTON
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Next", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),

      /// NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
