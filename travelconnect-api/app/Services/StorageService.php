<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Drivers\Gd\Driver;
use Intervention\Image\ImageManager;

class StorageService
{
    public function uploadAvatar(UploadedFile $file, User $user): string
    {
        try {
            $manager = new ImageManager(new Driver());

            $image = $manager->read($file->getPathname())
                ->cover(400, 400)
                ->toJpeg(80);
        } catch (\Throwable $e) {
            Log::error('Avatar image processing failed', [
                'user_id' => $user->id,
                'file_mime' => $file->getMimeType(),
                'file_size' => $file->getSize(),
                'error' => $e->getMessage(),
            ]);
            throw new \RuntimeException('Image processing failed: ' . $e->getMessage(), 0, $e);
        }

        $filename = "avatars/{$user->id}_" . time() . '.jpg';

        try {
            if ($user->avatar_url) {
                $oldPath = parse_url($user->avatar_url, PHP_URL_PATH);
                $oldPath = ltrim($oldPath, '/');
                Storage::disk('ovh')->delete($oldPath);
            }

            Storage::disk('ovh')->put($filename, (string) $image, 'public');
        } catch (\Throwable $e) {
            Log::error('Avatar storage upload failed', [
                'user_id' => $user->id,
                'filename' => $filename,
                'error' => $e->getMessage(),
            ]);
            throw new \RuntimeException('Storage upload failed: ' . $e->getMessage(), 0, $e);
        }

        $avatarUrl = Storage::disk('ovh')->url($filename);

        $user->update(['avatar_url' => $avatarUrl]);

        return $avatarUrl;
    }
}
