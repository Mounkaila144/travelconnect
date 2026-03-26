<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterFcmTokenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'fcm_token' => ['required', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'fcm_token.required' => 'Le token FCM est requis',
            'fcm_token.string' => 'Le token FCM doit être une chaîne de caractères',
            'fcm_token.max' => 'Le token FCM ne peut pas dépasser 500 caractères',
        ];
    }
}
