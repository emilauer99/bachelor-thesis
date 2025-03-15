<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProjectRequest;
use App\Http\Requests\UpdateProjectRequest;
use App\Http\Resources\ProjectResource;
use App\Repositories\Project\IProjectRepository;

class ProjectController extends Controller
{
    public function __construct(protected IProjectRepository $projectRepository)
    {
    }

    public function index()
    {
        return ProjectResource::collection($this->projectRepository->getAll());
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
                $request->validated()
            )
        );
    }

    public function destroy(int $id)
    {
        $this->projectRepository->delete($id);
        return response()->noContent();
    }
}
