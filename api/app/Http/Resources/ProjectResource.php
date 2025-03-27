<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProjectResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'state' => $this->state,
            'isPublic' => $this->is_public,
            'startDate' => $this->start_date?->format('Y-m-d'),
            'endDate' => $this->end_date?->format('Y-m-d'),
            'budget' => $this->budget ? $this->budget / 100 : null,
            'estimatedHours' => $this->estimated_hours,
            'customer' => new CustomerResource($this->customer),
            'createdAt' => $this->created_at?->format('Y-m-d H:i:s')
        ];
    }
}
