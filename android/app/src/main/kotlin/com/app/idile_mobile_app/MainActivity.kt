package com.app.idile_mobile_app

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.security.spec.ECGenParameterSpec
import java.util.Base64

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.app.idile_mobile_app/device_binding"
        private const val KEY_ALIAS = "idile_device_binding_v1"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getDeviceInfo" -> result.success(deviceInfo())
                        "sign" -> {
                            val message = call.argument<String>("message")
                                ?: throw IllegalArgumentException("message is required")
                            result.success(sign(message))
                        }
                        "deleteKey" -> {
                            deleteKey()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("DEVICE_BINDING", error.message, null)
                }
            }
    }

    private fun keyStore(): KeyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    private fun ensureKey() {
        if (keyStore().containsAlias(KEY_ALIAS)) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                generateKey(strongBox = true)
                return
            } catch (_: StrongBoxUnavailableException) {
                // Use the regular hardware-backed Android Keystore when the
                // device does not expose StrongBox.
            }
        }
        generateKey(strongBox = false)
    }

    private fun generateKey(strongBox: Boolean) {
        val builder = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY,
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            .setUserAuthenticationRequired(false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && strongBox) {
            builder.setIsStrongBoxBacked(true)
        }
        KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
            .apply { initialize(builder.build()) }
            .generateKeyPair()
    }

    private fun deviceInfo(): Map<String, Any> {
        ensureKey()
        val publicKey = keyStore().getCertificate(KEY_ALIAS).publicKey as ECPublicKey
        return mapOf(
            "publicKey" to mapOf(
                "kty" to "EC",
                "crv" to "P-256",
                "x" to base64Url(unsigned32(publicKey.w.affineX.toByteArray())),
                "y" to base64Url(unsigned32(publicKey.w.affineY.toByteArray())),
            ),
            "name" to "${Build.MANUFACTURER} ${Build.MODEL}".trim().take(60),
            "platform" to "android",
        )
    }

    private fun sign(message: String): String {
        ensureKey()
        val privateKey = keyStore().getKey(KEY_ALIAS, null) as PrivateKey
        val derSignature = Signature.getInstance("SHA256withECDSA").run {
            initSign(privateKey)
            update(message.toByteArray(Charsets.UTF_8))
            sign()
        }
        return base64Url(derToRaw(derSignature))
    }

    private fun deleteKey() {
        val store = keyStore()
        if (store.containsAlias(KEY_ALIAS)) store.deleteEntry(KEY_ALIAS)
    }

    private fun unsigned32(value: ByteArray): ByteArray {
        val unsigned = if (value.size > 32 && value[0].toInt() == 0) value.copyOfRange(1, value.size) else value
        require(unsigned.size <= 32) { "Invalid P-256 coordinate" }
        return ByteArray(32 - unsigned.size) + unsigned
    }

    private fun derToRaw(der: ByteArray): ByteArray {
        var offset = 0
        require(der[offset++].toInt() and 0xff == 0x30) { "Invalid ECDSA sequence" }
        val sequenceLength = readLength(der, offset)
        offset = sequenceLength.second
        require(sequenceLength.first == der.size - offset) { "Invalid ECDSA sequence length" }
        require(der[offset++].toInt() and 0xff == 0x02) { "Missing ECDSA r" }
        val rLength = readLength(der, offset)
        offset = rLength.second
        val r = der.copyOfRange(offset, offset + rLength.first)
        offset += rLength.first
        require(der[offset++].toInt() and 0xff == 0x02) { "Missing ECDSA s" }
        val sLength = readLength(der, offset)
        offset = sLength.second
        val s = der.copyOfRange(offset, offset + sLength.first)
        return unsigned32(r) + unsigned32(s)
    }

    private fun readLength(data: ByteArray, start: Int): Pair<Int, Int> {
        var offset = start
        val first = data[offset++].toInt() and 0xff
        if (first < 0x80) return first to offset
        val byteCount = first and 0x7f
        require(byteCount in 1..2) { "Unsupported DER length" }
        var length = 0
        repeat(byteCount) { length = (length shl 8) or (data[offset++].toInt() and 0xff) }
        return length to offset
    }

    private fun base64Url(data: ByteArray): String =
        Base64.getUrlEncoder().withoutPadding().encodeToString(data)
}
