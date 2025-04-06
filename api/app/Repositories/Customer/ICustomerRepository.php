<?php

namespace App\Repositories\Customer;

use App\Models\Customer;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Collection;

interface ICustomerRepository
{
    public function getAll(): Collection;
    public function create(string $name, UploadedFile $file): ?Customer;
    public function delete(int $id): void;
    public function getOne(int $id): ?Customer;
}
