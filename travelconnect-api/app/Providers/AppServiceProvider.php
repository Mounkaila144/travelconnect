<?php

namespace App\Providers;

use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;
use SocialiteProviders\Apple\AppleExtendSocialite;
use SocialiteProviders\Manager\SocialiteWasCalled;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Socialite Apple - must be manual (third-party, not auto-discovered)
        Event::listen(SocialiteWasCalled::class, AppleExtendSocialite::class);
        // AnswerCreated, QuestionCreated, AnswerRated listeners are auto-discovered by Laravel
    }
}
