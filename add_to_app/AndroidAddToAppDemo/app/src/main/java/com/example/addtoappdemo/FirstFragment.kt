package com.example.addtoappdemo

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.example.addtoappdemo.databinding.FragmentFirstBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * A simple [Fragment] subclass as the default destination in the navigation.
 *
 * Modified to test multiple FlutterEngine behavior for Shorebird updater testing.
 */
class FirstFragment : Fragment() {

    private var _binding: FragmentFirstBinding? = null
    private val binding get() = _binding!!

    // Track engines we've created
    private val engines = mutableMapOf<String, FlutterEngine>()
    private var engineCounter = 0

    // Track FlutterEngineGroup for warmup testing
    private var engineGroup: FlutterEngineGroup? = null

    companion object {
        private const val TAG = "MultiEngineTest"
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        _binding = FragmentFirstBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Original button - launch Flutter using default (single engine) approach
        binding.buttonFirst.setOnClickListener {
            startActivity(
                FlutterActivity.createDefaultIntent(requireActivity().applicationContext)
            )
        }

        // Spin up a new engine and start an activity with it
        binding.buttonSpinUp.setOnClickListener {
            spinUpEngine()
        }

        // Destroy the most recently created engine WITHOUT letting it complete boot
        binding.buttonSpinDown.setOnClickListener {
            spinDownEngine()
        }

        // Destroy engine after it has started (simulates mid-boot destruction)
        binding.buttonSpinDownDelayed.setOnClickListener {
            spinUpEngineAndDestroyAfterDelay()
        }

        // Create and immediately destroy engine WITHOUT running Dart
        binding.buttonCreateDestroy.setOnClickListener {
            createAndImmediatelyDestroyEngine()
        }

        // Create FlutterEngineGroup for warmup (THIS SHOULD REPRODUCE THE BUG)
        binding.buttonEngineGroup.setOnClickListener {
            createEngineGroupForWarmup()
        }

        updateStatus()
    }

    /**
     * Creates a FlutterEngineGroup for "warmup" WITHOUT creating/running an engine.
     *
     * THIS SHOULD REPRODUCE THE BUG because:
     * 1. FlutterEngineGroup constructor calls ensureInitializationComplete()
     * 2. ensureInitializationComplete() → FlutterMain::Init() → shorebird_report_launch_start()
     * 3. FlutterEngineGroup does NOT create a Shell (no shorebird_report_launch_success())
     *
     * If the app is force-stopped after this, on next launch the patch will be marked bad
     * because currently_booting_patch is still set (never cleared by report_launch_success).
     *
     * Test steps:
     * 1. Install app with a Shorebird patch
     * 2. Click this button (creates EngineGroup, triggers report_launch_start)
     * 3. Force-stop the app (Settings → Apps → Force Stop, or adb shell am force-stop)
     * 4. Relaunch the app
     * 5. Check logs - patch should be incorrectly marked as "failed to boot"
     */
    private fun createEngineGroupForWarmup() {
        Log.i(TAG, "Creating FlutterEngineGroup for warmup (no engine created yet)")
        Log.i(TAG, "This triggers ensureInitializationComplete() → shorebird_report_launch_start()")
        Log.i(TAG, "But does NOT create a Shell → no shorebird_report_launch_success()")

        // Create the engine group - this calls ensureInitializationComplete()
        // which triggers shorebird_report_launch_start() but NOT report_launch_success()
        engineGroup = FlutterEngineGroup(requireContext())

        Log.i(TAG, "FlutterEngineGroup created. If you force-stop now and relaunch,")
        Log.i(TAG, "the patch should be incorrectly marked as bad!")

        updateStatus()
    }

