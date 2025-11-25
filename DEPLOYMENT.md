# 🚀 Guide de Déploiement RideUp

Ce guide vous accompagne dans le déploiement de RideUp sur l'App Store (iOS) et Google Play (Android).

## 📋 Prérequis

### Comptes Développeur
- [ ] Compte Apple Developer (99$/an)
- [ ] Compte Google Play Console (25$ unique)

### Outils Nécessaires
- [ ] Flutter SDK 3.x installé
- [ ] Xcode (pour iOS, macOS uniquement)
- [ ] Android Studio
- [ ] Compte Supabase configuré
- [ ] Projet Firebase configuré

## 🗄️ Configuration Supabase

### 1. Créer le Projet Supabase

1. Aller sur [supabase.com](https://supabase.com)
2. Créer un nouveau projet
3. Noter l'URL et l'anon key

### 2. Exécuter le Schéma SQL

1. Ouvrir l'éditeur SQL dans Supabase Dashboard
2. Copier le contenu de `supabase/schema.sql`
3. Exécuter le script
4. Vérifier que toutes les tables sont créées

### 3. Déployer les Edge Functions

```bash
# Installer Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Deploy functions
supabase functions deploy generate_activity_pdf
supabase functions deploy compute_recovery_recommendation
supabase functions deploy scheduled_notifications_dispatcher
```

### 4. Configurer le Cron Job

Dans Supabase Dashboard > Edge Functions :
- Sélectionner `scheduled_notifications_dispatcher`
- Ajouter un cron trigger : `*/5 * * * *` (toutes les 5 minutes)

### 5. Configurer Storage

Les buckets `photos` et `documents` sont créés automatiquement par le schéma SQL.
Vérifier dans Storage > Buckets.

## 🔥 Configuration Firebase

### 1. Créer le Projet Firebase

1. Aller sur [console.firebase.google.com](https://console.firebase.google.com)
2. Créer un nouveau projet
3. Activer Firebase Cloud Messaging

### 2. Configuration Android

1. Ajouter une app Android dans Firebase
2. Package name : `com.rideup.rideup`
3. Télécharger `google-services.json`
4. Placer dans `android/app/`

### 3. Configuration iOS

1. Ajouter une app iOS dans Firebase
2. Bundle ID : `com.rideup.rideup`
3. Télécharger `GoogleService-Info.plist`
4. Placer dans `ios/Runner/`

### 4. Activer APNs (iOS)

1. Aller dans Project Settings > Cloud Messaging
2. Upload APNs Authentication Key (depuis Apple Developer)

## 🗺️ Configuration Google Maps

### 1. Créer les API Keys

1. Aller sur [console.cloud.google.com](https://console.cloud.google.com)
2. Activer Google Maps SDK for Android
3. Activer Google Maps SDK for iOS
4. Créer 2 API keys (une pour Android, une pour iOS)

### 2. Restreindre les Keys

**Android Key:**
- Type : Android apps
- Ajouter le package name et SHA-1

**iOS Key:**
- Type : iOS apps
- Ajouter le Bundle ID

### 3. Ajouter aux Fichiers de Config

Mettre à jour `.env` avec les keys.

## 📱 Build Android

### 1. Générer le Keystore

```bash
keytool -genkey -v -keystore ~/rideup-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rideup
```

### 2. Créer key.properties

Créer `android/key.properties` :

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=rideup
storeFile=/path/to/rideup-release-key.jks
```

### 3. Mettre à Jour build.gradle

Le fichier `android/app/build.gradle` doit contenir :

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. Build l'APK/AAB

```bash
# APK
flutter build apk --release

# AAB (recommandé pour Play Store)
flutter build appbundle --release
```

### 5. Upload sur Google Play Console

1. Créer une app dans Play Console
2. Remplir les informations (titre, description, screenshots)
3. Upload l'AAB dans Production > Releases
4. Soumettre pour review

## 🍎 Build iOS

### 1. Configurer Xcode

1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Sélectionner le projet Runner
3. Signing & Capabilities :
   - Team : Sélectionner votre équipe
   - Bundle Identifier : `com.rideup.rideup`
   - Signing : Automatic

### 2. Configurer les Capabilities

Ajouter les capabilities suivantes :
- Background Modes
  - Location updates
  - Background fetch
  - Remote notifications
- Push Notifications
- Sign in with Apple

### 3. Configurer les Permissions

Vérifier que `Info.plist` contient toutes les permissions (déjà fait).

### 4. Build et Archive

1. Dans Xcode : Product > Archive
2. Une fois l'archive créée, cliquer "Distribute App"
3. Choisir "App Store Connect"
4. Upload

### 5. App Store Connect

1. Créer une app dans [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Remplir les métadonnées
3. Ajouter screenshots (6.5", 5.5" pour iPhone)
4. Sélectionner le build uploadé
5. Soumettre pour review

## 📝 Métadonnées App Store / Play Store

### Titre
RideUp - Suivi Équestre

### Description Courte (80 caractères)
Suivez vos balades à cheval avec GPS, stats et santé du cheval

### Description Complète

```
🐴 RideUp - L'application indispensable pour tous les cavaliers !

Suivez vos activités équestres avec précision grâce au tracking GPS, gérez la santé de vos chevaux et analysez vos performances.

🎯 FONCTIONNALITÉS PRINCIPALES

📍 TRACKING GPS
• Enregistrement précis de vos parcours
• Distance, vitesse, dénivelé en temps réel
• Détection automatique des allures (pas, trot, galop)
• Historique complet de vos balades

🐎 GESTION DES CHEVAUX
• Fiches complètes pour chaque cheval
• Photos et documents
• Suivi vétérinaire et maréchal-ferrant
• Rappels automatiques

📊 STATISTIQUES
• Analyses détaillées de vos performances
• Graphiques de progression
• Calcul des calories dépensées
• Recommandations de repos

🏥 SANTÉ & BIEN-ÊTRE
• Historique médical complet
• Calendrier des soins
• Notifications pour les rappels
• Suivi personnalisé

💎 VERSION PREMIUM
• Chevaux illimités
• Statistiques avancées
• Export PDF
• Analyses santé détaillées

Téléchargez RideUp et transformez vos balades à cheval !
```

### Mots-clés (App Store)
cheval,équitation,gps,tracking,balade,cavalier,équestre,stats,santé

### Catégories
- Principale : Santé et forme
- Secondaire : Sports

### Screenshots Requis

**iPhone 6.5" (obligatoire):**
- Écran de tracking GPS
- Liste des activités
- Fiche cheval
- Statistiques
- Planning

**iPhone 5.5" (obligatoire):**
- Mêmes screenshots redimensionnés

**iPad (optionnel):**
- Screenshots adaptés

## 🔒 Confidentialité

### Privacy Policy

Créer une politique de confidentialité incluant :
- Collecte de données de localisation
- Utilisation des données
- Stockage sécurisé
- Droits des utilisateurs

Héberger sur un site web et fournir l'URL dans les stores.

### Data Safety (Google Play)

Déclarer :
- Localisation : Précise, utilisée pour le tracking
- Photos : Stockage des photos de chevaux
- Informations personnelles : Email, nom

## ✅ Checklist Finale

### Avant Soumission
- [ ] Tester sur devices réels (iOS et Android)
- [ ] Vérifier toutes les permissions
- [ ] Tester le tracking GPS en conditions réelles
- [ ] Vérifier les achats in-app (sandbox)
- [ ] Tester les notifications
- [ ] Vérifier le mode offline
- [ ] Tester Google/Apple Sign-in
- [ ] Screenshots de qualité
- [ ] Icône de l'app (1024x1024)
- [ ] Privacy Policy publiée
- [ ] Terms of Service publiés

### Post-Soumission
- [ ] Répondre aux questions de review
- [ ] Corriger les bugs signalés
- [ ] Préparer le marketing
- [ ] Configurer les analytics

## 🐛 Problèmes Courants

### iOS

**Problème : Background location ne fonctionne pas**
- Vérifier que Background Modes > Location updates est activé
- Vérifier les permissions dans Info.plist

**Problème : Apple Sign-in échoue**
- Vérifier que Sign in with Apple capability est activée
- Vérifier le Bundle ID dans Apple Developer

### Android

**Problème : Google Maps ne s'affiche pas**
- Vérifier que l'API key est correcte
- Vérifier que le SHA-1 est ajouté dans Google Cloud Console

**Problème : Background location ne fonctionne pas**
- Vérifier les permissions dans AndroidManifest.xml
- Tester sur Android 10+ (restrictions plus strictes)

## 📊 Monitoring Post-Launch

### Analytics
- Installer Firebase Analytics
- Tracker les événements clés (tracking started, horse added, etc.)

### Crash Reporting
- Activer Firebase Crashlytics
- Monitorer les crashes

### Performance
- Monitorer la consommation batterie
- Optimiser le tracking GPS si nécessaire

## 🔄 Mises à Jour

### Processus de Release

1. Incrémenter la version dans `pubspec.yaml`
2. Mettre à jour le CHANGELOG
3. Build et test
4. Upload sur stores
5. Soumettre pour review

### Versioning

Format : `MAJOR.MINOR.PATCH+BUILD`
- MAJOR : Changements incompatibles
- MINOR : Nouvelles fonctionnalités
- PATCH : Corrections de bugs
- BUILD : Numéro de build

Exemple : `1.2.3+45`

---

**Bon déploiement ! 🚀**
