import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EditSkillScreen extends StatefulWidget {
  const EditSkillScreen({super.key});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen> {
  final skillController = TextEditingController();
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    final res = await ApiService.addSkill(skillController.text);

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
      appBar: AppBar(title: const Text("Ajouter une compétence")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: skillController,
              decoration: const InputDecoration(
                labelText: "Nom de la compétence",
                border: OutlineInputBorder(),
              ),
            ),
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
}