    /**
     * Creates a FlutterEngine and immediately destroys it WITHOUT starting Dart code.
     *
     * NOTE: This probably WON'T reproduce the bug because both shorebird_report_launch_start()
     * and shorebird_report_launch_success() are called within the FlutterEngine constructor:
     * 1. ensureInitializationComplete() → FlutterMain::Init() → shorebird_report_launch_start()
     * 2. attachToJni() → Shell::Shell() → shorebird_report_launch_success()
     *
     * The bug would only manifest if the process is killed BETWEEN these two calls,
     * which is a very narrow window (likely < 100ms).
     *
     * To reproduce the bug, we'd need the process to be killed during engine construction.
     */
    private fun createAndImmediatelyDestroyEngine() {
        val engineId = "ghost_engine_${engineCounter++}"
        Log.i(TAG, "Creating FlutterEngine: $engineId (will destroy immediately)")

        // Create engine - this triggers BOTH:
        // 1. FlutterJNI.init() → ConfigureShorebird() → shorebird_report_launch_start()
        // 2. attachToJni() → Shell constructor → shorebird_report_launch_success()
        val engine = FlutterEngine(requireContext())

        // By this point, BOTH start and success have been called within the constructor.
        // So destroying here won't leave currently_booting_patch set.
        Log.i(TAG, "Destroying engine $engineId immediately (no Dart execution)")
        engine.destroy()

        Log.i(TAG, "Ghost engine $engineId created and destroyed")
        updateStatus()
    }

    private fun spinUpEngine() {
        val engineId = "engine_${engineCounter++}"
        Log.i(TAG, "Creating FlutterEngine: $engineId")

        val engine = FlutterEngine(requireContext())

        // Start executing Dart code
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // Cache the engine so FlutterActivity can use it
        FlutterEngineCache.getInstance().put(engineId, engine)
        engines[engineId] = engine

        Log.i(TAG, "Engine $engineId created and cached. Starting FlutterActivity...")

        // Start a FlutterActivity using this cached engine
        startActivity(
            FlutterActivity
                .withCachedEngine(engineId)
                .build(requireContext())
        )

        updateStatus()
    }

    private fun spinDownEngine() {
        if (engines.isEmpty()) {
            Log.i(TAG, "No engines to destroy")
            return
        }

        // Get the most recent engine
        val engineId = engines.keys.last()
        val engine = engines.remove(engineId)

        Log.i(TAG, "Destroying engine: $engineId (without waiting for boot completion)")

        // Remove from cache
        FlutterEngineCache.getInstance().remove(engineId)

        // Destroy the engine - this simulates the scenario where an engine
        // is destroyed mid-boot (after report_launch_start but before report_launch_success)
        engine?.destroy()

        Log.i(TAG, "Engine $engineId destroyed")
        updateStatus()
    }

    private fun spinUpEngineAndDestroyAfterDelay() {
        val engineId = "engine_${engineCounter++}"
        Log.i(TAG, "Creating FlutterEngine: $engineId (will destroy after 2 seconds)")

        val engine = FlutterEngine(requireContext())

        // Start executing Dart code
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // Cache and track
        FlutterEngineCache.getInstance().put(engineId, engine)
        engines[engineId] = engine

        // Start the activity
        startActivity(
            FlutterActivity
                .withCachedEngine(engineId)
                .build(requireContext())
        )

        // Schedule destruction after 2 seconds - this should be after report_launch_start
        // but potentially before report_launch_success, depending on timing
        binding.root.postDelayed({
            Log.i(TAG, "Delayed destruction of engine: $engineId")
            engines.remove(engineId)
            FlutterEngineCache.getInstance().remove(engineId)
            engine.destroy()
            Log.i(TAG, "Engine $engineId destroyed after delay")
            updateStatus()
        }, 2000)

        updateStatus()
    }

    private fun updateStatus() {
        val status = "Active engines: ${engines.size}\n" +
                     "Engine IDs: ${engines.keys.joinToString(", ")}\n" +
                     "Total created: $engineCounter\n" +
                     "EngineGroup: ${if (engineGroup != null) "CREATED (warmup mode)" else "none"}"
        binding.textStatus.text = status
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up all engines when fragment is destroyed
        engines.forEach { (id, engine) ->
            Log.i(TAG, "Cleaning up engine: $id")
            FlutterEngineCache.getInstance().remove(id)
            engine.destroy()
        }
        engines.clear()
    }
}
