package de.cylone.soundwave

import android.content.ContentUris
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val channelName = "de.cylone.soundwave/media"

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
