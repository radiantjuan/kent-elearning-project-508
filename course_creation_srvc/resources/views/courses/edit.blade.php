@extends('layouts.app')

@section('title', 'Edit Course')

@section('content')
    <h1 class="mb-4">Edit Course</h1>

    @if ($errors->any())
        <div class="alert alert-danger">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('courses.update', $course->id) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="form-group">
            <label for="course_name">Course Name</label>
            <input type="text" name="course_name" id="course_name" class="form-control" value="{{ $course->course_name }}" required>
        </div>
        <div class="form-group">
            <label for="course_code">Course Code</label>
            <input type="text" name="course_code" id="course_code" class="form-control" value="{{ $course->course_code }}" required>
        </div>
        <div class="form-group">
            <label for="is_enabled">Is Enabled</label>
            <select name="is_enabled" id="is_enabled" class="form-control" required>
                <option value="1" {{ $course->is_enabled ? 'selected' : '' }}>Yes</option>
                <option value="0" {{ !$course->is_enabled ? 'selected' : '' }}>No</option>
            </select>
        </div>
        <button type="submit" class="btn btn-success">Update Course</button>
    </form>
@endsection
