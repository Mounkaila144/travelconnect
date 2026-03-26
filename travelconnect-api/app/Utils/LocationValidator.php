<?php

namespace App\Utils;

class LocationValidator
{
    public static function validateCoordinates(float $lat, float $lng): bool
    {
        return self::isValidLatitude($lat) && self::isValidLongitude($lng);
    }

    public static function isValidLatitude(float $lat): bool
    {
        return $lat >= -90 && $lat <= 90;
    }

    public static function isValidLongitude(float $lng): bool
    {
        return $lng >= -180 && $lng <= 180;
    }
}
