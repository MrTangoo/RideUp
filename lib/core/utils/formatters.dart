import 'package:intl/intl.dart';

class Formatters {
  // Distance Formatting
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }
  
  // Speed Formatting
  static String formatSpeed(double metersPerSecond) {
    final kmh = metersPerSecond * 3.6;
    return '${kmh.toStringAsFixed(1)} km/h';
  }
  
  // Duration Formatting
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  // Detailed Duration Formatting
  static String formatDetailedDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // Date and Time Formatting
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // Time Formatting
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  // Relative Time Formatting
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
  
  // Calories Formatting
  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} kcal';
  }
  
  // Weight Formatting
  static String formatWeight(double kg) {
    return '${kg.toStringAsFixed(0)} kg';
  }
  
  // Height Formatting (for horses)
  static String formatHeight(double cm) {
    return '${cm.toStringAsFixed(0)} cm';
  }
  
  // Age Formatting
  static String formatAge(int years) {
    return '$years an${years > 1 ? 's' : ''}';
  }
  
  // Workload Formatting
  static String formatWorkload(double workload) {
    if (workload < 30) {
      return 'Léger';
    } else if (workload < 60) {
      return 'Modéré';
    } else if (workload < 80) {
      return 'Intense';
    } else {
      return 'Très intense';
    }
  }
  
  // Gait Formatting
  static String formatGait(double speedKmh) {
    if (speedKmh < 7.0) {
      return 'Pas';
    } else if (speedKmh < 15.0) {
      return 'Trot';
    } else {
      return 'Galop';
    }
  }
  
  // File Size Formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  // Number Formatting with Locale
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(number);
  }
  
  // Decimal Formatting
  static String formatDecimal(double number, int decimals) {
    return number.toStringAsFixed(decimals);
  }
}
