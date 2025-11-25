# 🐴 RideUp - Application Mobile Équestre

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Application mobile professionnelle pour cavaliers permettant de suivre les activités équestres et la santé des chevaux.

## 📱 Fonctionnalités

### 🔐 Authentification
- Inscription / Connexion par email et mot de passe
- Connexion avec Google
- Connexion avec Apple
- Réinitialisation du mot de passe
- Gestion de session sécurisée

### 🐎 Gestion des Chevaux
- Ajout de chevaux avec informations complètes (nom, race, âge, poids, taille)
- Upload de photos et documents
- Historique vétérinaire et soins
- Rappels automatiques pour les soins
- **Freemium** : 1 cheval gratuit, illimité en Premium

### 📍 Tracking GPS (Fonction Clé)
- Suivi GPS en temps réel (foreground + background)
- Calcul de distance, vitesse instantanée et moyenne
- Détection automatique des allures (pas / trot / galop)
- Altitude et dénivelé
- Enregistrement des parcours avec compression des points GPS
- Affichage sur carte avec polylines

### 📊 Statistiques & Analyses
- Distance totale par semaine / mois
- Vitesse maximale et moyenne
- Temps total à cheval
- Calories dépensées
- Charge de travail calculée
- Recommandations de repos (Premium)
- Graphiques interactifs

### 🏥 Santé & Bien-être
- Historique des événements de santé
- Suivi vétérinaire, maréchal-ferrant, vaccinations
- Calcul automatique des prochaines échéances
- Notifications push pour les rappels

### 📅 Planning
- Calendrier par cheval
- Événements d'entraînement, repos, soins
- Notifications programmées

### 💎 Premium
- Chevaux illimités
- Statistiques avancées
- Export PDF des activités
- Stockage illimité de documents
- Analyses santé avancées
- Recommandations de repos personnalisées

## 🏗️ Architecture

### Stack Technique

**Frontend:**
- Flutter 3.x / Dart 3.x
- Riverpod (state management)
- GoRouter (navigation)
- Freezed + JsonSerializable (models)
- Google Maps / Mapbox
- Clean Architecture

**Backend:**
- Supabase (Auth, Database, Storage, Edge Functions)
- PostgreSQL avec Row Level Security (RLS)
- Firebase Cloud Messaging (notifications)

**Services:**
- GPS tracking avec Geolocator
- In-app purchases (iOS & Android)
- Image compression
- PDF generation

### Structure du Projet

```
lib/
├── core/
│   ├── config/          # Configuration (env, constants)
│   ├── theme/           # Thèmes dark/light
│   ├── utils/           # Utilitaires (formatters, validators)
│   ├── constants/       # Constantes de l'app
│   └── error/           # Gestion d'erreurs
├── features/
│   ├── auth/            # Authentification
│   ├── horses/          # Gestion des chevaux
│   ├── tracking/        # Tracking GPS
│   ├── stats/           # Statistiques
│   ├── health/          # Santé
│   ├── planning/        # Planning
│   ├── documents/       # Documents
│   ├── premium/         # Abonnement
│   └── home/            # Navigation principale
├── services/            # Services (GPS, notifications, sync)
├── widgets/             # Widgets réutilisables
├── routes/              # Configuration des routes
└── main.dart            # Point d'entrée

supabase/
├── schema.sql           # Schéma de base de données
└── functions/           # Edge Functions
    ├── generate_activity_pdf/
    ├── compute_recovery_recommendation/
    └── scheduled_notifications_dispatcher/
```

## 🚀 Installation

### Prérequis

1. **Flutter SDK** (3.x ou supérieur)
   ```bash
   flutter --version
   ```

