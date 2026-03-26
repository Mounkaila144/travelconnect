<?php

namespace App\Http\Requests;

use App\Rules\ValidReportableType;
use Illuminate\Foundation\Http\FormRequest;

class CreateReportRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'reportable_type' => ['required', 'in:Question,Answer'],
            'reportable_id' => ['required', 'integer', new ValidReportableType($this->reportable_type)],
            'reason' => ['required', 'in:spam,offensive,false_info,other'],
            'comment' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'reportable_type.required' => 'Le type de contenu est requis',
            'reportable_type.in' => 'Type de contenu invalide',
            'reportable_id.required' => "L'ID du contenu est requis",
            'reason.required' => 'La raison du signalement est requise',
            'reason.in' => 'Raison invalide',
            'comment.max' => 'Le commentaire ne peut pas dépasser 500 caractères',
        ];
    }
}
