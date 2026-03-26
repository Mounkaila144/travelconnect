<?php

namespace Tests\Unit\Services;

use App\Services\FCMService;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Mockery;
use Tests\TestCase;

class FCMServiceTest extends TestCase
{
    private Messaging $mockMessaging;

    protected function setUp(): void
    {
        parent::setUp();
        $this->mockMessaging = Mockery::mock(Messaging::class);
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    private function createServiceWithMock(): FCMService
    {
        $reflection = new \ReflectionClass(FCMService::class);
        $instance = $reflection->newInstanceWithoutConstructor();

        $property = $reflection->getProperty('messaging');
        $property->setAccessible(true);
        $property->setValue($instance, $this->mockMessaging);

        return $instance;
    }

    public function test_send_notification_success(): void
    {
        $this->mockMessaging->shouldReceive('send')
            ->once()
            ->with(Mockery::type(CloudMessage::class))
            ->andReturn([]);

        $service = $this->createServiceWithMock();

        $result = $service->sendNotification(
            'test_fcm_token_12345',
            ['title' => 'Test', 'body' => 'Test body'],
            ['question_id' => '1']
        );

        $this->assertTrue($result);
    }

    public function test_send_notification_with_invalid_token(): void
    {
        $this->mockMessaging->shouldReceive('send')
            ->once()
            ->andThrow(new \Kreait\Firebase\Exception\Messaging\InvalidMessage('Invalid token'));

        $service = $this->createServiceWithMock();

        $result = $service->sendNotification(
            'invalid_token',
            ['title' => 'Test', 'body' => 'Test body']
        );

        $this->assertFalse($result);
    }

    public function test_send_notification_handles_general_exception(): void
    {
        $this->mockMessaging->shouldReceive('send')
            ->once()
            ->andThrow(new \Exception('Firebase unavailable'));

        $service = $this->createServiceWithMock();

        $result = $service->sendNotification(
            'test_token',
            ['title' => 'Test', 'body' => 'Test body']
        );

        $this->assertFalse($result);
    }

    public function test_send_multicast_to_multiple_devices(): void
    {
        $this->mockMessaging->shouldReceive('send')
            ->times(3)
            ->andReturn([]);

        $service = $this->createServiceWithMock();

        $tokens = ['token_1', 'token_2', 'token_3'];

        $results = $service->sendMulticast(
            $tokens,
            ['title' => 'Test', 'body' => 'Test body']
        );

        $this->assertCount(3, $results);
        $this->assertTrue($results['token_1']);
        $this->assertTrue($results['token_2']);
        $this->assertTrue($results['token_3']);
    }

    public function test_send_notification_includes_correct_payload_structure(): void
    {
        $this->mockMessaging->shouldReceive('send')
            ->once()
            ->with(Mockery::on(function ($message) {
                return $message instanceof CloudMessage;
            }))
            ->andReturn([]);

        $service = $this->createServiceWithMock();

        $result = $service->sendNotification(
            'test_token',
            ['title' => 'Nouvelle réponse', 'body' => 'Tanaka a répondu'],
            ['type' => 'new_answer', 'question_id' => '123']
        );

        $this->assertTrue($result);
    }
}
