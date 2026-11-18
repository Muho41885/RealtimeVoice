package com.example.realtime_voice

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "realtime_voice/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val intent = Intent(this, VoiceChangerService::class.java)
                            .putExtra(VoiceChangerService.EXTRA_EFFECT, call.argument<String>("effect") ?: "baby")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(intent)
                        else startService(intent)
                        result.success(null)
                    }
                    "setEffect" -> {
                        val intent = Intent(this, VoiceChangerService::class.java)
                            .setAction(VoiceChangerService.ACTION_SET_EFFECT)
                            .putExtra(VoiceChangerService.EXTRA_EFFECT, call.argument<String>("effect") ?: "baby")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(intent)
                        else startService(intent)
                        result.success(null)
                    }
                    "stop" -> {
                        stopService(Intent(this, VoiceChangerService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
