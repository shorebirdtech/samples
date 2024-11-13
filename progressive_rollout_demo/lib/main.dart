import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

const groupKey = 'groupNumber';
const firestoreCollectionName = 'rollouts';
const firebaseDocumentName = 'rollouts';

/// Assigns a random group number (1-100) to the user if one has not already
/// been assigned.
Future<void> assignGroupNumberIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(groupKey)) {
    final groupNumber = Random().nextInt(100) + 1;
    await prefs.setInt(groupKey, groupNumber);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await assignGroupNumberIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _updater = ShorebirdUpdater();

  int? _groupNumber;

  /// Returns the current release version (e.g., 1.0.0+1).
  Future<String> _releaseVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  /// Fetches the rollout percentage for the current release version
  /// (e.g., 1.0.0+1) from Firestore.
  ///
  /// Shorebird employees can view the Firestore data in the console at:
  /// https://console.firebase.google.com/u/0/project/progressive-rollout-demo/firestore/databases/-default-/data/~2Frollouts~2Frollouts
  Future<int?> _fetchRolloutPercentage() async {
    final collection = await FirebaseFirestore.instance
        .collection(firestoreCollectionName)
        .get();
    final releaseVersion = await _releaseVersion();
    return collection.docs.first.data()[releaseVersion] as int?;
  }

  /// Determines the update track (beta or stable) based on the group number
  /// and rollout percentage. If a user's group number is less than or equal to
  /// the rollout percentage, they are assigned to the beta track. Otherwise,
  /// they are assigned to the stable track. If there is no rollout percentage
  /// for the current release version, all users are on the stable track.
  Future<UpdateTrack> _updateTrack() async {
    // If we haven't set a group number yet, assume we're in the stable track.
    // This should never happen.
    if (_groupNumber == null) return UpdateTrack.stable;

    final rolloutPercentage = await _fetchRolloutPercentage();

    // If there is no rollout percentage, all users are on the stable track.
    if (rolloutPercentage == null) return UpdateTrack.stable;

    // If the user's group number is less than or equal to the rollout
    // percentage, they are on the beta track. For example:
    // - if the rollout percentage is 25%, users with group numbers 1-25 are on
    //   the beta track, and the other 75% are on the stable track.
    // - if the rollout percentage is 100%, all users are on the beta track.
    return _groupNumber! <= rolloutPercentage
        ? UpdateTrack.beta
        : UpdateTrack.stable;
  }

  Future<void> _checkForUpdate() async {
    final track = await _updateTrack();
    final updateResult = await _updater.checkForUpdate(track: track);
    if (updateResult == UpdateStatus.outdated) {
      await _updater.update(track: track);
    }
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _groupNumber = prefs.getInt(groupKey);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Phased Rollout Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Group number: ${_groupNumber ?? 'unknown'}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkForUpdate,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
