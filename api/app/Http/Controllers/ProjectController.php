<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProjectRequest;
use App\Http\Requests\UpdateProjectRequest;
use App\Http\Resources\ProjectResource;
use App\Repositories\Project\IProjectRepository;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Log;

class ProjectController extends Controller
{
    public function __construct(protected IProjectRepository $projectRepository)
    {
    }

    public function index(FormRequest $request)
    {
        return ProjectResource::collection($this->projectRepository->getAll(
            $this->prepareFiltersFromRequest(
                $request,
                ['name', 'state', 'customerName', 'customer', 'startDate', 'endDate']
            )
        ));
    }

    public function show(int $id)
    {
        return new ProjectResource($this->projectRepository->getOne($id));
    }

    public function store(StoreProjectRequest $request)
    {
        return new ProjectResource($this->projectRepository->create(
            $this->transformKeysToSnakeCase($request->validated())
        ));
    }

    public function update(UpdateProjectRequest $request, int $id)
    {
        return new ProjectResource(
            $this->projectRepository->update(
                $id,
                $this->transformKeysToSnakeCase($request->validated())
            )
        );
    }

    public function destroy(int $id)
    {
        $this->projectRepository->delete($id);
        return response()->noContent();
    }
}
