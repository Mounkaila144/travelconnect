# Exigences

## Exigences Fonctionnelles

- **FR1:** Le système doit afficher une carte interactive avec les questions géolocalisées visibles sous forme de marqueurs
- **FR2:** Les utilisateurs doivent pouvoir publier une question liée à leur position actuelle ou à une destination future
- **FR3:** Les utilisateurs doivent pouvoir répondre aux questions avec du texte
- **FR4:** Chaque utilisateur doit avoir un profil simplifié comprenant : nom, photo, bio courte, badge (Voyageur/Local), pays d'origine
- **FR5:** Le système doit calculer et afficher un score de confiance pour chaque utilisateur basé sur les évaluations de ses réponses
- **FR6:** Les utilisateurs doivent recevoir des notifications push pour les nouvelles réponses à leurs questions et les nouvelles questions dans leur zone
- **FR7:** Le système doit afficher un fil d'actualité/forum listant les questions récentes par destination
- **FR8:** Les utilisateurs doivent pouvoir s'authentifier via Google ou Apple Sign-In
- **FR9:** Les utilisateurs doivent pouvoir noter les réponses reçues (système d'évaluation)
- **FR10:** Les utilisateurs doivent pouvoir signaler du contenu inapproprié
- **FR11:** Le système doit permettre aux administrateurs de modérer et supprimer le contenu signalé
- **FR12:** Les utilisateurs doivent pouvoir filtrer les questions par destination/zone géographique
- **FR13:** Le système doit afficher le temps écoulé depuis la publication de chaque question/réponse
- **FR14:** Les utilisateurs doivent pouvoir uploader une photo de profil depuis leur galerie ou appareil photo

## Exigences Non-Fonctionnelles

- **NFR1:** Le chargement de la carte doit être inférieur à 3 secondes sur connexion 4G
- **NFR2:** Le temps de réponse API doit être inférieur à 500ms pour 95% des requêtes
- **NFR3:** L'application doit supporter iOS 15+ et Android 10+ (API 29)
- **NFR4:** L'application doit fonctionner en japonais pour le MVP
- **NFR5:** Le système doit supporter 10 000 utilisateurs actifs mensuels sans dégradation de performance
- **NFR6:** Les données utilisateurs doivent être chiffrées en transit (HTTPS) et au repos
- **NFR7:** Le système doit implémenter un rate limiting pour prévenir les abus
- **NFR8:** L'application doit respecter les guidelines Apple App Store et Google Play Store
- **NFR9:** Le backend doit être hébergé sur OVH avec une disponibilité de 99.5%
- **NFR10:** Les tokens d'authentification doivent expirer après 30 jours d'inactivité
- **NFR11:** Le système doit conserver les logs d'activité pendant 90 jours minimum
- **NFR12:** L'application doit consommer moins de 100MB de stockage sur l'appareil
