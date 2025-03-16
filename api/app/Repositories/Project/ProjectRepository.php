<?php

namespace App\Repositories\Project;

use App\Models\Project;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

class ProjectRepository implements IProjectRepository
{
    public function getAll(?array $filters = null): Collection
    {
        $query = Project::query();
        if ($filters && count($filters) > 0) {
            foreach ($filters as $filter => $value) {
                $this->addFilter($query, $filter, $value);
            }
        }
        return $query->get();
    }

    public function getOne(int $id): ?Project
    {
        return Project::findOrFail($id);
    }

    public function create(array $attributes): ?Project
    {
        return Project::create($attributes);
    }

    public function update(int $id, array $attributes): ?Project
    {
        $project = $this->getOne($id);
        $project->update($attributes);
        return $project->fresh(); // Returns the latest version of the project
    }

    public function delete(int $id): void
    {
        $project = $this->getOne($id);
        $project->delete();
    }

    private function addFilter(Builder &$query, $filter, $value): void
    {
        switch ($filter) {
            case 'name':
                $query->where($filter, 'like', '%' . $value . '%');
                break;
            case 'customerName':
                $query->whereHas('customer', function ($q) use ($value) {
                    $q->where('name', 'like', '%' . $value . '%');
                });
                break;
            case 'customer':
                $query->where('customer_id', '=', $value);
                break;
            case 'startDate':
                $query->whereDate('start_date', '>=', $value);
                break;
            case 'endDate':
                $query->whereDate('end_date', '<=', $value);
                break;
            default:
                $query->where(str_replace('-', '_', $filter), '=', $value);
        }
    }
}
