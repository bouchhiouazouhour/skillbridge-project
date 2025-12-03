<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Experience;

class ExperiencesController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->experiences()->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'company' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'is_current' => 'nullable|boolean',
            'description' => 'nullable|string',
        ]);
        $data['user_id'] = auth()->id();    
        $exp = $request->user()->experiences()->create($data);
        return response()->json(['status' => 'success', 'experience' => $exp], 201);
    }

    public function show(Request $request, $id)
    {
        $exp = $request->user()->experiences()->findOrFail($id);
        return response()->json($exp);
    }

    public function update(Request $request, $id)
    {
        $exp = $request->user()->experiences()->findOrFail($id);

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'company' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'is_current' => 'nullable|boolean',
            'description' => 'nullable|string',
        ]);

        $exp->update($data);
        return response()->json(['status' => 'success', 'experience' => $exp]);
    }

    public function destroy(Request $request, $id)
    {
        $exp = $request->user()->experiences()->findOrFail($id);
        $exp->delete();
        return response()->json(['status' => 'success']);
    }
}
