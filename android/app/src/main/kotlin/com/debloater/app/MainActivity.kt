package com.debloater.app

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import rikka.shizuku.ShizukuProvider

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.debloater.app/shizuku"
    private lateinit var channel: MethodChannel

    private val requestPermissionResultListener =
        Shizuku.OnRequestPermissionResultListener { requestCode, grantResult ->
            val granted = grantResult == PackageManager.PERMISSION_GRANTED
            if (::channel.isInitialized) {
                runOnUiThread {
                    channel.invokeMethod("onPermissionResult", granted)
                }
            }
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Shizuku.addRequestPermissionResultListener(requestPermissionResultListener)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getShizukuStatus" -> result.success(getShizukuStatus())
                "requestShizukuPermission" -> requestShizukuPermission(result)
                "getSystemApps" -> getSystemApps(result)
                "disableApp" -> {
                    val pkg = call.argument<String>("packageName") ?: return@setMethodCallHandler result.error("BAD_ARGS", "packageName required", null)
                    disableApp(pkg, result)
                }
                "uninstallApp" -> {
                    val pkg = call.argument<String>("packageName") ?: return@setMethodCallHandler result.error("BAD_ARGS", "packageName required", null)
                    uninstallApp(pkg, result)
                }
                "enableApp" -> {
                    val pkg = call.argument<String>("packageName") ?: return@setMethodCallHandler result.error("BAD_ARGS", "packageName required", null)
                    enableApp(pkg, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Shizuku.removeRequestPermissionResultListener(requestPermissionResultListener)
    }

    // ─── Shizuku Status ───────────────────────────────────────────────────────

    private fun getShizukuStatus(): Int {
        return try {
            when {
                !isShizukuInstalled() -> 0           // Not installed
                !Shizuku.pingBinder() -> 1            // Not running
                !hasShizukuPermission() -> 2          // No permission
                else -> 3                             // Ready
            }
        } catch (e: Exception) {
            0
        }
    }

    private fun isShizukuInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo("moe.shizuku.privileged.api", 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun hasShizukuPermission(): Boolean {
        return if (Shizuku.isPreV11()) {
            checkSelfPermission(ShizukuProvider.PERMISSION) == PackageManager.PERMISSION_GRANTED
        } else {
            Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestShizukuPermission(result: MethodChannel.Result) {
        try {
            if (Shizuku.isPreV11()) {
                requestPermissions(arrayOf(ShizukuProvider.PERMISSION), 1001)
                result.success(false)
            } else {
                if (hasShizukuPermission()) {
                    result.success(true)
                } else {
                    Shizuku.requestPermission(1001)
                    result.success(false)
                }
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    // ─── App Discovery ────────────────────────────────────────────────────────

    private fun getSystemApps(result: MethodChannel.Result) {
        Thread {
            try {
                val pm = packageManager
                val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                    .filter { it.flags and ApplicationInfo.FLAG_SYSTEM != 0 }
                    .map { info ->
                        val appName = pm.getApplicationLabel(info).toString()
                        val isEnabled = info.enabled
                        mapOf(
                            "packageName" to info.packageName,
                            "appName" to appName,
                            "isSystemApp" to true,
                            "status" to if (isEnabled) "enabled" else "disabled",
                            "isRecommendedBloatware" to false
                        )
                    }
                    .sortedBy { it["appName"] as String }

                runOnUiThread { result.success(apps) }
            } catch (e: Exception) {
                runOnUiThread { result.error("SCAN_ERROR", e.message, null) }
            }
        }.start()
    }

    // ─── Shell Command Execution via Shizuku ──────────────────────────────────

    private fun executeShellCommand(command: String): ShellResult {
        return try {
            val process = Shizuku.newProcess(
                arrayOf("sh", "-c", command),
                null,
                null
            )
            val exitCode = process.waitFor()
            val output = process.inputStream.bufferedReader().readText().trim()
            val error = process.errorStream.bufferedReader().readText().trim()
            ShellResult(exitCode == 0, output, error)
        } catch (e: Exception) {
            ShellResult(false, "", e.message ?: "Unknown error")
        }
    }

    private fun disableApp(packageName: String, result: MethodChannel.Result) {
        Thread {
            val cmd = "pm disable-user --user 0 $packageName"
            val shellResult = executeShellCommand(cmd)
            val response = mapOf(
                "success" to shellResult.success,
                "message" to if (shellResult.success) "App disabled successfully" else shellResult.error
            )
            runOnUiThread { result.success(response) }
        }.start()
    }

    private fun uninstallApp(packageName: String, result: MethodChannel.Result) {
        Thread {
            val cmd = "pm uninstall -k --user 0 $packageName"
            val shellResult = executeShellCommand(cmd)
            val response = mapOf(
                "success" to shellResult.success,
                "message" to if (shellResult.success) "App removed successfully" else shellResult.error
            )
            runOnUiThread { result.success(response) }
        }.start()
    }

    private fun enableApp(packageName: String, result: MethodChannel.Result) {
        Thread {
            val cmd = "pm enable --user 0 $packageName"
            val shellResult = executeShellCommand(cmd)
            val response = mapOf(
                "success" to shellResult.success,
                "message" to if (shellResult.success) "App enabled successfully" else shellResult.error
            )
            runOnUiThread { result.success(response) }
        }.start()
    }
}

data class ShellResult(val success: Boolean, val output: String, val error: String)
