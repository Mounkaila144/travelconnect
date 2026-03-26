<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Question extends Model
{
    use HasFactory;

    protected $hidden = [
        'location',
    ];

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'latitude',
        'longitude',
        'location',
        'location_name',
        'city',
        'answers_count',
        'has_unread_answers',
        'is_deleted',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'answers_count' => 'integer',
            'has_unread_answers' => 'boolean',
            'is_deleted' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function answers(): HasMany
    {
        return $this->hasMany(Answer::class);
    }

    public function reports(): \Illuminate\Database\Eloquent\Relations\MorphMany
    {
        return $this->morphMany(Report::class, 'reportable');
    }

    public function getHasAnswersAttribute(): bool
    {
        return $this->answers_count > 0;
    }

    public function getNeedsAnswerAttribute(): bool
    {
        return $this->answers_count === 0;
    }
}
