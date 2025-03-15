<?php

namespace App\Http\Controllers;

use App\Utils\RequestUtils;
use Illuminate\Support\Str;

abstract class Controller
{
    public function transformKeysToSnakeCase(array $data): array
    {
        $transformed = [];
        foreach ($data as $key => $value) {
            $snakeCaseKey = Str::snake($key);

            if (is_array($value)) {
                // Recursively transform nested arrays
                $transformed[$snakeCaseKey] = $this->transformKeysToSnakeCase($value);
            } else {
                // Assign the value directly if it's not an array
                $transformed[$snakeCaseKey] = $value;
            }
        }

        return $transformed;
    }
}
