<?php
// app/Http/Controllers/Api/ProfileController.php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    public function show(Request $request)
{
    $user = $request->user();

    return response()->json([
        'id' => $user->id,
        'name' => $user->name,
        'email' => $user->email,

        // 🔥 Ajoute TOUS les champs ici :
        'title' => $user->title,
        'phone' => $user->phone,
        'linkedin' => $user->linkedin,
        'location' => $user->location,
        'status' => $user->status,
        'summary' => $user->summary,

        'avatar' => $user->avatar ? asset('storage/'.$user->avatar) : null,

        // TES AUTRES CHAMPS
        'applications' => 15,
        'saved_cvs' => 24,
        'cv_uploaded' => 5,
        'suggestions' => 12,
        'jobs_applied' => 8,

        // Placeholders
        'experiences' => [],
        'educations' => [],
        'projects' => [],
        'skills' => [],
        'certifications' => [],
      ]);
    }   


    public function update(Request $request)
    {
        $user = $request->user();

       $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'title' => 'nullable|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,

            // 📌 Validation du numéro tunisien
            'phone' => ['nullable', 'regex:/^(2|4|5|9)[0-9]{7}$/'],

            // 📌 Validation du lien LinkedIn
            'linkedin' => [
                'nullable',
                'regex:/^https?:\/\/(www\.)?linkedin\.com\/in\/[A-Za-z0-9\-_]+\/?$/'
            ],

            'location' => 'nullable|string|max:255',

            // 📌 Suggestions du statut (must be in list)
                'status' => [
                    'nullable',
                    Rule::in([
                        "Disponible immédiatement",
                        "En recherche d’opportunités",
                        "Ouvert(e) aux propositions",
                        "Freelance disponible",
                        "Indisponible pour le moment"
                    ])
                ],

                'summary' => 'nullable|string',
                'avatar' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            ]);



        if ($request->hasFile('avatar')) {
        $avatarPath = $request->file('avatar')->store('avatars', 'public');
        $data['avatar'] = $avatarPath;
         }
        $user->update($data);

        return response()->json(['status' => 'success', 'user' => $user]);
    }
    public function updateAbout(Request $request)
    {
        $request->validate([
            'summary' => 'nullable|string',
        ]);

        $user = $request->user();
        $user->summary = $request->summary;
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Résumé mis à jour',
            'user' => $user
        ]);
    }
        
}
