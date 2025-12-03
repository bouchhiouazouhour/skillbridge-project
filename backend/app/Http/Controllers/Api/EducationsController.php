<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Education;

class EducationsController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->educations()->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'institution' => 'required|string|max:255',
            'degree' => 'nullable|string|max:255',
            'field' => 'nullable|string|max:255',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);
        $data['user_id'] = auth()->id();
        $education = $request->user()->educations()->create($data);
        return response()->json(['status' => 'success', 'education' => $education], 201);
    }

    public function show(Request $request, $id)
    {
        $education = $request->user()->educations()->findOrFail($id);
        return response()->json($education);
    }

    public function update(Request $request, $id)
    {
        $education = $request->user()->educations()->findOrFail($id);

        $data = $request->validate([
            'institution' => 'sometimes|required|string|max:255',
            'degree' => 'nullable|string|max:255',
            'field' => 'nullable|string|max:255',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $education->update($data);
        return response()->json(['status' => 'success', 'education' => $education]);
    }

    public function destroy(Request $request, $id)
    {
        $education = $request->user()->educations()->findOrFail($id);
        $education->delete();
        return response()->json(['status' => 'success']);
    }
}
