// package com.example.trackapp

// import android.Manifest
// import android.content.pm.PackageManager
// import android.os.Build
// import android.os.Bundle
// import android.telephony.TelephonyManager
// import androidx.annotation.NonNull
// import androidx.annotation.RequiresApi
// import androidx.core.app.ActivityCompat
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler
// import io.flutter.plugin.common.MethodChannel.Result

// class MainActivity : FlutterActivity() {
//     private val CHANNEL = "samples.flutter.dev/imei"
//     private val REQUEST_CODE = 1

//     override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "getIMEI" -> {
//                     if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
//                         ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE), REQUEST_CODE)
//                     } else {
//                         result.success(getIMEI())
//                     }
//                 }
//                 "stopSignal" -> {
//                     stopSignal(result)
//                 }
//                 else -> {
//                     result.notImplemented()
//                 }
//             }
//         }
//     }

//     @RequiresApi(Build.VERSION_CODES.O)
//     private fun getIMEI(): String {
//         val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
//         return telephonyManager.imei
//     }

//     private fun stopSignal(result: Result) {
//         result.success("Signal stopped")
//     }

//     override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
//         super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//         if (requestCode == REQUEST_CODE) {
//             if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                 MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("getIMEI", null)
//             }
//         }
//     }
// }

package com.example.trackapp

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/imei"
    private val REQUEST_CODE = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "stopSignal" -> {
                    stopSignal(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun stopSignal(result: Result) {
        result.success("Signal stopped")
    }

    private fun createPendingIntent(context: Context, requestCode: Int, intent: Intent): PendingIntent {
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(context, requestCode, intent, flags)
    }

    // Example of how to use createPendingIntent
    private fun showNotification() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = createPendingIntent(this, 0, notificationIntent)

        val notification = NotificationCompat.Builder(this, "default")
            .setContentTitle("Title")
            .setContentText("Content")
            .setSmallIcon(R.mipmap.favicon)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        with(NotificationManagerCompat.from(this)) {
            notify(1, notification)
        }
    }
}

