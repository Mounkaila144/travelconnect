String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'à l\'instant';
  } else if (difference.inMinutes < 60) {
    return 'il y a ${difference.inMinutes} min';
  } else if (difference.inHours < 24) {
    return 'il y a ${difference.inHours} h';
  } else if (difference.inDays < 30) {
    return 'il y a ${difference.inDays} j';
  } else {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }
}
