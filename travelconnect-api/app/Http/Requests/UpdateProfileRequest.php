<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'bio' => ['nullable', 'string', 'max:150'],
            'country_code' => ['required', 'string', 'size:2', 'in:' . implode(',', config('countries.codes'))],
            'user_type' => ['required', 'in:traveler,local_supporter'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Le nom est obligatoire.',
            'name.min' => 'Le nom doit contenir au moins 2 caractères.',
            'name.max' => 'Le nom ne peut pas dépasser 100 caractères.',
            'bio.max' => 'La bio ne peut pas dépasser 150 caractères.',
            'country_code.required' => 'Le code pays est obligatoire.',
            'country_code.size' => 'Le code pays doit contenir exactement 2 caractères.',
            'country_code.in' => 'Le code pays sélectionné est invalide.',
            'user_type.required' => 'Le type d\'utilisateur est obligatoire.',
            'user_type.in' => 'Le type d\'utilisateur doit être "traveler" ou "local_supporter".',
        ];
    }
}
