@extends('layouts.app')

@section('title', 'Subject List')

@section('content')
    <h1 class="mb-4">Subject List</h1>

    <a href="{{ route('subjects.create') }}" class="btn btn-primary mb-3">Add New Subject</a>

    <table class="table table-bordered">
        <thead>
        <tr>
            <th>Subject Name</th>
            <th>Course Name</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        @foreach ($subjects as $subject)
            <tr>
                <td>{{ $subject->subject_name }}</td>
                <td>{{ $subject->course->course_name }}</td>
                <td>
                    <a href="{{ route('subjects.edit', $subject->id) }}" class="btn btn-warning btn-sm">Edit</a>
                    <form action="{{ route('subjects.destroy', $subject->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this subject?');">Delete</button>
                    </form>
                </td>
            </tr>
        @endforeach
        </tbody>
    </table>
@endsection
