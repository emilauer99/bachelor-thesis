<?php

namespace App\Enums;

enum EProjectState: string {
    case PLANNED = 'planned';
    case IN_PROGRESS = 'in_progress';
    case FINISHED = 'finished';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
