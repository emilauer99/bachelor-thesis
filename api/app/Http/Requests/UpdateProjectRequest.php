<?php

namespace App\Http\Requests;

use App\Enums\EProjectState;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProjectRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'state' => ['sometimes', Rule::enum(EProjectState::class)],
            'isPublic' => ['sometimes', 'boolean'],
            'startDate' => ['nullable', 'date', 'date_format:Y-m-d'],
            'endDate' => ['nullable', 'date', 'after_or_equal:startDate', 'date_format:Y-m-d'],
            'budget' => ['nullable', 'numeric', 'min:0'],
            'estimatedHours' => ['nullable', 'integer', 'min:0'],
            'customerId' => ['sometimes', 'exists:customers,id'],
        ];
    }
}
