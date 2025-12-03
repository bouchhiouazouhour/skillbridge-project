import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EditAboutScreen extends StatefulWidget {
  final String? summary;

  const EditAboutScreen({super.key, required this.summary});

  @override
  State<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  late TextEditingController summaryController;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    summaryController = TextEditingController(text: widget.summary ?? "");
  }

  Future<void> save() async {
    setState(() => loading = true);

    final res = await ApiService.updateAbout(summaryController.text);

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
      appBar: AppBar(title: const Text("Modifier À propos")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: summaryController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Votre description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: save,
                    child: const Text("Enregistrer"),
                  ),
          ],
        ),
      ),
    );
  }
}
