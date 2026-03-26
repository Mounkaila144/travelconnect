<?php

namespace App\Events;

use App\Models\Question;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class QuestionCreated
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public readonly Question $question
    ) {}
}
