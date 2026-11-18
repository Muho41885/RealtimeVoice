package com.example.realtime_voice

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder
import android.os.Process
import androidx.core.app.NotificationCompat
import kotlin.math.PI
import kotlin.math.sin

class VoiceChangerService : Service() {
    companion object {
        const val ACTION_SET_EFFECT = "com.example.realtime_voice.SET_EFFECT"
        const val EXTRA_EFFECT = "effect"
        private const val CHANNEL_ID = "voice_changer_live"
        private const val NOTIFICATION_ID = 4101
        private const val SAMPLE_RATE = 24000
    }

    @Volatile private var running = false
    @Volatile private var effect = "baby"
    private var audioThread: Thread? = null
    @Volatile private var recorder: AudioRecord? = null
    @Volatile private var player: AudioTrack? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_SET_EFFECT) {
            effect = intent.getStringExtra(EXTRA_EFFECT) ?: effect
            return START_NOT_STICKY
        }

        effect = intent?.getStringExtra(EXTRA_EFFECT) ?: effect
        if (!running) {
            val notification = buildNotification()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            running = true
            audioThread = Thread({ audioLoop() }, "voice-audio-loop").also { it.start() }
        }
        // Do not stop on task removal: the foreground service owns the audio stream,
        // not the Flutter activity, and continues while the app is backgrounded.
        return START_NOT_STICKY
    }

    private fun audioLoop() {
        Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
        var input: AudioRecord? = null
        var output: AudioTrack? = null
        try {
            val minBytes = AudioRecord.getMinBufferSize(
                SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
            )
            check(minBytes > 0) { "AudioRecord reported an unsupported audio configuration." }
            val bufferBytes = maxOf(minBytes, 4096)
            val inputRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferBytes * 2
            )
            input = inputRecord
            check(inputRecord.state == AudioRecord.STATE_INITIALIZED) {
                "Could not initialize the microphone audio recorder."
            }

            val outputTrack = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setSampleRate(SAMPLE_RATE)
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build()
                )
                .setBufferSizeInBytes(bufferBytes * 2)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()
            output = outputTrack
            check(outputTrack.state == AudioTrack.STATE_INITIALIZED) {
                "Could not initialize audio playback."
            }
            recorder = inputRecord
            player = outputTrack

            inputRecord.startRecording()
            outputTrack.play()
            val samples = ShortArray(bufferBytes / 2)
            var phase = 0.0
            while (running && !Thread.currentThread().isInterrupted) {
                val count = inputRecord.read(samples, 0, samples.size)
                if (count > 0) {
                    phase = process(samples, count, effect, phase)
                    outputTrack.write(samples, 0, count, AudioTrack.WRITE_BLOCKING)
                }
            }
        } catch (_: Exception) {
            // Release resources and remove the foreground service if audio setup fails.
            stopSelf()
        } finally {
            try { input?.stop() } catch (_: Exception) {}
            input?.release()
            output?.pause()
            output?.flush()
            output?.release()
            recorder = null
            player = null
            if (!running) stopSelf()
        }
    }

    // Lightweight demo DSP: simple pitch resampling and amplitude modulation for robot.
    private fun process(data: ShortArray, count: Int, mode: String, phaseStart: Double): Double {
        val ratio = when (mode) {
            "baby" -> 1.45
            "deep" -> 0.72
            "funny" -> 1.8
            else -> 1.0
        }
        // Read from a copy so output samples don't overwrite source samples needed later.
        val sourceSamples = data.copyOf(count)
        var phase = phaseStart
        for (i in 0 until count) {
            val source = ((i * ratio).toInt() % count).coerceIn(0, count - 1)
            var sample = sourceSamples[source].toDouble()
            if (mode == "robot") {
                sample *= sin(phase)
                phase += 2.0 * PI * 38.0 / SAMPLE_RATE
                if (phase >= 2.0 * PI) phase -= 2.0 * PI
            }
            data[i] = sample.toInt()
                .coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt())
                .toShort()
        }
        return phase
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Canlı ses",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("Realtime Voice çalışıyor")
        .setContentText("Mikrofon sesi canlı olarak işleniyor")
        .setSmallIcon(android.R.drawable.ic_btn_speak_now)
        .setOngoing(true)
        .setCategory(NotificationCompat.CATEGORY_SERVICE)
        .build()

    override fun onDestroy() {
        running = false
        try { recorder?.stop() } catch (_: Exception) {}
        try { player?.pause() } catch (_: Exception) {}
        audioThread?.interrupt()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
