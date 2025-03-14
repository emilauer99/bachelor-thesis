<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Resources\UserResource;
use App\Repositories\User\IUserRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function __construct(protected IUserRepository $userRepository)
    {}

    public function login(LoginRequest $request)
    {
        $user = $this->userRepository->getOneByEmail($request->email);

        if (!$user || !Hash::check($request->password, $user->password))
            return response()->json(['errors' => ['credentials' => 'incorrect']], 401);

        $userResource = new UserResource($user);

        // already authorized
        if ($request->bearerToken() && auth('sanctum')->check())
            return new UserResource($user, $request->bearerToken());

        // create authorization token and add to response
        $token = $user->createToken('personalAccessToken', ['role:' . $user->role->value])->plainTextToken;
        return new UserResource($user, $token);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();
        return response()->json(['message' => 'Logged out']);
    }
}