2. **Compte Supabase**
   - Créer un projet sur [supabase.com](https://supabase.com)
   - Exécuter le fichier `supabase/schema.sql` dans l'éditeur SQL

3. **Firebase Project** (pour FCM)
   - Créer un projet sur [Firebase Console](https://console.firebase.google.com)
   - Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)

4. **Google Maps API Key**
   - Activer Google Maps SDK sur [Google Cloud Console](https://console.cloud.google.com)

5. **Comptes développeur** (optionnel)
   - Apple Developer Account (pour Apple Sign-in et App Store)
   - Google Cloud Project (pour Google Sign-in)

### Configuration

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd RideUp
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer les variables d'environnement**
   
   Copier `.env.example` vers `.env` et remplir les valeurs :
   ```bash
   cp .env.example .env
   ```

   Éditer `.env` :
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   GOOGLE_MAPS_API_KEY_ANDROID=your-android-key
   GOOGLE_MAPS_API_KEY_IOS=your-ios-key
   ```

4. **Configurer Firebase**
   
   - Placer `google-services.json` dans `android/app/`
   - Placer `GoogleService-Info.plist` dans `ios/Runner/`

5. **Générer le code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Lancer l'application

**Mode développement:**
```bash
flutter run
```

**Build Android:**
```bash
flutter build apk --release
```

**Build iOS:**
```bash
flutter build ios --release
```

## 🗄️ Base de Données Supabase

### Tables Principales

- `users` - Profils utilisateurs (plan free/premium)
- `horses` - Informations sur les chevaux
- `activities` - Activités de tracking
- `activity_points` - Points GPS des activités
- `health_events` - Événements de santé
- `documents` - Documents et fichiers
- `planning` - Événements du calendrier
- `notifications` - Notifications programmées

### Sécurité

- **Row Level Security (RLS)** activé sur toutes les tables
- Policies strictes par `user_id`
- Storage sécurisé pour photos et documents

### Edge Functions

1. **generate_activity_pdf**
   - Génère un PDF récapitulatif d'une activité
   - Endpoint: `/functions/v1/generate_activity_pdf`

2. **compute_recovery_recommendation**
   - Calcule le temps de repos recommandé
   - Analyse la charge de travail récente
   - Endpoint: `/functions/v1/compute_recovery_recommendation`

3. **scheduled_notifications_dispatcher**
   - Envoie les notifications programmées via FCM
   - Exécuté par cron job (toutes les 5 minutes)

## 🎨 UI/UX

### Design System

- **Couleurs principales** : Bleu nuit (#1E3A5F) et Vert (#2ECC71)
- **Thèmes** : Dark mode et Light mode
- **Typographie** : Inter (Google Fonts)
- **Animations** : Transitions fluides et micro-animations
- **Icônes** : Material Icons minimalistes

### Écrans Principaux

1. **Authentification** - Login, Register, Forgot Password
2. **Activités** - Liste des balades avec stats
3. **Chevaux** - Gestion des chevaux
4. **Tracking** - Carte en temps réel pendant l'activité
5. **Stats** - Graphiques et analyses
6. **Planning** - Calendrier
7. **Profil** - Paramètres et abonnement

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter_riverpod: ^2.5.1        # State management
  go_router: ^14.0.2              # Navigation
  supabase_flutter: ^2.3.4        # Backend
  geolocator: ^11.0.0             # GPS
  google_maps_flutter: ^2.5.3     # Cartes
  firebase_messaging: ^14.7.10    # Notifications
  freezed: ^2.4.7                 # Models immutables
  fl_chart: ^0.66.2               # Graphiques
  in_app_purchase: ^3.1.13        # Achats in-app
```

## 🔧 Services

### GPS Service
- Tracking en temps réel avec `geolocator`
- Calcul de distance avec formule de Haversine
- Détection automatique des allures basée sur la vitesse
- Compression des points GPS pour optimiser le stockage
- Mode background pour continuer le tracking

### Notification Service
- Firebase Cloud Messaging
- Notifications locales
- Notifications programmées
- Deep linking vers les écrans appropriés

### Sync Service
- Mode offline complet
- Synchronisation automatique
- Résolution de conflits
- Cache local avec Hive

### Subscription Service
- In-app purchases iOS et Android
- Gestion des abonnements
- Vérification du statut Premium
- Restauration des achats

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Coverage
flutter test --coverage
```

## 📱 Déploiement

### App Store (iOS)

1. Configurer les certificats et provisioning profiles
2. Mettre à jour `ios/Runner/Info.plist` avec les permissions
3. Build et archive dans Xcode
4. Upload vers App Store Connect

### Google Play (Android)

1. Générer le keystore
2. Configurer `android/key.properties`
3. Build l'APK/AAB
   ```bash
   flutter build appbundle --release
   ```
4. Upload vers Google Play Console

## 🔐 Permissions

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>RideUp a besoin de votre position pour enregistrer vos balades</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>RideUp a besoin de votre position en arrière-plan pour continuer l'enregistrement</string>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

## 🐛 Debugging

### Logs Supabase
```dart
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  print('Auth state: ${data.event}');
});
```

### Logs GPS
```dart
gpsService.startTracking(
  onNewPoint: (point) => print('New point: ${point.lat}, ${point.lng}'),
  onStatsUpdate: (stats) => print('Stats: $stats'),
);
```

## 📄 License

MIT License - voir le fichier [LICENSE](LICENSE)

## 👥 Contribution

Les contributions sont les bienvenues ! Veuillez :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub


## 🎯 Roadmap

- [ ] Intégration Apple Watch
- [ ] Partage social des activités
- [ ] Challenges et compétitions
- [ ] Mode hors ligne complet
- [ ] Export vers Strava
- [ ] Analyses IA des performances

---

**Développé avec ❤️ pour la communauté équestre**
