<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function() {
   return redirect(route('courses.index'));
});
Route::resource('/courses',\App\Http\Controllers\CoursesController::class);
Route::resource('/subjects',\App\Http\Controllers\SubjectsController::class);
