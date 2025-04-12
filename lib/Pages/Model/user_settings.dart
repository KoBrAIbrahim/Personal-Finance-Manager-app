class UserSettings {
  final String theme;
  final bool notificationsEnabled;
  final String region;

  UserSettings({
    required this.theme,
    required this.notificationsEnabled,
    required this.region,
  });

  Map<String, dynamic> toMap() => {
        'theme': theme,
        'notificationsEnabled': notificationsEnabled,
        'region': region,
      };

  factory UserSettings.fromMap(Map<String, dynamic> map) => UserSettings(
        theme: map['theme'] ?? 'light',
        notificationsEnabled: map['notificationsEnabled'] ?? true,
        region: map['region'] ?? 'USD',
      );
}
