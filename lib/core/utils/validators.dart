class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }
  
  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    return null;
  }
  
  // Confirm Password Validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  // Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
  
  // Horse Name Validation
  static String? validateHorseName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom du cheval est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    if (value.length > 50) {
      return 'Le nom ne peut pas dépasser 50 caractères';
    }
    
    return null;
  }
  
  // Age Validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'âge est requis';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'L\'âge doit être un nombre';
    }
    
    if (age < 0 || age > 50) {
      return 'L\'âge doit être entre 0 et 50 ans';
    }
    
    return null;
  }
  
  // Weight Validation
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le poids est requis';
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Le poids doit être un nombre';
    }
    
    if (weight < 100 || weight > 1500) {
      return 'Le poids doit être entre 100 et 1500 kg';
    }
    
    return null;
  }
  
  // Height Validation
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'La taille est requise';
    }
    
    final height = double.tryParse(value);
    if (height == null) {
      return 'La taille doit être un nombre';
    }
    
    if (height < 50 || height > 250) {
      return 'La taille doit être entre 50 et 250 cm';
    }
    
    return null;
  }
  
  // Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }
  
  // URL Validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL invalide';
    }
    
    return null;
  }
  
  // Numeric Validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName doit être un nombre';
    }
    
    return null;
  }
  
  // Min Length Validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }
    
    return null;
  }
  
  // Max Length Validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }
    
    return null;
  }
  
  // Range Validation
  static String? validateRange(String? value, double min, double max, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre';
    }
    
    if (number < min || number > max) {
      return '$fieldName doit être entre $min et $max';
    }
    
    return null;
  }
}
