<?php

namespace App\Repositories\Project;

use App\Enums\EProjectState;
use App\Models\Project;
use Illuminate\Support\Collection;

class ProjectRepository implements IProjectRepository
{
    public function getAll(): Collection
    {
        return Project::all();
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
}
