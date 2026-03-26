<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AppleAuthRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'identity_token' => ['required', 'string'],
            'authorization_code' => ['required', 'string'],
            'full_name' => ['nullable', 'array'],
            'full_name.given_name' => ['nullable', 'string', 'max:50'],
            'full_name.family_name' => ['nullable', 'string', 'max:50'],
        ];
    }
}
