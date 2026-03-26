<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Drivers\Gd\Driver;
use Intervention\Image\ImageManager;

class StorageService
{
    public function uploadAvatar(UploadedFile $file, User $user): string
    {
        $manager = new ImageManager(new Driver());

        $image = $manager->read($file->getPathname())
            ->cover(400, 400)
            ->toJpeg(80);

        $filename = "avatars/{$user->id}_" . time() . '.jpg';

        if ($user->avatar_url) {
            $oldPath = parse_url($user->avatar_url, PHP_URL_PATH);
            $oldPath = ltrim($oldPath, '/');
            Storage::disk('ovh')->delete($oldPath);
        }

        Storage::disk('ovh')->put($filename, (string) $image, 'public');

        $avatarUrl = Storage::disk('ovh')->url($filename);

        $user->update(['avatar_url' => $avatarUrl]);

        return $avatarUrl;
    }
}
