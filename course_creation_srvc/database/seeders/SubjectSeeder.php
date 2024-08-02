<?php

namespace Database\Seeders;

use App\Models\Course;
use App\Models\Subject;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SubjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //
        $course = Course::all();
        $subject_factory = Subject::factory(30)->make();
        foreach ($subject_factory as $sf) {
            $course_random = $course->random();
            $sf->course()->associate($course_random);
            $sf->save();
        }
    }
}
