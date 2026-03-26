<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateAnswerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'content' => ['required', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'content.required' => 'Le contenu de la réponse est obligatoire.',
            'content.max' => 'La réponse ne peut pas dépasser 1000 caractères.',
        ];
    }
}
