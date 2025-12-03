<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Skill;

class SkillsController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->skills()->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'level' => 'nullable|integer|min:1|max:15',
        ]);
        $data['user_id'] = auth()->id();    
        $skill = $request->user()->skills()->create($data);
        return response()->json(['status' => 'success', 'skill' => $skill], 201);
    }

    public function show(Request $request, $id)
    {
        $skill = $request->user()->skills()->findOrFail($id);
        return response()->json($skill);
    }

    public function update(Request $request, $id)
    {
        $skill = $request->user()->skills()->findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'level' => 'nullable|integer|min:0|max:100',
        ]);

        $skill->update($data);
        return response()->json(['status' => 'success', 'skill' => $skill]);
    }

    public function destroy(Request $request, $id)
    {
        $skill = $request->user()->skills()->findOrFail($id);
        $skill->delete();
        return response()->json(['status' => 'success']);
    }
}
