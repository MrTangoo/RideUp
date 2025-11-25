# 🚀 Guide de Démarrage Rapide - RideUp

## ⚡ Démarrage Rapide

### 1. Installer Flutter

Si Flutter n'est pas encore installé :

```bash
# Télécharger Flutter depuis https://flutter.dev/docs/get-started/install
# Ajouter Flutter au PATH
flutter doctor
```

### 2. Configurer les Variables d'Environnement

Créer un fichier `.env` à la racine du projet :

```bash
cp .env.example .env
```

Éditer `.env` avec vos valeurs :

```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-anon-key
GOOGLE_MAPS_API_KEY_ANDROID=votre-key-android
GOOGLE_MAPS_API_KEY_IOS=votre-key-ios
GOOGLE_CLIENT_ID_IOS=votre-client-id-ios
GOOGLE_CLIENT_ID_ANDROID=votre-client-id-android
FIREBASE_PROJECT_ID=votre-project-id
```

### 3. Installer les Dépendances

```bash
flutter pub get
```

### 4. Générer le Code

**IMPORTANT** : Générer les fichiers Freezed et Riverpod :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Cette commande génère tous les fichiers `.g.dart` et `.freezed.dart` nécessaires.

### 5. Configurer Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Aller dans SQL Editor
3. Copier et exécuter le contenu de `supabase/schema.sql`
4. Vérifier que toutes les tables sont créées

### 6. Configurer Firebase (pour les notifications)

1. Créer un projet sur [Firebase Console](https://console.firebase.google.com)
2. Ajouter une app Android :
   - Télécharger `google-services.json`
   - Placer dans `android/app/`
3. Ajouter une app iOS :
   - Télécharger `GoogleService-Info.plist`
   - Placer dans `ios/Runner/`

### 7. Lancer l'Application

```bash
# Sur émulateur/simulateur
flutter run

# Sur device physique
flutter run -d <device-id>
```

## 📱 Fonctionnalités Disponibles

### ✅ Complètement Implémenté

- **Authentification** : Email/password, Google, Apple Sign-in
- **Gestion des Chevaux** : Liste, détail, ajout/édition avec photos
- **Tracking GPS** : Carte en temps réel, stats live, détection allures
- **Statistiques** : Dashboard avec graphiques et analyses
- **Santé** : Timeline des événements, rappels
- **Planning** : Calendrier avec événements
- **Premium** : Écran d'abonnement

### 🔨 À Finaliser

- Génération des fichiers `.g.dart` et `.freezed.dart`
- Configuration des API keys
- Tests sur devices réels
- In-app purchases (implémentation native ou RevenueCat)

## 🐛 Problèmes Courants

### Erreur "No such file or directory" pour les fichiers .g.dart

**Solution** : Exécuter `flutter pub run build_runner build --delete-conflicting-outputs`

### Erreur Supabase "Invalid API key"

**Solution** : Vérifier que `.env` contient les bonnes valeurs et que le fichier est à la racine

### Google Maps ne s'affiche pas

**Solution** : 
- Vérifier que l'API key est correcte
- Activer Google Maps SDK dans Google Cloud Console
- Ajouter le SHA-1 pour Android

### Erreur de build iOS

**Solution** :
- Ouvrir `ios/Runner.xcworkspace` dans Xcode
- Configurer le signing avec votre équipe
- Vérifier que les capabilities sont activées

## 📚 Documentation Complète

Pour plus de détails, consulter :

- [README.md](README.md) - Documentation principale
- [DEPLOYMENT.md](DEPLOYMENT.md) - Guide de déploiement
- [walkthrough.md](file:///C:/Users/Maxime%20Derbigny/.gemini/antigravity/brain/11f25315-5b2b-4df2-a557-aff66b82b4d8/walkthrough.md) - Walkthrough complet

## 🎯 Prochaines Étapes

1. ✅ Générer le code avec build_runner
2. ✅ Configurer Supabase
3. ✅ Configurer Firebase
4. ✅ Tester sur émulateur
5. ⏳ Tester sur device réel
6. ⏳ Implémenter in-app purchases
7. ⏳ Déployer sur stores

---

**Bon développement ! 🐴**
