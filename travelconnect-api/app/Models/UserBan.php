<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserBan extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'banned_by',
        'reason',
        'is_permanent',
        'duration_days',
        'banned_at',
        'expires_at',
        'unbanned_at',
        'unbanned_by',
        'unban_reason',
    ];

    protected function casts(): array
    {
        return [
            'is_permanent' => 'boolean',
            'banned_at' => 'datetime',
            'expires_at' => 'datetime',
            'unbanned_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function bannedByAdmin(): BelongsTo
    {
        return $this->belongsTo(Admin::class, 'banned_by');
    }

    public function unbannedByAdmin(): BelongsTo
    {
        return $this->belongsTo(Admin::class, 'unbanned_by');
    }
}
