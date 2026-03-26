<?php

namespace App\Rules;

use App\Models\Answer;
use App\Models\Question;
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class ValidReportableType implements ValidationRule
{
    public function __construct(private ?string $type) {}

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $model = match ($this->type) {
            'Question' => Question::class,
            'Answer' => Answer::class,
            default => null,
        };

        if (!$model) {
            $fail('Type de contenu invalide');
            return;
        }

        $exists = $model::where('id', $value)
            ->where('is_deleted', false)
            ->exists();

        if (!$exists) {
            $fail("Le contenu à signaler n'existe pas");
        }
    }
}
