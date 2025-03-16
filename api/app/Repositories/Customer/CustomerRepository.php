<?php

namespace App\Repositories\Customer;

use App\Models\Customer;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;

class CustomerRepository implements ICustomerRepository
{
    public function getAll(): Collection
    {
        return Customer::all();
    }

    public function create(string $name, UploadedFile $file): ?Customer
    {
        $imagePath = Storage::putFile('customers', $file);

        $customer = new Customer;
        $customer->name = $name;
        $customer->image_path = $imagePath;

        return $customer->save() ? $customer : null;
    }
}
