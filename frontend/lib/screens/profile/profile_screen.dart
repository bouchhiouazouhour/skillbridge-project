import 'package:flutter/material.dart';
import 'package:skillbridge_frontend/core/services/api_service.dart';
import 'edit_profile_screen.dart';
import 'edit_about_screen.dart';
import 'edit_experience_screen.dart';
import 'edit_education_screen.dart';
import 'edit_project_screen.dart';
import 'edit_certification_screen.dart';
import 'edit_skill_screen.dart';


class NewProfileScreen extends StatefulWidget {
  const NewProfileScreen({super.key});

  @override
  State<NewProfileScreen> createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends State<NewProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);

    try {
      final res = await ApiService.getProfile();
      setState(() {
        profile = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  Widget sectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: onAdd)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final user = profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: user),
                ),
              ).then((_) => loadProfile());
            },
          )

        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ----------------------- HEADER -----------------------
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: (user['avatar'] != null)
                          ? NetworkImage(user['avatar'])
                          : null,
                      child: (user['avatar'] == null)
                          ? const Icon(Icons.person, size: 55)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(user['name'],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                        user['title'] ?? "Aucun titre professionnel",
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 5),
                    Text(user['email'],
                        style: TextStyle(color: Colors.grey[600])),
                    if (user['phone'] != null)
                      Text(user['phone'], style: TextStyle(color: Colors.grey)),
                    if (user['linkedin'] != null)
                      Text(user['linkedin'], style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ----------------------- A PROPOS ---------------------
              sectionHeader("À propos", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditAboutScreen(summary: user['summary']),
                  ),
                ).then((_) => loadProfile());
              }),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    user["summary"] ?? "Aucune description ajoutée",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------- EXPERIENCES ---------------------
              sectionHeader("Expériences Professionnelles", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditExperienceScreen()),
                ).then((_) => loadProfile());
              }),

              _dynamicList(
                list: user['experiences'],
                empty: "Aucune expérience ajoutée",
              ),

              const SizedBox(height: 20),

              // --------------------- EDUCATION ------------------------
              sectionHeader("Formations", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEducationScreen(user: user),
                  ),
                ).then((_) => loadProfile());
              }),

              _dynamicList(
                list: user['educations'],
                empty: "Aucune formation ajoutée",
              ),

              const SizedBox(height: 20),

              // --------------------- SKILLS -------------------------
              sectionHeader("Compétences ATS", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditSkillScreen()),
                ).then((_) => loadProfile());
              }),

              Wrap(
                spacing: 8,
                children: (user["skills"] ?? [])
                    .map<Widget>((e) => Chip(label: Text(e['name'])))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // --------------------- PROJECTS ------------------------
              sectionHeader("Projets", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProjectScreen()),
                ).then((_) => loadProfile());
              }),

              _dynamicList(
                list: user['projects'],
                empty: "Aucun projet ajouté",
              ),

              const SizedBox(height: 20),

              // ------------------ CERTIFICATIONS ----------------------
              sectionHeader("Certifications", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditCertificationScreen()),
                ).then((_) => loadProfile());
              }),

              _dynamicList(
                list: user['certifications'],
                empty: "Aucune certification ajoutée",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dynamicList({required List? list, required String empty}) {
    if (list == null || list.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(empty, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: list
          .map((e) => Card(
                child: ListTile(
                  title: Text(e['title'] ?? ""),
                  subtitle: Text(e['subtitle'] ?? ""),
                ),
              ))
          .toList(),
    );
  }
}
