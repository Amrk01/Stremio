# Stremio iOS

Application iOS native pour parcourir et lire du contenu via des addons Stremio avec support RealDebrid.

## Fonctionnalites

- **Catalogue** : Parcourez les catalogues de votre addon (films, series)
- **Recherche** : Recherchez du contenu par titre
- **Detail** : Fiches detaillees avec poster, description, casting, episodes
- **Streams** : Liste des sources disponibles avec resolution
- **RealDebrid** : Resolution automatique des liens via RealDebrid (direct links, magnets, torrents)
- **Lecteur** : Lecteur video integre avec support AirPlay et Picture-in-Picture
- **Series** : Navigation par saison/episode pour les series

## Configuration

1. Ouvrez `Stremio.xcodeproj` dans Xcode 15+
2. Selectionnez votre Team de signature dans les parametres du projet
3. Changez le Bundle Identifier si necessaire
4. Build & Run sur votre iPhone (iOS 16+)

## Premier lancement

Au premier lancement, l'app vous demandera :

1. **URL de l'addon** : L'URL de votre addon AIOStreams (ou tout addon Stremio compatible). Exemple : `https://aiostreams.example.com/E8s7.../manifest.json`
2. **Cle API RealDebrid** : Votre cle API disponible sur [real-debrid.com](https://real-debrid.com/apitoken)

## Architecture

```
Stremio/
  StremioApp.swift          # Point d'entree
  Models/
    StremioModels.swift     # Protocole addon Stremio (Manifest, Meta, Stream)
    RealDebridModels.swift  # Modeles API RealDebrid
    AppSettings.swift       # Parametres persistants
  Services/
    StremioService.swift    # Client API addon Stremio
    RealDebridService.swift # Client API RealDebrid
    ImageLoader.swift       # Chargement d'images async
  Views/
    MainTabView.swift       # Navigation par onglets
    SetupView.swift         # Assistant de configuration
    CatalogView.swift       # Catalogue principal
    CatalogDetailView.swift # Grille d'un catalogue
    SearchView.swift        # Recherche
    ContentDetailView.swift # Fiche detail film/serie
    StreamListView.swift    # Selection des sources
    VideoPlayerView.swift   # Lecteur video
    SettingsView.swift      # Parametres
    Components/
      PosterCard.swift      # Carte poster reutilisable
```

## Compatibilite

- iOS 16.0+
- iPhone et iPad
- Xcode 15+
- Swift 5.9+

## Notes techniques

- L'app utilise le protocole standard des addons Stremio (manifest, catalog, meta, stream)
- Compatible avec AIOStreams et tout addon Stremio standard
- RealDebrid est utilise pour derestreindre les liens (direct HTTP, magnets, torrents)
- Le lecteur supporte AirPlay et empeche la mise en veille pendant la lecture
- Audio en arriere-plan active pour la continuite de lecture
