<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RateAnswerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'score' => ['required', 'integer', 'between:1,5'],
        ];
    }

    public function messages(): array
    {
        return [
            'score.required' => 'La note est requise',
            'score.integer' => 'La note doit être un nombre entier',
            'score.between' => 'La note doit être entre 1 et 5',
        ];
    }
}
