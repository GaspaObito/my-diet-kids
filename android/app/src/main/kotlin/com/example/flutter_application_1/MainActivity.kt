package com.example.flutter_application_1

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.max

class MainActivity : FlutterActivity(), SensorEventListener {
    private val methodChannelName = "mydiet/steps"
    private val eventChannelName = "mydiet/steps_stream"
    private val requestActivityRecognition = 4552
    private val prefsName = "mydiet_step_counter"

    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null
    private var listening = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startStepTracking" -> result.success(startStepTracking())
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            eventChannelName
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                startStepTracking()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private fun startStepTracking(): Map<String, Any> {
        if (stepSensor == null) {
            return status(false, false, "Este celular no tiene sensor de pasos.")
        }

        if (!hasActivityPermission()) {
            requestActivityPermission()
            return status(
                true,
                false,
                "Permite actividad fisica para completar la caminata sola."
            )
        }

        ensureListening()
        return status(true, true, "Pasos detectados por el celular.")
    }

    private fun ensureListening() {
        if (listening) return
        val sensor = stepSensor ?: return
        sensorManager?.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
        listening = true
    }

    private fun hasActivityPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestActivityPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            requestPermissions(
                arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                requestActivityRecognition
            )
        }
    }

    private fun status(
        available: Boolean,
        permissionGranted: Boolean,
        message: String
    ): Map<String, Any> {
        return mapOf(
            "available" to available,
            "permissionGranted" to permissionGranted,
            "steps" to storedSteps(),
            "message" to message
        )
    }

    private fun todayKey(): String {
        return SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
    }

    private fun storedSteps(): Int {
        val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        return prefs.getInt("steps_${todayKey()}", 0)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type != Sensor.TYPE_STEP_COUNTER) return
        if (event.values.isEmpty()) return
        val totalSteps = event.values[0].toInt()
        val today = todayKey()
        val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val baselineKey = "baseline_$today"
        var baseline = prefs.getInt(baselineKey, -1)

        if (baseline < 0 || totalSteps < baseline) {
            baseline = totalSteps
            prefs.edit().putInt(baselineKey, baseline).apply()
        }

        val todaySteps = max(0, totalSteps - baseline)
        prefs.edit().putInt("steps_$today", todaySteps).apply()
        eventSink?.success(todaySteps)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == requestActivityRecognition && hasActivityPermission()) {
            ensureListening()
            eventSink?.success(storedSteps())
        }
    }

    override fun onDestroy() {
        sensorManager?.unregisterListener(this)
        listening = false
        super.onDestroy()
    }
}
