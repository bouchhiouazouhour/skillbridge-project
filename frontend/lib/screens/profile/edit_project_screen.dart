import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({super.key});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    final data = {
      "name": nameController.text,
      "description": descriptionController.text,
    };

    final res = await ApiService.addProject(data);

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
      appBar: AppBar(title: const Text("Ajouter un projet")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Input(nameController, "Titre du projet"),
            const SizedBox(height: 12),
            Input(descriptionController, "Description", maxLines: 3),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: save, child: const Text("Ajouter")),
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
