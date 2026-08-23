package de.cylone.soundwave

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.view.KeyEvent
import android.widget.RemoteViews
import com.ryanheise.audioservice.MediaButtonReceiver

class PlayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        PlayerWidgetUpdater.update(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_PLAY_PAUSE -> sendMedia(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
            ACTION_NEXT -> sendMedia(context, KeyEvent.KEYCODE_MEDIA_NEXT)
            ACTION_PREV -> sendMedia(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
            else -> super.onReceive(context, intent)
        }
    }

    private fun sendMedia(context: Context, keyCode: Int) {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launch != null && !hasTrack(context)) {
            launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(launch)
            return
        }
        for (action in listOf(KeyEvent.ACTION_DOWN, KeyEvent.ACTION_UP)) {
            val media = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
                setClass(context, MediaButtonReceiver::class.java)
                putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(action, keyCode))
            }
            context.sendBroadcast(media)
        }
    }

    companion object {
        const val ACTION_PLAY_PAUSE = "de.cylone.soundwave.widget.PLAY_PAUSE"
        const val ACTION_NEXT = "de.cylone.soundwave.widget.NEXT"
        const val ACTION_PREV = "de.cylone.soundwave.widget.PREV"
        const val PREFS = "player_widget"

        fun hasTrack(context: Context): Boolean {
            return context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean("hasTrack", false)
        }
    }
}

object PlayerWidgetUpdater {
    fun save(
        context: Context,
        title: String,
        artist: String,
        playing: Boolean,
        artworkPath: String?,
        hasTrack: Boolean,
    ) {
        context.getSharedPreferences(PlayerWidgetProvider.PREFS, Context.MODE_PRIVATE).edit()
            .putString("title", title)
            .putString("artist", artist)
            .putBoolean("playing", playing)
            .putString("artworkPath", artworkPath)
            .putBoolean("hasTrack", hasTrack)
            .apply()
        update(context)
    }

    fun update(context: Context) {
        val prefs = context.getSharedPreferences(PlayerWidgetProvider.PREFS, Context.MODE_PRIVATE)
        val hasTrack = prefs.getBoolean("hasTrack", false)
        val title = if (hasTrack) {
            prefs.getString("title", context.getString(R.string.widget_name)).orEmpty()
        } else {
            context.getString(R.string.widget_name)
        }
        val artist = if (hasTrack) {
            prefs.getString("artist", "").orEmpty().ifEmpty { context.getString(R.string.widget_idle) }
        } else {
            context.getString(R.string.widget_idle)
        }
        val playing = prefs.getBoolean("playing", false)
        val artworkPath = prefs.getString("artworkPath", null)
        val views = RemoteViews(context.packageName, R.layout.player_widget)
        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(R.id.widget_artist, artist)
        views.setImageViewResource(
            R.id.widget_play,
            if (playing) R.drawable.widget_pause else R.drawable.widget_play,
        )
        val art = decodeArt(artworkPath)
        if (art != null) {
            views.setImageViewBitmap(R.id.widget_art, art)
        } else {
            views.setImageViewResource(R.id.widget_art, R.mipmap.ic_launcher)
        }

        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        open.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        views.setOnClickPendingIntent(
            R.id.widget_root,
            PendingIntent.getActivity(context, 10, open, flags),
        )
        views.setOnClickPendingIntent(
            R.id.widget_play,
            broadcast(context, PlayerWidgetProvider.ACTION_PLAY_PAUSE, 11, flags),
        )
        views.setOnClickPendingIntent(
            R.id.widget_next,
            broadcast(context, PlayerWidgetProvider.ACTION_NEXT, 12, flags),
        )
        views.setOnClickPendingIntent(
            R.id.widget_prev,
            broadcast(context, PlayerWidgetProvider.ACTION_PREV, 13, flags),
        )

        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, PlayerWidgetProvider::class.java))
        if (ids.isNotEmpty()) {
            manager.updateAppWidget(ids, views)
        }
    }

    private fun broadcast(context: Context, action: String, code: Int, flags: Int): PendingIntent {
        val intent = Intent(context, PlayerWidgetProvider::class.java).setAction(action)
        return PendingIntent.getBroadcast(context, code, intent, flags)
    }

    private fun decodeArt(path: String?): android.graphics.Bitmap? {
        if (path.isNullOrBlank()) return null
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, bounds)
            var sample = 1
            val max = 256
            while (bounds.outWidth / sample > max || bounds.outHeight / sample > max) {
                sample *= 2
            }
            val opts = BitmapFactory.Options().apply { inSampleSize = sample }
            BitmapFactory.decodeFile(path, opts)
        } catch (_: Exception) {
            null
        }
    }
}
