<?php

namespace App\Repositories\Project;

use App\Models\Project;
use Illuminate\Support\Collection;

interface IProjectRepository
{
    public function getAll(): Collection;
    public function getOne(int $id): ?Project;
    public function create(array $attributes): ?Project;
    public function update(int $id, array $attributes): ?Project;
    public function delete(int $id): void;
}
