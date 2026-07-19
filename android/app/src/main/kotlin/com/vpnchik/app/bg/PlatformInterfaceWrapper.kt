package com.vpnchik.app.bg

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Process
import android.util.Log
import androidx.annotation.RequiresApi
import com.vpnchik.app.Application
import com.hiddify.core.libbox.InterfaceUpdateListener
import com.hiddify.core.libbox.Libbox
import com.hiddify.core.libbox.NetworkInterfaceIterator
import com.hiddify.core.libbox.PlatformInterface
import com.hiddify.core.libbox.StringIterator
import com.hiddify.core.libbox.TunOptions
import com.hiddify.core.libbox.WIFIState
import java.net.Inet6Address
import java.net.InetSocketAddress
import java.net.InterfaceAddress
import java.net.NetworkInterface
import java.util.Enumeration
import com.hiddify.core.libbox.NetworkInterface as LibboxNetworkInterface



import android.system.OsConstants
import com.hiddify.core.libbox.ConnectionOwner
import com.hiddify.core.libbox.LocalDNSTransport
import java.security.KeyStore
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

interface PlatformInterfaceWrapper : PlatformInterface {
    // Disable auto-detect to avoid getInterfaces() crash on Android 16+
    override fun usePlatformAutoDetectInterfaceControl(): Boolean = false

    override fun autoDetectInterfaceControl(fd: Int) {
    }

    override fun openTun(options: TunOptions): Int {
        error("invalid argument")
    }

    override fun useProcFS(): Boolean =  Build.VERSION.SDK_INT < Build.VERSION_CODES.Q

    @RequiresApi(Build.VERSION_CODES.Q)
    override fun findConnectionOwner(
        ipProtocol: Int,
        sourceAddress: String,
        sourcePort: Int,
        destinationAddress: String,
        destinationPort: Int,
    ): ConnectionOwner {
        try {
            val uid =
                Application.connectivity.getConnectionOwnerUid(
                    ipProtocol,
                    InetSocketAddress(sourceAddress, sourcePort),
                    InetSocketAddress(destinationAddress, destinationPort),
                )
//            if (uid == Process.INVALID_UID)error("android: connection owner not found")

            val owner = ConnectionOwner()
            owner.userId = uid
            if (uid!=Process.INVALID_UID) {
                val packages = Application.packageManager.getPackagesForUid(uid)
                owner.userName = packages?.firstOrNull() ?: ""
                owner.androidPackageName = owner.userName
            }
            return owner
        } catch (e: Exception) {
            Log.e("PlatformInterface", "getConnectionOwnerUid", e)
            e.printStackTrace(System.err)
            throw e
        }
    }

    override fun startDefaultInterfaceMonitor(listener: InterfaceUpdateListener) {
        DefaultNetworkMonitor.setListener(listener)
    }

    override fun closeDefaultInterfaceMonitor(listener: InterfaceUpdateListener) {
        DefaultNetworkMonitor.setListener(null)
    }

    override fun getInterfaces(): NetworkInterfaceIterator {
        // Return empty on Android 16+ — gomobile JNI refs are broken
        // regardless of implementation. sing-box routes work without this.
        return InterfaceArray(emptyList<LibboxNetworkInterface>().iterator())
    }

    override fun underNetworkExtension(): Boolean = false

    override fun includeAllNetworks(): Boolean = false

    override fun clearDNSCache() {
    }

    override fun readWIFIState(): WIFIState? {
        @Suppress("DEPRECATION")
        val wifiInfo =
            Application.wifiManager.connectionInfo ?: return null
        var ssid = wifiInfo.ssid
        if (ssid == "<unknown ssid>") {
            return WIFIState("", "")
        }
        if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
            ssid = ssid.substring(1, ssid.length - 1)
        }
        return WIFIState(ssid, wifiInfo.bssid)
    }

    override fun localDNSTransport(): LocalDNSTransport? = LocalResolver

    @OptIn(ExperimentalEncodingApi::class)
    override fun systemCertificates(): StringIterator {
        val certificates = mutableListOf<String>()
        val keyStore = KeyStore.getInstance("AndroidCAStore")
        if (keyStore != null) {
            keyStore.load(null, null)
            val aliases = keyStore.aliases()
            while (aliases.hasMoreElements()) {
                val cert = keyStore.getCertificate(aliases.nextElement())
                certificates.add(
                    "-----BEGIN CERTIFICATE-----\n" + Base64.encode(cert.encoded) + "\n-----END CERTIFICATE-----",
                )
            }
        }
        return StringArray(certificates.iterator())
    }

    private class InterfaceArray(private val iterator: Iterator<LibboxNetworkInterface>) : NetworkInterfaceIterator {
        override fun hasNext(): Boolean = iterator.hasNext()

        override fun next(): LibboxNetworkInterface = iterator.next()
    }

    class StringArray(private val iterator: Iterator<String>) : StringIterator {
        override fun len(): Int {
            // not used by core
            return 0
        }

        override fun hasNext(): Boolean = iterator.hasNext()

        override fun next(): String = iterator.next()
    }

    private fun InterfaceAddress.toPrefix(): String = if (address is Inet6Address) {
        "${Inet6Address.getByAddress(address.address).hostAddress}/$networkPrefixLength"
    } else {
        "${address.hostAddress}/$networkPrefixLength"
    }

    private val NetworkInterface.flags: Int
        @SuppressLint("SoonBlockedPrivateApi")
        get() {
            val getFlagsMethod = NetworkInterface::class.java.getDeclaredMethod("getFlags")
            return getFlagsMethod.invoke(this) as Int
        }
}