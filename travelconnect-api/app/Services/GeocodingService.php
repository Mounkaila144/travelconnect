<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class GeocodingService
{
    public function reverseGeocode(float $lat, float $lng): array
    {
        $cacheKey = "geocode:{$lat}:{$lng}";

        return Cache::remember($cacheKey, now()->addDays(30), function () use ($lat, $lng) {
            $response = Http::get('https://maps.googleapis.com/maps/api/geocode/json', [
                'latlng' => "{$lat},{$lng}",
                'key' => config('services.google_maps.api_key'),
                'language' => 'ja',
            ]);

            if ($response->successful() && !empty($response['results'])) {
                $result = $response['results'][0];
                return [
                    'formatted_address' => $result['formatted_address'],
                    'city' => $this->extractCity($result['address_components']),
                ];
            }

            return [
                'formatted_address' => "{$lat}, {$lng}",
                'city' => null,
            ];
        });
    }

    private function extractCity(array $addressComponents): ?string
    {
        foreach ($addressComponents as $component) {
            if (in_array('locality', $component['types'])) {
                return $component['long_name'];
            }
        }

        foreach ($addressComponents as $component) {
            if (in_array('administrative_area_level_1', $component['types'])) {
                return $component['long_name'];
            }
        }

        return null;
    }
}
