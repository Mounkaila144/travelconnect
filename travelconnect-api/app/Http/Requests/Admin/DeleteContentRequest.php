<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class DeleteContentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'admin_note' => ['required', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'admin_note.required' => 'Veuillez indiquer la raison de la suppression.',
            'admin_note.max' => 'La note ne peut pas dépasser 500 caractères.',
        ];
    }
}
