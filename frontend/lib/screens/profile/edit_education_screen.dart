import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EditEducationScreen extends StatefulWidget {
  const EditEducationScreen({super.key, required Map<String, dynamic> user});

  @override
  State<EditEducationScreen> createState() => _EditEducationScreenState();
}

class _EditEducationScreenState extends State<EditEducationScreen> {
  final schoolController = TextEditingController();
  final degreeController = TextEditingController();
  final yearController = TextEditingController();

  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    final data = {
      "school": schoolController.text,
      "degree": degreeController.text,
      "year": yearController.text,
    };

    final res = await ApiService.addEducation(data);

    setState(() => loading = false);

    if (res['status'] == 'success') {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $res")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une formation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Input(schoolController, "Établissement"),
            const SizedBox(height: 12),
            Input(degreeController, "Diplôme"),
            const SizedBox(height: 12),
            Input(yearController, "Année d'obtention"),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: save, child: const Text("Ajouter")),
          ],
        ),
      ),
    );
  }

  Widget Input(TextEditingController c, String l) {
    return TextField(
      controller: c,
      decoration:
          InputDecoration(labelText: l, border: const OutlineInputBorder()),
    );
  }
}
