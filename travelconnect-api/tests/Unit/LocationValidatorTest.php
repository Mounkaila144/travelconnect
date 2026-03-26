<?php

namespace Tests\Unit;

use App\Utils\LocationValidator;
use PHPUnit\Framework\TestCase;

class LocationValidatorTest extends TestCase
{
    public function test_valid_coordinates_returns_true(): void
    {
        $this->assertTrue(LocationValidator::validateCoordinates(35.6762, 139.6503));
        $this->assertTrue(LocationValidator::validateCoordinates(0, 0));
        $this->assertTrue(LocationValidator::validateCoordinates(-33.8688, 151.2093));
    }

    public function test_boundary_coordinates_are_valid(): void
    {
        $this->assertTrue(LocationValidator::validateCoordinates(90, 180));
        $this->assertTrue(LocationValidator::validateCoordinates(-90, -180));
        $this->assertTrue(LocationValidator::validateCoordinates(90, -180));
        $this->assertTrue(LocationValidator::validateCoordinates(-90, 180));
    }

    public function test_invalid_latitude_returns_false(): void
    {
        $this->assertFalse(LocationValidator::validateCoordinates(91, 0));
        $this->assertFalse(LocationValidator::validateCoordinates(-91, 0));
        $this->assertFalse(LocationValidator::validateCoordinates(100, 50));
    }

    public function test_invalid_longitude_returns_false(): void
    {
        $this->assertFalse(LocationValidator::validateCoordinates(0, 181));
        $this->assertFalse(LocationValidator::validateCoordinates(0, -181));
        $this->assertFalse(LocationValidator::validateCoordinates(45, 200));
    }

    public function test_is_valid_latitude(): void
    {
        $this->assertTrue(LocationValidator::isValidLatitude(0));
        $this->assertTrue(LocationValidator::isValidLatitude(90));
        $this->assertTrue(LocationValidator::isValidLatitude(-90));
        $this->assertTrue(LocationValidator::isValidLatitude(45.5));
        $this->assertFalse(LocationValidator::isValidLatitude(90.1));
        $this->assertFalse(LocationValidator::isValidLatitude(-90.1));
    }

    public function test_is_valid_longitude(): void
    {
        $this->assertTrue(LocationValidator::isValidLongitude(0));
        $this->assertTrue(LocationValidator::isValidLongitude(180));
        $this->assertTrue(LocationValidator::isValidLongitude(-180));
        $this->assertTrue(LocationValidator::isValidLongitude(139.6503));
        $this->assertFalse(LocationValidator::isValidLongitude(180.1));
        $this->assertFalse(LocationValidator::isValidLongitude(-180.1));
    }
}
