<?php

namespace App\Enums;

enum EProjectState: string {
    case PLANNED = 'planned';
    case IN_PROGRESS = 'inProgress';
    case FINISHED = 'finished';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
