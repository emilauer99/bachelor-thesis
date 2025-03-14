<?php

namespace App\Repositories\User;

use App\Models\User;

class UserRepository implements IUserRepository
{
    public function getOneByEmail($email): ?User
    {
        return User::where('email', $email)->first();
    }
}
