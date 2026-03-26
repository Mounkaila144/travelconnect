<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'email',
        'name',
        'avatar_url',
        'bio',
        'country_code',
        'provider',
        'provider_id',
        'fcm_token',
        'notification_settings',
        'notification_zone_lat',
        'notification_zone_lng',
        'notification_zone_radius',
        'user_type',
        'trust_score',
        'is_new',
        'is_banned',
    ];

    protected $hidden = [
        'provider_id',
    ];

    protected function casts(): array
    {
        return [
            'trust_score' => 'decimal:2',
            'is_new' => 'boolean',
            'is_banned' => 'boolean',
            'notification_settings' => 'array',
        ];
    }

    public function questions(): HasMany
    {
        return $this->hasMany(Question::class);
    }

    public function answers(): HasMany
    {
        return $this->hasMany(Answer::class);
    }

    public function bans(): HasMany
    {
        return $this->hasMany(UserBan::class);
    }

    public function adminActions(): HasMany
    {
        return $this->hasMany(AdminUserAction::class);
    }

    public function getActiveBanAttribute(): ?UserBan
    {
        return $this->bans()->whereNull('unbanned_at')->latest('banned_at')->first();
    }
}
