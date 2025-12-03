import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EditExperienceScreen extends StatefulWidget {
  const EditExperienceScreen({super.key});

  @override
  State<EditExperienceScreen> createState() => _EditExperienceScreenState();
}

class _EditExperienceScreenState extends State<EditExperienceScreen> {
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();
  final descriptionController = TextEditingController();

  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    final data = {
      "company": companyController.text,
      "role": roleController.text,
      "start_date": startController.text,
      "end_date": endController.text,
      "description": descriptionController.text,
    };

    final res = await ApiService.addExperience(data);

    setState(() => loading = false);

    if (res['status'] == 'success') {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $res")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une expérience")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Input(companyController, "Entreprise"),
            const SizedBox(height: 12),
            Input(roleController, "Poste"),
            const SizedBox(height: 12),
            Input(startController, "Date début (YYYY-MM)"),
            const SizedBox(height: 12),
            Input(endController, "Date fin (YYYY-MM ou actuel)"),
            const SizedBox(height: 12),
            Input(descriptionController, "Description", maxLines: 3),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: save,
                    child: const Text("Ajouter"),
                  ),
          ],
        ),
      ),
    );
  }

  Widget Input(TextEditingController c, String l, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration:
          InputDecoration(labelText: l, border: const OutlineInputBorder()),
    );
  }
}
