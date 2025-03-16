<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreCustomerRequest;
use App\Http\Resources\CustomerResource;
use App\Repositories\Customer\ICustomerRepository;

class CustomerController extends Controller
{
    public function __construct(protected ICustomerRepository $customerRepository)
    {}

    public function index()
    {
        return CustomerResource::collection($this->customerRepository->getAll());
    }

    public function store(StoreCustomerRequest $request)
    {
        return new CustomerResource($this->customerRepository->create(
            $request->name,
            $request->image
        ));
    }
}
