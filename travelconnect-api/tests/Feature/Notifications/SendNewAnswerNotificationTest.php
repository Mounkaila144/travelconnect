<?php

namespace Tests\Feature\Notifications;

use App\Events\AnswerCreated;
use App\Listeners\SendNewAnswerNotification;
use App\Models\Answer;
use App\Models\Question;
use App\Models\User;
use App\Services\FCMService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Mockery;
use Tests\TestCase;

class SendNewAnswerNotificationTest extends TestCase
{
    use RefreshDatabase;

    private function createMockFCMService(bool $expectSend = true, int $times = 1): FCMService
    {
        $mock = Mockery::mock(FCMService::class);

        if ($expectSend) {
            $mock->shouldReceive('sendNotification')
                ->times($times)
                ->andReturn(true);
        } else {
            $mock->shouldNotReceive('sendNotification');
        }

        $this->app->instance(FCMService::class, $mock);

        return $mock;
    }

    public function test_notification_sent_when_answer_created(): void
    {
        $questionAuthor = User::factory()->create([
            'fcm_token' => 'test_fcm_token',
            'notification_settings' => ['new_answers' => true],
        ]);

        $answerAuthor = User::factory()->create(['name' => 'John Doe']);

        $question = Question::factory()->create([
            'user_id' => $questionAuthor->id,
            'title' => 'Best ramen in Tokyo?',
        ]);

        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $answerAuthor->id,
            'content' => 'Try Ichiran!',
        ]);

        $this->createMockFCMService(true);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $questionAuthor->id,
            'type' => 'new_answer',
        ]);
    }

    public function test_notification_contains_question_title_and_author_name(): void
    {
        $questionAuthor = User::factory()->create([
            'fcm_token' => 'test_token',
        ]);

        $answerAuthor = User::factory()->create(['name' => 'Tanaka']);

        $question = Question::factory()->create([
            'user_id' => $questionAuthor->id,
            'title' => 'Meilleur sushi à Osaka?',
        ]);

        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $answerAuthor->id,
        ]);

        $fcmMock = Mockery::mock(FCMService::class);
        $fcmMock->shouldReceive('sendNotification')
            ->once()
            ->with(
                'test_token',
                Mockery::on(function ($notification) {
                    return $notification['title'] === 'Nouvelle réponse'
                        && str_contains($notification['body'], 'Tanaka')
                        && str_contains($notification['body'], 'Meilleur sushi à Osaka?');
                }),
                Mockery::on(function ($data) use ($question, $answer) {
                    return $data['type'] === 'new_answer'
                        && $data['question_id'] === (string) $question->id
                        && $data['answer_id'] === (string) $answer->id;
                })
            )
            ->andReturn(true);
        $this->app->instance(FCMService::class, $fcmMock);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);
    }

    public function test_notification_not_sent_if_user_answers_own_question(): void
    {
        $user = User::factory()->create(['fcm_token' => 'test_token']);

        $question = Question::factory()->create(['user_id' => $user->id]);
        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $user->id,
        ]);

        $this->createMockFCMService(false);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);

        $this->assertDatabaseMissing('notifications', [
            'user_id' => $user->id,
            'type' => 'new_answer',
        ]);
    }

    public function test_notification_not_sent_if_user_has_no_fcm_token(): void
    {
        $questionAuthor = User::factory()->create(['fcm_token' => null]);
        $answerAuthor = User::factory()->create();

        $question = Question::factory()->create(['user_id' => $questionAuthor->id]);
        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $answerAuthor->id,
        ]);

        $this->createMockFCMService(false);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);

        $this->assertDatabaseMissing('notifications', [
            'user_id' => $questionAuthor->id,
            'type' => 'new_answer',
        ]);
    }

    public function test_notification_not_sent_if_user_disabled_new_answers(): void
    {
        $questionAuthor = User::factory()->create([
            'fcm_token' => 'test_token',
            'notification_settings' => ['new_answers' => false],
        ]);
        $answerAuthor = User::factory()->create();

        $question = Question::factory()->create(['user_id' => $questionAuthor->id]);
        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $answerAuthor->id,
        ]);

        $this->createMockFCMService(false);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);

        $this->assertDatabaseMissing('notifications', [
            'user_id' => $questionAuthor->id,
        ]);
    }

    public function test_notification_record_created_in_database(): void
    {
        $questionAuthor = User::factory()->create(['fcm_token' => 'test_token']);
        $answerAuthor = User::factory()->create(['name' => 'Marie']);

        $question = Question::factory()->create([
            'user_id' => $questionAuthor->id,
            'title' => 'Where to eat?',
        ]);

        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $answerAuthor->id,
        ]);

        $this->createMockFCMService(true);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $questionAuthor->id,
            'type' => 'new_answer',
            'title' => 'Nouvelle réponse',
        ]);

        $notification = \App\Models\Notification::where('user_id', $questionAuthor->id)->first();
        $this->assertNull($notification->read_at);
        $this->assertNotNull($notification->data);
        $this->assertEquals('new_answer', $notification->data['type']);
        $this->assertEquals((string) $question->id, $notification->data['question_id']);
    }

    public function test_notification_sent_when_settings_are_null(): void
    {
        $questionAuthor = User::factory()->create([
            'fcm_token' => 'test_token',
            'notification_settings' => null,
        ]);
        $answerAuthor = User::factory()->create();

        $question = Question::factory()->create(['user_id' => $questionAuthor->id]);
        $answer = Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $answerAuthor->id,
        ]);

        $this->createMockFCMService(true);

        $event = new AnswerCreated($answer, $question);
        $listener = app(SendNewAnswerNotification::class);
        $listener->handle($event);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $questionAuthor->id,
            'type' => 'new_answer',
        ]);
    }
}
