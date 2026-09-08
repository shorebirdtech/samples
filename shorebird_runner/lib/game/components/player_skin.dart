enum PlayerSkin { blueBird, goldPhoenix, emeraldFalcon, violetRaven }

extension PlayerSkinDetails on PlayerSkin {
  String get displayName {
    switch (this) {
      case PlayerSkin.blueBird:
        return 'Shorebird Dev';
      case PlayerSkin.goldPhoenix:
        return 'Frontend Ninja';
      case PlayerSkin.emeraldFalcon:
        return 'Fullstack Hero';
      case PlayerSkin.violetRaven:
        return 'Bug Hunter';
    }
  }

  String get roleTitle {
    switch (this) {
      case PlayerSkin.blueBird:
        return 'CodePush Specialist';
      case PlayerSkin.goldPhoenix:
        return 'UI / Flutter Architect';
      case PlayerSkin.emeraldFalcon:
        return 'Fullstack Hacker';
      case PlayerSkin.violetRaven:
        return 'QA Bug Terminator';
    }
  }

  String get emoji {
    switch (this) {
      case PlayerSkin.blueBird:
        return '👨‍💻';
      case PlayerSkin.goldPhoenix:
        return '🧑‍💻';
      case PlayerSkin.emeraldFalcon:
        return '⚡';
      case PlayerSkin.violetRaven:
        return '👾';
    }
  }
}
