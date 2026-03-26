<?php

namespace App\Events;

use App\Models\Answer;
use App\Models\Question;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AnswerCreated
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Answer $answer,
        public Question $question
    ) {}
}
