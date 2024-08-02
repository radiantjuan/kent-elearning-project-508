@extends('layouts.app')

@section('title', 'Course List')

@section('content')
    <h1 class="mb-4">Course List</h1>

    <a href="{{ route('courses.create') }}" class="btn btn-primary mb-3">Add New Course</a>

    <table class="table table-bordered">
        <thead>
        <tr>
            <th>Course Name</th>
            <th>Course Code</th>
            <th>Is Enabled</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        @foreach ($courses as $course)
            <tr>
                <td>{{ $course->course_name }}</td>
                <td>{{ $course->course_code }}</td>
                <td>{{ $course->is_enabled ? 'Yes' : 'No' }}</td>
                <td>
                    <a href="{{ route('courses.edit', $course->id) }}" class="btn btn-warning btn-sm">Edit</a>
                    <form action="{{ route('courses.destroy', $course->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this course?');">Delete</button>
                    </form>
                </td>
            </tr>
        @endforeach
        </tbody>
    </table>
@endsection
