package com.cobi.paint.cobi_paint_mobile

import android.content.ContentValues
import android.graphics.BitmapFactory
import android.os.Build
import android.provider.MediaStore
import androidx.print.PrintHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The grown-up exports Android's share sheet does not offer: saving a picture
 * to the gallery (MediaStore, no permission from Android 10) and printing it
 * through the system print dialog (PrintHelper). Both sit behind the parental
 * gate on the Dart side; iOS has both in its share sheet and no channel.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "capabilities" -> result.success(
                    mapOf(
                        "gallery" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q),
                        "print" to PrintHelper.systemSupportsPrint(),
                    )
                )
                "saveToGallery" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val name = call.argument<String>("name") ?: "cobi_paint"
                    if (bytes == null) {
                        result.error("args", "bytes missing", null)
                        return@setMethodCallHandler
                    }
                    // Off the main thread: a page is up to a few megabytes.
                    Thread {
                        try {
                            val uri = saveToGallery(bytes, name)
                            runOnUiThread { result.success(uri) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("save", e.message, null) }
                        }
                    }.start()
                }
                "print" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val name = call.argument<String>("name") ?: "Cobi Paint"
                    if (bytes == null) {
                        result.error("args", "bytes missing", null)
                        return@setMethodCallHandler
                    }
                    try {
                        print(bytes, name)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("print", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Writes [bytes] as a PNG into Pictures/Cobi Paint and returns its gallery URI. */
    private fun saveToGallery(bytes: ByteArray, name: String): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw UnsupportedOperationException("saving to the gallery needs Android 10")
        }
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, "$name.png")
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Cobi Paint")
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }
        val resolver = contentResolver
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("the gallery refused the picture")
        try {
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("the picture cannot be written")
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }
        return uri.toString()
    }

    /** Opens the system print dialog with the picture fitted to one page. */
    private fun print(bytes: ByteArray, name: String) {
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            ?: throw IllegalArgumentException("not a picture")
        PrintHelper(this).apply {
            scaleMode = PrintHelper.SCALE_MODE_FIT
            colorMode = PrintHelper.COLOR_MODE_COLOR
        }.printBitmap(name, bitmap)
    }

    private companion object {
        const val CHANNEL = "cobi.paint/export"
    }
}
