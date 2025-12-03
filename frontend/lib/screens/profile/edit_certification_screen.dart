import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EditCertificationScreen extends StatefulWidget {
  const EditCertificationScreen({super.key});

  @override
  State<EditCertificationScreen> createState() =>
      _EditCertificationScreenState();
}

class _EditCertificationScreenState extends State<EditCertificationScreen> {
  final titleController = TextEditingController();
  final issuerController = TextEditingController();

  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    final data = {
      "title": titleController.text,
      "issuer": issuerController.text,
    };

    final res = await ApiService.addCertification(data);

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
      appBar: AppBar(title: const Text("Ajouter une certification")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Input(titleController, "Titre de la certification"),
            const SizedBox(height: 12),
            Input(issuerController, "Émetteur"),
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
