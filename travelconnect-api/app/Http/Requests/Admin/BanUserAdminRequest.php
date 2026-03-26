<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class BanUserAdminRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'reason' => ['required', 'string', 'max:500'],
            'is_permanent' => ['boolean'],
            'ban_duration_days' => ['nullable', 'integer', 'min:1', 'max:365'],
        ];
    }

    public function messages(): array
    {
        return [
            'reason.required' => 'Veuillez indiquer la raison du bannissement.',
            'ban_duration_days.max' => 'La durée maximum est de 365 jours.',
        ];
    }
}
