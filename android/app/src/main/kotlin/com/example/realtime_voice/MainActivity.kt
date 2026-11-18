package com.example.realtime_voice

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.core.content.ContextCompat

class MainActivity : Activity() {
    companion object {
        private const val AUDIO_PERMISSION_REQUEST = 701
        private const val SITE_URL = "https://muho41885.github.io/RealtimeVoice/"
        private const val SITE_HOST = "muho41885.github.io"
    }

    private var webView: WebView? = null
    private var pendingWebPermission: PermissionRequest? = null
    private var pendingWebResources: Array<String> = emptyArray()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val view = WebView(this)
        webView = view
        view.settings.javaScriptEnabled = true
        view.settings.domStorageEnabled = true
        view.settings.mediaPlaybackRequiresUserGesture = false
        view.webViewClient = WebViewClient()
        view.webChromeClient = object : WebChromeClient() {
            override fun onPermissionRequest(request: PermissionRequest) {
                runOnUiThread {
                    val origin = Uri.parse(request.origin.toString())
                    if (origin.scheme != "https" || origin.host != SITE_HOST) {
                        request.deny()
                        return@runOnUiThread
                    }

                    val audioResources = request.resources
                        .filter { it == PermissionRequest.RESOURCE_AUDIO_CAPTURE }
                        .toTypedArray()
                    if (audioResources.isEmpty()) {
                        request.deny()
                        return@runOnUiThread
                    }

                    if (ContextCompat.checkSelfPermission(
                            this@MainActivity,
                            Manifest.permission.RECORD_AUDIO
                        ) == PackageManager.PERMISSION_GRANTED
                    ) {
                        request.grant(audioResources)
                    } else {
                        pendingWebPermission?.deny()
                        pendingWebPermission = request
                        pendingWebResources = audioResources
                        requestPermissions(
                            arrayOf(Manifest.permission.RECORD_AUDIO),
                            AUDIO_PERMISSION_REQUEST
                        )
                    }
                }
            }

            override fun onPermissionRequestCanceled(request: PermissionRequest) {
                if (pendingWebPermission == request) {
                    pendingWebPermission = null
                    pendingWebResources = emptyArray()
                }
            }
        }
        setContentView(view)
        view.loadUrl(SITE_URL)
    }

    @Deprecated("Deprecated in Android API; retained for compatibility with the Flutter template")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != AUDIO_PERMISSION_REQUEST) return

        val request = pendingWebPermission
        pendingWebPermission = null
        if (request != null && grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            request.grant(pendingWebResources)
        } else {
            request?.deny()
        }
        pendingWebResources = emptyArray()
    }

    @Deprecated("Deprecated in Android API")
    override fun onBackPressed() {
        val view = webView
        if (view?.canGoBack() == true) view.goBack() else super.onBackPressed()
    }

    override fun onDestroy() {
        pendingWebPermission?.deny()
        pendingWebPermission = null
        webView?.apply {
            stopLoading()
            destroy()
        }
        webView = null
        super.onDestroy()
    }
}
