String timeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  
  final isFuture = difference.isNegative;

  
  final diff = difference.abs();

  if (diff.inSeconds < 60) {
    return isFuture ? 'Незабаром' : 'Щойно';
  } else if (diff.inMinutes < 60) {
    return isFuture
        ? 'Через ${diff.inMinutes} хв'
        : '${diff.inMinutes} хв тому';
  } else if (diff.inHours < 24) {
    return isFuture
        ? 'Через ${diff.inHours} год'
        : '${diff.inHours} год тому';
  } else if (diff.inDays < 7) {
    return isFuture
        ? 'Через ${diff.inDays} дн.'
        : '${diff.inDays} дн. тому';
  } else if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return isFuture
        ? 'Через $weeks тиж.'
        : '$weeks тиж. тому';
  } else if (diff.inDays < 365) {
    final months = (diff.inDays / 30).floor();
    return isFuture
        ? 'Через $months міс.'
        : '$months міс. тому';
  } else {
    final years = (diff.inDays / 365).floor();
    return isFuture
        ? 'Через $years р.'
        : '$years р. тому';
  }
}