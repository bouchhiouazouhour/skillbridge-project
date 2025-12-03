<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Certification;

class CertificationsController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->projects()->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'issuer' => 'nullable|string|max:255',
            'date_obtained' => 'nullable|date',
            'expires_at' => 'nullable|date',
            'credential_id' => 'nullable|string|max:255',
            'credential_url' => 'nullable|string|max:255',
        ]);
        $data['user_id'] = auth()->id();
        $certification = $request->user()->certifications()->create($data);
        return response()->json(['status' => 'success', 'certification' => $certification], 201);
    }

    public function show(Request $request, $id)
    {
        $certification = $request->user()->certifications()->findOrFail($id);
        return response()->json($certification);
    }

    public function update(Request $request, $id)
    {
        $certification = $request->user()->certifications()->findOrFail($id);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'issuer' => 'nullable|string|max:255',
            'date_obtained' => 'nullable|date',
            'expires_at' => 'nullable|date',
            'credential_id' => 'nullable|string|max:255',
            'credential_url' => 'nullable|string|max:255',
        ]);

        $certification->update($data);
        return response()->json(['status' => 'success', 'certification' => $certification]);
    }

    public function destroy(Request $request, $id)
    {
        $certification = $request->user()->certifications()->findOrFail($id);
        $certification->delete();
        return response()->json(['status' => 'success']);
    }
}
