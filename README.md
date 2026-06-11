# PlayStream 🎬

PlayStream est une application iOS native moderne et élégante conçue pour diffuser et organiser vos films et vidéos directement depuis votre stockage **Google Drive**.

Grâce à une interface premium inspirée des meilleures plateformes de SVOD (Netflix, Apple TV+), PlayStream transforme vos fichiers vidéo bruts stockés sur Google Drive en une superbe bibliothèque de médias personnelle.

---

## ✨ Fonctionnalités

*   🔐 **Connexion Google Sécurisée** : Authentification OAuth 2.0 native via `ASWebAuthenticationSession` utilisant le protocole sécurisé **PKCE** (Proof Key for Code Exchange) pour les applications clientes publiques.
*   📺 **Streaming Fluide** : Lecture vidéo native de haute qualité à l'aide d'un lecteur personnalisé basé sur `AVPlayer`.
*   🚀 **Optimisation du Stream Google Drive** : Résolveur de redirections HTTP asynchrone intégré pour extraire l'adresse de streaming directe depuis `googleusercontent.com` et contourner les limitations de bande passante/chargement standard.
*   🖼️ **Miniatures Haute Résolution** : Récupération et conversion automatique des vignettes Google Drive standard en versions haute définition ($1080\text{p}$) pour l'interface de l'application.
*   ⏳ **Mémoire de Lecture** : Sauvegarde automatique de la progression de chaque vidéo (reprise de lecture là où vous vous êtes arrêté).
*   🎨 **Design Premium & Thème Sombre** : Interface soignée utilisant une palette de couleurs sombres et des accents vibrants, conçue en SwiftUI.

---

## 🛠️ Architecture du Projet

Le projet suit une architecture propre et modulaire en SwiftUI :

```text
PlayStream/
├── Models/             # Modèles de données (DriveVideo, VideoMetadata)
├── Views/              # Composants et pages SwiftUI
│   ├── HomeView        # Tableau de bord principal avec sections horizontales
│   ├── MediaCardView   # Carte de média individuelle avec vignette
│   ├── MediaDetailView # Fiche détaillée du film (durée, description, lecture)
│   ├── PlayerView      # Lecteur vidéo personnalisé intégrant AVPlayer
│   └── HeroHeaderView  # En-tête dynamique pour les mises en avant
├── Services/           # Services applicatifs
│   ├── DriveAuthService      # Gestion de l'authentification et de la session Google
│   ├── DriveAPIService       # Requêtes vers l'API Google Drive v3 (fichiers, stream direct)
│   └── PlaybackProgressManager # Suivi et sauvegarde de la progression de lecture
└── Utils/              # Utilitaires de bas niveau (PKCE helper)
```

---

## ⚙️ Configuration & Installation

### Prérequis

*   **Xcode 15.0+**
*   **iOS 16.0+**
*   Un compte **Google Developer Console** (pour configurer votre propre accès à l'API Google Drive)

### Instructions de Configuration

1.  **Clonez le dépôt** :
    ```bash
    git clone https://github.com/votre-utilisateur/PlayStream.git
    cd PlayStream/PlayStream
    ```

2.  **Configurer le Google Cloud Project** :
    *   Créez un projet sur la [Google Cloud Console](https://console.cloud.google.com/).
    *   Activez l'API **Google Drive API**.
    *   Configurez l'écran de consentement OAuth (sélectionnez le type *Externe* et ajoutez le scope `.../auth/drive.readonly`).
    *   Créez des identifiants de type **ID client OAuth** pour une application **iOS**.
    *   Notez l'**ID client** (ex: `123456-abcdef.apps.googleusercontent.com`) et son **schéma d'URL iOS associé** (ex: `com.googleusercontent.apps.123456-abcdef`).

3.  **Mettre à jour l'application avec vos identifiants** :
    *   Ouvrez `PlayStream.xcodeproj` dans Xcode.
    *   Dans [DriveAuthService.swift](file:///Users/abdu/Documents/Projets/PlayStream/PlayStream/PlayStream/Services/DriveAuthService.swift), remplacez la constante `clientId` par votre ID client Google.
    *   Dans le fichier [Info.plist](file:///Users/abdu/Documents/Projets/PlayStream/PlayStream/PlayStream/Info.plist), sous `CFBundleURLTypes`, remplacez le schéma d'URL par votre schéma Google personnalisé (`com.googleusercontent.apps.VOTRE_ID`).

4.  **Exécutez le projet** sur votre simulateur ou appareil iOS !

---

## 🔒 Sécurité et Confidentialité

*   **OAuth 2.0 PKCE** : Ce projet utilise PKCE, ce qui signifie qu'**aucun secret client n'est requis ou stocké** dans le code. C'est la recommandation de sécurité officielle de Google pour les applications natives mobiles. Le *Client ID* présent dans le code est public par nature et peut être partagé sur GitHub en toute sécurité.
*   **UserDefaults (AppStorage)** : Le jeton d'accès OAuth est temporairement stocké sur l'appareil dans les UserDefaults afin de maintenir la session active entre les démarrages de l'application.

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
