<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class BanUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'admin_note' => ['required', 'string', 'max:500'],
            'is_permanent' => ['boolean'],
            'ban_duration' => ['nullable', 'integer', 'min:1', 'max:365'],
        ];
    }

    public function messages(): array
    {
        return [
            'admin_note.required' => 'Veuillez indiquer la raison du bannissement.',
            'ban_duration.min' => 'La durée minimale est de 1 jour.',
            'ban_duration.max' => 'La durée maximale est de 365 jours.',
        ];
    }
}
