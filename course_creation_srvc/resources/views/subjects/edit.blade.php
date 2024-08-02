@extends('layouts.app')

@section('title', 'Edit Subject')

@section('content')
    <h1 class="mb-4">Edit Subject</h1>

    @if ($errors->any())
        <div class="alert alert-danger">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('subjects.update', $subject->id) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="form-group">
            <label for="subject_name">Subject Name</label>
            <input type="text" name="subject_name" id="subject_name" class="form-control" value="{{ $subject->subject_name }}" required>
        </div>
        <div class="form-group">
            <label for="course_id">Course</label>
            <select name="course_id" id="course_id" class="form-control" required>
                @foreach ($courses as $course)
                    <option value="{{ $course->id }}" {{ $subject->course_id == $course->id ? 'selected' : '' }}>{{ $course->course_name }}</option>
                @endforeach
            </select>
        </div>
        <button type="submit" class="btn btn-success">Update Subject</button>
    </form>
@endsection
