<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GetNearbyQuestionsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
            'radius' => ['sometimes', 'integer', 'min:1', 'max:50'],
            'page' => ['sometimes', 'integer', 'min:1'],
        ];
    }

    public function validated($key = null, $default = null): mixed
    {
        $data = parent::validated($key, $default);

        if ($key === null && is_array($data)) {
            $data['radius'] = $data['radius'] ?? 10;
            $data['page'] = $data['page'] ?? 1;
        }

        return $data;
    }
}
