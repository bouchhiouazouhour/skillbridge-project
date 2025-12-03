import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillbridge_frontend/core/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController titleController;
  late TextEditingController phoneController;
  late TextEditingController linkedinController;
  late TextEditingController locationController;
  late TextEditingController statusController;

  File? selectedImage;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user['name']);
    emailController = TextEditingController(text: widget.user['email']);
    titleController = TextEditingController(text: widget.user['title'] ?? "");
    phoneController = TextEditingController(text: widget.user['phone'] ?? "");
    linkedinController = TextEditingController(text: widget.user['linkedin'] ?? "");
    locationController = TextEditingController(text: widget.user['location'] ?? "");
    statusController = TextEditingController(text: widget.user['status'] ?? "");
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }
  bool isValidLinkedIn(String url) {
    final pattern = RegExp(r"^https?:\/\/(www\.)?linkedin\.com\/in\/[A-Za-z0-9\-_]+\/?$");
    return pattern.hasMatch(url);
  }
  bool isValidPhone(String phone) {
    final pattern = RegExp(r"^(2|4|5|9)[0-9]{7}$");
    return pattern.hasMatch(phone);
  }


  Future<void> saveChanges() async {
    setState(() => loading = true);

    final response = await ApiService.updateProfileFull({
      "name": nameController.text,
      "title": titleController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "linkedin": linkedinController.text,
      "location": locationController.text,
      "status": statusController.text,
    }, selectedImage);

    setState(() => loading = false);

    if (response['status'] == 'success') {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${response.toString()}")),
      );
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  final hasImage = selectedImage != null ||
      (widget.user['avatar'] != null && widget.user['avatar'] != "");

  final imageWidget = selectedImage != null
      ? FileImage(selectedImage!)
      : (widget.user['avatar'] != null
          ? NetworkImage(widget.user['avatar'])
          : null) as ImageProvider?;

  // ✅ Liste déroulante ici (pas dans les widgets !)
  final statusOptions = [
    "Disponible immédiatement",
    "En recherche d’opportunités",
    "Ouvert(e) aux propositions",
    "Freelance disponible",
    "Indisponible pour le moment",
  ];

  return Scaffold(
    backgroundColor: const Color(0xFFF5F7FB),

    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue,
      elevation: 1,
      title: const Text("Modifier le profil"),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),

      child: Column(
        children: [
          // ----------- PHOTO -----------
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: hasImage ? imageWidget : null,
                  backgroundColor: Colors.blue.shade100,
                  child: !hasImage
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: InkWell(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 22, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ----------- FORM -----------
          _input("Nom complet", Icons.person_outline, nameController),
          _input("Titre professionnel", Icons.work_outline, titleController),
          _input("Téléphone", Icons.phone, phoneController),

          // ----------- LINKEDIN AUTO FORMAT -----------
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: TextField(
              controller: linkedinController,
              onChanged: (value) {
                if (!value.contains("linkedin.com")) {
                  linkedinController.text =
                      "https://www.linkedin.com/in/$value";
                  linkedinController.selection = TextSelection.fromPosition(
                    TextPosition(offset: linkedinController.text.length),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: "LinkedIn",
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                hintText: "www.linkedin.com/in/ton-profil",
              ),
            ),
          ),

          _input("Localisation", Icons.location_on_outlined, locationController),

          // ----------- STATUT (DROPDOWN) -----------
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: DropdownButtonFormField<String>(
              value: statusController.text.isNotEmpty
                  ? statusController.text
                  : null,
              decoration: InputDecoration(
                labelText: "Statut",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.flag_outlined),
              ),
              items: statusOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                statusController.text = value!;
              },
            ),
          ),

          // ----------- EMAIL NON MODIFIABLE -----------
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),

          const SizedBox(height: 30),

          loading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer"),
                    onPressed: saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    ),
  );
}
// ----------- WIDGET CHAMP -----------  
  Widget _input(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
