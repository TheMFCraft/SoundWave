package de.cylone.soundwave

import android.content.Context
import android.util.Base64
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import java.security.SecureRandom

object PlayIntegrity {
    fun requestToken(context: Context, onDone: (String?) -> Unit) {
        try {
            val nonceBytes = ByteArray(32)
            SecureRandom().nextBytes(nonceBytes)
            val nonce = Base64.encodeToString(
                nonceBytes,
                Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING,
            )
            val request = IntegrityTokenRequest.builder().setNonce(nonce).build()
            IntegrityManagerFactory.create(context)
                .requestIntegrityToken(request)
                .addOnSuccessListener { onDone(it.token()) }
                .addOnFailureListener { onDone(null) }
        } catch (_: Exception) {
            onDone(null)
        }
    }
}
