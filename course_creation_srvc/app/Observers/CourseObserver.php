<?php

namespace App\Observers;

use App\Models\Course;

class CourseObserver
{
    public function deleting(Course $course)
    {
        if ($course->isForceDeleting()) {
            $course->subjects()->forceDelete();
        } else {
            $course->subjects()->each(function ($subject) {
                $subject->delete();
            });
        }
    }
}
