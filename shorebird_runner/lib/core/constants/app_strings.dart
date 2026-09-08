/// Central repository of all user-facing strings and labels in Shorebird Runner.
class AppStrings {
  AppStrings._();

  // App & Metadata
  static const String appTitle = 'Patch Rush — by Shorebird';
  static const String appTagline =
      'A Shorebird booth arcade game. Dodge bugs, collect patches, keep flying!';
  static const String shorebirdBrand = 'SHOREBIRD';
  static const String patchRush = 'PATCH RUSH';
  static const String appNameUpper = 'SHOREBIRD PATCH RUSH';

  // Navigation & Menus
  static const String menu = 'MENU';
  static const String backToMenu = 'BACK TO MENU';
  static const String leaveRoom = 'LEAVE ROOM';
  static const String quit = 'QUIT';
  static const String soloSprint = 'SOLO SPRINT';
  static const String soloSprintSubtitle =
      'Play solo, advance tiers, set your personal best record!';
  static const String boothTournament = 'BOOTH TOURNAMENT';
  static const String boothTournamentSubtitle =
      'Multiplayer room · Race live on the booth screen!';
  static const String boothBattle2P = '2-PLAYER BOOTH BATTLE';
  static const String boothBattle2PSubtitle =
      'Split-screen keyboard showdown on one laptop!';
  static const String howToPlay = 'HOW TO PLAY';
  static const String viewRules = 'GAME RULES';

  // Pilot Skins
  static const String selectYourPilot = 'SELECT YOUR PILOT';
  static const String pilotBlue = 'Blue Bird';
  static const String pilotGold = 'Gold Phoenix';
  static const String pilotNeon = 'Neon Cyber';
  static const String pilotFire = 'Flame Bird';

  // Solo & In-Game
  static const String score = 'SCORE';
  static const String highScore = 'HIGH SCORE';
  static const String patches = 'PATCHES';
  static const String plan = 'PLAN';
  static const String newRecord = '★ NEW HIGH SCORE RECORD! ★';
  static const String gameOver = 'RUN TERMINATED';
  static const String restart = 'PLAY AGAIN';
  static const String finalScore = 'Final Score';
  static const String tierReached = 'Tier Reached';
  static const String hotReloadActive = '🔥 HOT RELOAD INVINCIBLE!';
  static const String squashedBonus = '💥 SQUASHED!';
  static const String leapBonus = '🦘 LEAP!';
  static const String slideBonus = '⚡ SLIDE!';
  static const String patchCollected = '🐤 PATCH!';
  static const String patchMissed = '🐤 MISSED!';

  // Mobile Controls
  static const String left = 'LEFT';
  static const String mid = 'MID';
  static const String right = 'RIGHT';
  static const String jump = 'JUMP';
  static const String slide = 'SLIDE';

  // Tournament Lobby
  static const String tournamentTitle = 'TOURNAMENT RACE LOBBY';
  static const String hostRoom = 'CREATE RACE ROOM';
  static const String joinRoom = 'JOIN WITH CODE';
  static const String roomCode = 'ROOM CODE';
  static const String roomCodePrompt = 'Enter 4-letter room code:';
  static const String playerNamePrompt = 'Your Pilot Name:';
  static const String createAsHost = 'Host & Spectate Big Screen';
  static const String createAsPlayer = 'Host & Race as Player';
  static const String startingIn = 'STARTING IN';
  static const String startRace = 'START RACE';
  static const String waitingForHost = 'WAITING FOR HOST TO LAUNCH...';
  static const String waitingForPilots = 'Waiting for pilots to join...';
  static const String pilotsReady = 'PILOTS IN LOBBY';
  static const String scanQrPrompt = 'Scan to join on mobile:';
  static const String connectedToLobby = 'CONNECTED TO TOURNAMENT SERVER';
  static const String disconnectedFromLobby =
      'DISCONNECTED FROM TOURNAMENT SERVER';

  // Live Multiplayer Race
  static const String liveRace = 'LIVE RACE';
  static const String awaitingRaceCompletion = 'Awaiting race completion...';
  static const String runCrashed = '💥 RUN CRASHED';
  static const String spectating = 'SPECTATING';
  static const String liveUpdatesFooter =
      'Live updates as pilots dodge obstacles & collect patches • Podium appears upon match completion';

  // Podium
  static const String podiumTitle = 'BOOTH TOURNAMENT PODIUM';
  static const String savedToDatabase = 'SAVED TO BOOTH DATABASE';
  static const String rematchRace = 'REMATCH RACE';
  static const String waitingForRematch =
      'WAITING FOR ROOM OWNER TO REMATCH...';

  // Rules & Shorebird Messaging
  static const String rulesTitle = 'MISSION BRIEFING';
  static const String rulesSub =
      'Patch your apps instantly in production without app-store delays.';
  static const String rulesObstaclesTitle = 'AVOID RUNTIME ERRORS';
  static const String rulesObstaclesDesc =
      'Dodge barricades, bugs, and null checks on the production road.';
  static const String rulesHotReloadTitle = 'COLLECT HOT RELOAD POWERUPS';
  static const String rulesHotReloadDesc =
      'Glowing Shorebird patches grant invincible forcefield smash power!';
  static const String rulesTiersTitle = 'TIER PROGRESSION';
  static const String rulesTiersDesc =
      'Advance through Hobby, Pro, Business, and Enterprise plans with speed boosts!';

  // Booth Battle
  static const String p1 = 'PLAYER 1';
  static const String p2 = 'PLAYER 2';
  static const String vs = 'VS';
  static const String matchWinner = 'WINNER!';
  static const String matchTie = "IT'S A TIE!";
  static const String matchFinished = 'MATCH FINISHED';
  static const String rematch = 'REMATCH';

  // Lobby Extra Strings
  static const String playerCallsign = 'PLAYER CALLSIGN';
  static const String chooseYourPilot = 'CHOOSE YOUR PILOT';
  static const String createARoom = 'CREATE A ROOM';
  static const String enterRoomCode = 'ENTER ROOM CODE';
  static const String joinRace = 'JOIN RACE';
  static const String connectedDevelopers = 'CONNECTED DEVELOPERS';
  static const String getReady = 'GET READY!';
  static const String changeServer = 'Change Server';

  // Start Menu Extra Strings
  static const String roadmapTitle = 'STAGE PROGRESSION ROADMAP';
  static const String instantUpdates = 'INSTANT OTA UPDATES FOR FLUTTER';
  static const String codePush = 'CODE PUSH';
}
