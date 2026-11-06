import '../models/scene.dart';
import '../services/voice_service.dart';
import 'builtin_scenes.dart';

/// `--dart-define=COBI_SCENE=...` decides whether the scene mode is in the
/// build. Empty (every App Store build): no scene card. `true`: the card
/// shows only once every word clip of the scene is bundled, so a silent
/// scene game never ships (council condition 16). `observation`: the card
/// shows without clips; only for the first observation round, where a grown-up
/// says the words, and never for the App Store.
const String sceneFlag = String.fromEnvironment('COBI_SCENE');

/// Whether this build carries the scene mode at all.
bool get sceneModeBuilt => sceneFlag == 'true' || sceneFlag == 'observation';

/// The card rule on its own, for tests.
bool sceneCardAllowed(String flag, {required bool clipsBundled}) =>
    flag == 'observation' || (flag == 'true' && clipsBundled);

/// Whether the home screen shows the scene card for [scene].
Future<bool> sceneCardVisible({SceneDefinition scene = gardenScene}) async {
  if (!sceneModeBuilt) return false;
  final clips = sceneFlag == 'true' && await VoiceService().hasAll(scene.clipPaths());
  return sceneCardAllowed(sceneFlag, clipsBundled: clips);
}
