<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AdminLoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'min:8'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $key = 'admin_login_' . request()->ip();
            $attempts = cache()->get($key, 0);

            if ($attempts >= 5) {
                $validator->errors()->add('email', 'Trop de tentatives. Réessayez dans 1 minute.');
            }

            cache()->put($key, $attempts + 1, now()->addMinute());
        });
    }
}
