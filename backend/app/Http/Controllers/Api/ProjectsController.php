<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;

class ProjectsController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->projects()->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'link' => 'nullable|string|max:255',
            'tech_stack' => 'nullable|string',
        ]);
        $data['user_id'] = auth()->id();
        $project = $request->user()->projects()->create($data);
        return response()->json(['status' => 'success', 'project' => $project], 201);
    }

    public function show(Request $request, $id)
    {
        $project = $request->user()->projects()->findOrFail($id);
        return response()->json($project);
    }

    public function update(Request $request, $id)
    {
        $project = $request->user()->projects()->findOrFail($id);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:255',
            'link' => 'nullable|string|max:255',
            'tech_stack' => 'nullable|string',
        ]);

        $project->update($data);
        return response()->json(['status' => 'success', 'project' => $project]);
    }

    public function destroy(Request $request, $id)
    {
        $project = $request->user()->projects()->findOrFail($id);
        $project->delete();
        return response()->json(['status' => 'success']);
    }
}
