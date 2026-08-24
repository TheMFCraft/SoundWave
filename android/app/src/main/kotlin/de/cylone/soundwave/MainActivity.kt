package de.cylone.soundwave

import android.content.ContentUris
import android.content.Context
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val channelName = "de.cylone.soundwave/media"
    private var hotspotReservation: WifiManager.LocalOnlyHotspotReservation? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "queryAudio" -> result.success(queryAudio())
                    "loadAlbumArt" -> {
                        val albumId = call.argument<Number>("albumId")?.toLong()
                        if (albumId == null) {
                            result.success(null)
                        } else {
                            result.success(loadAlbumArt(albumId))
                        }
                    }
                    "copyAudioToPath" -> {
                        val src = call.argument<String>("src")
                        val dest = call.argument<String>("dest")
                        if (src.isNullOrBlank() || dest.isNullOrBlank()) {
                            result.error("ARG", "missing src/dest", null)
                        } else {
                            copyAudioToPath(src, dest, result)
                        }
                    }
                    "updatePlayerWidget" -> {
                        val title = call.argument<String>("title") ?: ""
                        val artist = call.argument<String>("artist") ?: ""
                        val playing = call.argument<Boolean>("playing") ?: false
                        val artworkPath = call.argument<String>("artworkPath")
                        val hasTrack = call.argument<Boolean>("hasTrack") ?: false
                        PlayerWidgetUpdater.save(this, title, artist, playing, artworkPath, hasTrack)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "de.cylone.soundwave/integrity")
            .setMethodCallHandler { call, result ->
                if (call.method != "requestIntegrityToken") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                PlayIntegrity.requestToken(this) { token ->
                    runOnUiThread { result.success(token) }
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "de.cylone.soundwave/jam")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startLocalHotspot" -> startLocalHotspot(result)
                    "stopLocalHotspot" -> {
                        stopLocalHotspot()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startLocalHotspot(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.error("UNSUPPORTED", "Local hotspot requires Android 8+", null)
            return
        }
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        try {
            wifi.startLocalOnlyHotspot(
                object : WifiManager.LocalOnlyHotspotCallback() {
                    override fun onStarted(reservation: WifiManager.LocalOnlyHotspotReservation) {
                        hotspotReservation = reservation
                        result.success(hotspotCredentials(reservation))
                    }

                    override fun onFailed(reason: Int) {
                        result.error("FAILED", "Hotspot failed: $reason", null)
                    }
                },
                Handler(Looper.getMainLooper()),
            )
        } catch (error: Exception) {
            result.error("FAILED", error.message, null)
        }
    }

    @Suppress("DEPRECATION")
    private fun hotspotCredentials(reservation: WifiManager.LocalOnlyHotspotReservation): HashMap<String, String> {
        val map = HashMap<String, String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val sap = reservation.softApConfiguration
            val ssid = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                sap.wifiSsid?.toString()?.trim('"') ?: ""
            } else {
                sap.ssid ?: ""
            }
            map["ssid"] = ssid
            map["password"] = sap.passphrase ?: ""
        } else {
            val conf = reservation.wifiConfiguration
            map["ssid"] = conf?.SSID?.trim('"') ?: ""
            map["password"] = conf?.preSharedKey ?: ""
        }
        return map
    }

    private fun stopLocalHotspot() {
        hotspotReservation?.close()
        hotspotReservation = null
    }

    private fun queryAudio(): ArrayList<HashMap<String, Any?>> {
        val songs = ArrayList<HashMap<String, Any?>>()
        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = mutableListOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DISPLAY_NAME,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            projection.add(MediaStore.Audio.Media.RELATIVE_PATH)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            projection.add(MediaStore.Audio.Media.GENRE)
        }

        val selection = "${MediaStore.Audio.Media.IS_MUSIC}!=0"
        val sort = "${MediaStore.Audio.Media.DATE_ADDED} DESC"
        contentResolver.query(collection, projection.toTypedArray(), selection, null, sort)?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val albumIdCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val dataCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)
            val relativeCol = cursor.getColumnIndex(MediaStore.Audio.Media.RELATIVE_PATH)
            val displayCol = cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME)
            val genreCol = cursor.getColumnIndex(MediaStore.Audio.Media.GENRE)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                val contentUri = ContentUris.withAppendedId(collection, id).toString()
                val relative = if (relativeCol >= 0) cursor.getString(relativeCol) else null
                val display = if (displayCol >= 0) cursor.getString(displayCol) else null
                val dataPath = if (dataCol >= 0) cursor.getString(dataCol) else null
                val reconstructed = if (!relative.isNullOrBlank() && !display.isNullOrBlank()) {
                    "/storage/emulated/0/${relative}${display}"
                } else null
                val path = dataPath ?: reconstructed
                val map = HashMap<String, Any?>()
                map["id"] = id
                map["title"] = cursor.getString(titleCol)
                map["artist"] = cursor.getString(artistCol)
                map["album"] = cursor.getString(albumCol)
                map["durationMs"] = cursor.getLong(durationCol)
                map["albumId"] = cursor.getLong(albumIdCol)
                map["contentUri"] = contentUri
                map["path"] = path
                map["relativePath"] = relative
                map["displayName"] = display
                map["genre"] = if (genreCol >= 0) cursor.getString(genreCol) else null
                songs.add(map)
            }
        }
        return songs
    }

    private fun copyAudioToPath(src: String, dest: String, result: MethodChannel.Result) {
        Thread {
            try {
                val outFile = java.io.File(dest)
                outFile.parentFile?.mkdirs()
                val input = openAudioStream(src) ?: throw IllegalStateException("cannot open audio")
                input.use { ins ->
                    outFile.outputStream().use { outs -> ins.copyTo(outs) }
                }
                Handler(Looper.getMainLooper()).post { result.success(true) }
            } catch (e: Exception) {
                Handler(Looper.getMainLooper()).post {
                    result.error("IO", e.message, null)
                }
            }
        }.start()
    }

    private fun openAudioStream(src: String): java.io.InputStream? {
        if (src.startsWith("content:") || src.startsWith("file:")) {
            return contentResolver.openInputStream(android.net.Uri.parse(src))
        }
        val file = java.io.File(src)
        if (file.exists()) return file.inputStream()
        return try {
            contentResolver.openInputStream(android.net.Uri.fromFile(file))
        } catch (_: Exception) {
            null
        }
    }

    private fun loadAlbumArt(albumId: Long): ByteArray? {
        val uri = ContentUris.withAppendedId(
            android.net.Uri.parse("content://media/external/audio/albumart"),
            albumId,
        )
        return try {
            contentResolver.openInputStream(uri)?.use { it.readBytes() }
        } catch (_: Exception) {
            null
        }
    }
}
