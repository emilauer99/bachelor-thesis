<?php

namespace App\Enums;

enum ERole: string {
    case ADMIN = 'admin';
    case EMPLOYEE = 'employee';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
