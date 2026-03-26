<?php

namespace App\Events;

use App\Models\Answer;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AnswerRated
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Answer $answer,
        public Rating $rating,
        public User $rater
    ) {}
}
