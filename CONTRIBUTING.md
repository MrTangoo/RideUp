# 🛠️ Guide de Contribution

Merci de votre intérêt pour contribuer à RideUp ! Ce guide vous aidera à démarrer.

## 📋 Code of Conduct

En participant à ce projet, vous acceptez de respecter notre code de conduite :
- Soyez respectueux et inclusif
- Acceptez les critiques constructives
- Concentrez-vous sur ce qui est le mieux pour la communauté

## 🚀 Comment Contribuer

### Signaler un Bug

1. Vérifiez que le bug n'a pas déjà été signalé dans les Issues
2. Créez une nouvelle Issue avec le template "Bug Report"
3. Incluez :
   - Description claire du problème
   - Étapes pour reproduire
   - Comportement attendu vs actuel
   - Screenshots si applicable
   - Version de l'app et OS

### Proposer une Fonctionnalité

1. Créez une Issue avec le template "Feature Request"
2. Décrivez la fonctionnalité et son utilité
3. Attendez les retours avant de commencer le développement

### Soumettre du Code

1. **Fork** le repository
2. **Clone** votre fork
   ```bash
   git clone https://github.com/your-username/rideup.git
   ```
3. **Créer une branche** pour votre feature
   ```bash
   git checkout -b feature/amazing-feature
   ```
4. **Développer** votre fonctionnalité
5. **Tester** vos changements
6. **Commit** avec des messages clairs
   ```bash
   git commit -m "feat: add amazing feature"
   ```
7. **Push** vers votre fork
   ```bash
   git push origin feature/amazing-feature
   ```
8. **Créer une Pull Request**

## 📝 Standards de Code

### Dart/Flutter

- Suivre les [Effective Dart guidelines](https://dart.dev/guides/language/effective-dart)
- Utiliser `flutter analyze` avant de commit
- Formater avec `flutter format .`
- Commenter le code complexe
- Écrire des tests pour les nouvelles fonctionnalités

### Commits

Format : `type(scope): message`

Types :
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation
- `style`: Formatage
- `refactor`: Refactoring
- `test`: Tests
- `chore`: Maintenance

Exemples :
```
feat(tracking): add pause button during ride
fix(auth): resolve Google Sign-in crash on iOS
docs(readme): update installation instructions
```

### Architecture

- Respecter Clean Architecture
- Utiliser Riverpod pour le state management
- Créer des modèles avec Freezed
- Séparer la logique métier de l'UI

### Tests

- Tests unitaires pour les services et repositories
- Tests de widgets pour les écrans
- Minimum 70% de couverture pour les nouvelles features

## 🔍 Review Process

1. Un mainteneur reviewera votre PR
2. Des changements peuvent être demandés
3. Une fois approuvée, la PR sera mergée
4. Votre contribution sera ajoutée au CHANGELOG

## 🎯 Priorités Actuelles

Consultez les Issues avec les labels :
- `good first issue` - Bon pour débuter
- `help wanted` - Besoin d'aide
- `priority: high` - Priorité élevée

## 📚 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Supabase Docs](https://supabase.com/docs)
- [Riverpod Docs](https://riverpod.dev)

## 💬 Questions ?

- Ouvrez une Discussion sur GitHub
- Rejoignez notre Discord (lien à venir)
- Email : dev@rideup.app

Merci de contribuer à RideUp ! 🐴
