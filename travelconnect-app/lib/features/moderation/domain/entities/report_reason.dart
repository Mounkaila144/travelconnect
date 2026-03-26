enum ReportReason {
  spam,
  offensive,
  falseInfo,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.offensive:
        return 'Contenu offensant';
      case ReportReason.falseInfo:
        return 'Information fausse';
      case ReportReason.other:
        return 'Autre';
    }
  }

  String get apiValue {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.offensive:
        return 'offensive';
      case ReportReason.falseInfo:
        return 'false_info';
      case ReportReason.other:
        return 'other';
    }
  }
}
