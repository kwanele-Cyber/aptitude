enum SkillLevel {
  beginner,
  intermediate,
  expert;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.expert:
        return 'Expert';
    }
  }
}

enum SkillFormat {
  online,
  inPerson,
  hybrid;

  String get displayName {
    switch (this) {
      case SkillFormat.online:
        return 'Online';
      case SkillFormat.inPerson:
        return 'In-person';
      case SkillFormat.hybrid:
        return 'Hybrid';
    }
  }
}
