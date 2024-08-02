<?php

namespace App\Http\Controllers;

use App\Models\Course;
use App\Models\Subject;
use Illuminate\Http\Request;

class SubjectsController extends Controller
{
    public function index()
    {
        $subjects = Subject::with('course')->get();
        return view('subjects.index', compact('subjects'));
    }

    public function create()
    {
        $courses = Course::all();
        return view('subjects.create', compact('courses'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'subject_name' => 'required|string|max:255',
            'course_id' => 'required|exists:courses,id',
        ]);

        Subject::create($request->all());

        return redirect()->route('subjects.index')->with('success', 'Subject added successfully.');
    }

    public function edit(Subject $subject)
    {
        $courses = Course::all();
        return view('subjects.edit', compact('subject', 'courses'));
    }

    public function update(Request $request, Subject $subject)
    {
        $request->validate([
            'subject_name' => 'required|string|max:255',
            'course_id' => 'required|exists:courses,id',
        ]);

        $subject->update($request->all());

        return redirect()->route('subjects.index')->with('success', 'Subject updated successfully.');
    }

    public function destroy(Subject $subject)
    {
        $subject->delete();

        return redirect()->route('subjects.index')->with('success', 'Subject deleted successfully.');
    }
}
