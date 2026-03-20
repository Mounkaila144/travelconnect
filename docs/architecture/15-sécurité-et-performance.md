# 15. Sécurité et Performance

## 15.1 Exigences de Sécurité

**Sécurité Frontend :**
- **Stockage Sécurisé :** Tokens stockés via `flutter_secure_storage` (Keychain iOS, Keystore Android)
- **Certificate Pinning :** Implémenté pour les connexions API en production
- **Obfuscation :** Code Dart obfusqué en release (`--obfuscate`)

**Sécurité Backend :**
- **Validation Input :** Toutes les entrées validées via Form Requests Laravel
- **Rate Limiting :** 60 requêtes/minute par IP, 1000/minute par utilisateur authentifié
- **CORS Policy :** Restreint aux domaines autorisés uniquement

**Sécurité Authentification :**
- **Stockage Tokens :** Tokens Sanctum hashés en base, expiration 30 jours inactivité
- **Gestion Sessions :** Un seul token actif par appareil, révocation possible
- **Politique Mots de Passe :** N/A (OAuth uniquement)

## 15.2 Optimisation Performance

**Performance Frontend :**
- **Taille Bundle :** < 20MB APK, < 50MB IPA (objectif)
- **Stratégie Chargement :** Lazy loading des features, préchargement carte
- **Stratégie Cache :** Cache images (cached_network_image), cache requêtes API (5 min)

**Performance Backend :**
- **Temps Réponse Cible :** < 500ms pour 95% des requêtes
- **Optimisation BDD :** Index sur colonnes de recherche, index spatial, requêtes optimisées
- **Stratégie Cache :** Cache fichier Laravel, cache requêtes géospatiales fréquentes
