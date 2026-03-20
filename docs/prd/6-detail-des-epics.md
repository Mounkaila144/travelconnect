# Détail des Epics

## Epic 1 : Fondation & Authentification

**Objectif :** Établir les bases techniques du projet avec une infrastructure robuste, un système d'authentification sociale fonctionnel (Google/Apple) et la gestion complète du profil utilisateur. Cette epic pose les fondations sur lesquelles toutes les fonctionnalités suivantes seront construites.

---

### Story 1.1 : Configuration initiale du projet

**En tant que** développeur,
**Je veux** avoir une structure de projet Laravel et Flutter configurée avec Git,
**Afin de** pouvoir commencer le développement sur des bases solides.

**Critères d'acceptation :**
1. Le repository `travelconnect-api` est créé avec Laravel 10+ initialisé
2. Le repository `travelconnect-app` est créé avec Flutter 3.x initialisé
3. Les fichiers .gitignore appropriés sont configurés pour chaque repository
4. Le fichier README.md documente les instructions de setup pour chaque projet
5. La structure de dossiers Laravel suit les conventions (Controllers, Models, Services)
6. La connexion à une base de données MySQL locale est fonctionnelle
7. Une route health-check `/api/health` retourne un status 200 avec timestamp

---

### Story 1.2 : Authentification Google Sign-In

**En tant qu'** utilisateur,
**Je veux** pouvoir me connecter avec mon compte Google,
**Afin d'** accéder rapidement à l'application sans créer un nouveau compte.

**Critères d'acceptation :**
1. L'écran de login affiche un bouton "Continuer avec Google" clairement visible
2. Le flux OAuth Google s'ouvre dans un navigateur sécurisé (pas WebView)
3. Après autorisation Google, l'utilisateur est redirigé vers l'app avec un token valide
4. Le backend crée automatiquement un compte utilisateur à la première connexion
5. Le token d'authentification est stocké de manière sécurisée sur l'appareil
6. Les connexions suivantes utilisent le token stocké sans redemander l'autorisation
7. Un message d'erreur clair s'affiche si l'authentification échoue
8. L'endpoint `/api/auth/google` accepte le token Google et retourne un token Sanctum

---

### Story 1.3 : Authentification Apple Sign-In

**En tant qu'** utilisateur iOS,
**Je veux** pouvoir me connecter avec mon compte Apple,
**Afin de** respecter mes préférences de confidentialité Apple.

**Critères d'acceptation :**
1. L'écran de login affiche un bouton "Continuer avec Apple" (style officiel Apple)
2. Le flux Apple Sign-In natif iOS s'ouvre correctement
3. L'option "Hide My Email" d'Apple est supportée
4. Le backend gère correctement les emails relayés Apple
5. Le compte utilisateur est créé avec le nom fourni par Apple (ou "Utilisateur" par défaut)
6. L'endpoint `/api/auth/apple` accepte le token Apple et retourne un token Sanctum
7. Sur Android, le bouton Apple n'est pas affiché

---

### Story 1.4 : Création et affichage du profil utilisateur

**En tant qu'** utilisateur connecté,
**Je veux** avoir un profil avec mes informations de base,
**Afin que** les autres utilisateurs puissent me connaître et me faire confiance.

**Critères d'acceptation :**
1. À la première connexion, l'utilisateur est dirigé vers un écran de complétion de profil
2. Le profil contient : nom d'affichage, photo, bio courte (max 150 caractères), pays
3. L'utilisateur peut choisir son type : "Voyageur" ou "Local Supporter"
4. Un badge visuel distinct indique le type d'utilisateur (Voyageur/Local)
5. La photo de profil peut être uploadée depuis la galerie ou l'appareil photo
6. Les photos sont redimensionnées à 400x400px avant upload
7. L'écran "Mon profil" affiche toutes les informations avec le score de confiance (initialisé à 0)
8. L'endpoint GET `/api/user/profile` retourne les données du profil connecté
9. L'endpoint PUT `/api/user/profile` permet de modifier les informations

---

### Story 1.5 : Déconnexion et gestion de session

**En tant qu'** utilisateur connecté,
**Je veux** pouvoir me déconnecter de l'application,
**Afin de** sécuriser mon compte sur un appareil partagé.

**Critères d'acceptation :**
1. Un bouton "Déconnexion" est accessible dans les paramètres
2. Une confirmation est demandée avant déconnexion
3. Le token local est supprimé après déconnexion
4. Le token est invalidé côté serveur
5. L'utilisateur est redirigé vers l'écran de login
6. L'endpoint POST `/api/auth/logout` invalide le token courant

---

## Epic 2 : Carte & Questions

**Objectif :** Implémenter le cœur de l'expérience TravelConnect : une carte interactive affichant les questions géolocalisées et permettant aux utilisateurs de publier leurs propres questions. Cette epic transforme l'application en un outil utile pour les voyageurs.

---

### Story 2.1 : Affichage de la carte interactive

**En tant qu'** utilisateur,
**Je veux** voir une carte interactive de ma zone,
**Afin de** visualiser les questions posées autour de moi.

**Critères d'acceptation :**
1. La carte Google Maps s'affiche en plein écran comme vue principale
2. La carte se centre sur la position actuelle de l'utilisateur au chargement
3. L'utilisateur peut zoomer, dézoomer et naviguer sur la carte
4. Un bouton "Ma position" permet de recentrer sur la localisation actuelle
5. La permission de géolocalisation est demandée avec une explication claire
6. Si la permission est refusée, la carte affiche une position par défaut (Tokyo)
7. Le chargement de la carte prend moins de 3 secondes sur 4G

---

### Story 2.2 : Affichage des marqueurs de questions

**En tant qu'** utilisateur,
**Je veux** voir des marqueurs sur la carte représentant les questions,
**Afin de** découvrir ce que les voyageurs demandent dans une zone.

**Critères d'acceptation :**
1. Les questions sont représentées par des marqueurs distinctifs sur la carte
2. Les marqueurs affichent un aperçu (icône + indicateur de nombre de réponses)
3. Les questions sans réponse ont un marqueur d'une couleur différente (urgence visuelle)
4. Cliquer sur un marqueur affiche une info-bulle avec le titre de la question
5. Cliquer sur l'info-bulle ouvre le détail complet de la question
6. Le clustering s'active automatiquement quand les marqueurs sont trop proches
7. L'endpoint GET `/api/questions?lat={lat}&lng={lng}&radius={km}` retourne les questions dans le rayon
8. Maximum 100 questions sont chargées à la fois (pagination)

---

### Story 2.3 : Publication d'une nouvelle question

**En tant qu'** utilisateur,
**Je veux** pouvoir poster une question liée à un lieu,
**Afin d'** obtenir des conseils de locaux ou voyageurs expérimentés.

**Critères d'acceptation :**
1. Un bouton flottant (FAB) "+" est toujours visible sur la carte
2. Cliquer sur le FAB ouvre un formulaire de nouvelle question
3. Le formulaire contient : titre (obligatoire, max 100 car.), description (max 500 car.)
4. La localisation est pré-remplie avec la position actuelle
5. L'utilisateur peut ajuster la localisation en déplaçant un marqueur sur une mini-carte
6. Un bouton "Publier" envoie la question
7. Une confirmation visuelle s'affiche après publication réussie
8. La nouvelle question apparaît immédiatement sur la carte
9. L'endpoint POST `/api/questions` crée une nouvelle question
10. Les champs titre et localisation sont validés côté serveur

---

### Story 2.4 : Affichage du détail d'une question

**En tant qu'** utilisateur,
**Je veux** voir le détail complet d'une question,
**Afin de** comprendre le contexte et lire les réponses.

**Critères d'acceptation :**
1. L'écran détail affiche : titre, description, localisation sur mini-carte
2. L'auteur est affiché avec sa photo, nom, badge et score de confiance
3. La date de publication est affichée en format relatif ("il y a 2h")
4. Le nombre de réponses est indiqué
5. La liste des réponses s'affiche sous la question (voir Epic 3)
6. Un bouton "Répondre" est visible en bas de l'écran
7. L'endpoint GET `/api/questions/{id}` retourne la question avec ses réponses

---

### Story 2.5 : Mes questions

**En tant qu'** utilisateur,
**Je veux** voir la liste des questions que j'ai posées,
**Afin de** suivre les réponses reçues.

**Critères d'acceptation :**
1. Un onglet "Mes questions" est accessible depuis le profil
2. La liste affiche mes questions triées par date (récentes en premier)
3. Chaque item montre : titre, localisation, nombre de réponses, date
4. Un indicateur visuel signale les nouvelles réponses non lues
5. Cliquer sur une question ouvre son détail
6. L'endpoint GET `/api/user/questions` retourne les questions de l'utilisateur connecté

---

## Epic 3 : Réponses & Réputation

**Objectif :** Compléter le cycle d'interaction communautaire en permettant aux utilisateurs de répondre aux questions et de noter les réponses. Le système de score de confiance différencie TravelConnect des solutions anonymes existantes.

---

### Story 3.1 : Répondre à une question

**En tant qu'** utilisateur,
**Je veux** pouvoir répondre à une question,
**Afin d'** aider un voyageur avec mon expérience.

**Critères d'acceptation :**
1. Le bouton "Répondre" sur le détail question ouvre un champ de saisie
2. La réponse accepte du texte (max 1000 caractères)
3. Un compteur de caractères indique la limite
4. Le bouton "Envoyer" publie la réponse
5. La réponse apparaît immédiatement dans la liste
6. L'auteur de la question reçoit une notification (voir Epic 4)
7. L'endpoint POST `/api/questions/{id}/answers` crée une réponse
8. Un utilisateur peut poster plusieurs réponses à la même question

---

### Story 3.2 : Affichage des réponses

**En tant qu'** utilisateur,
**Je veux** voir toutes les réponses à une question,
**Afin de** bénéficier des différents points de vue.

**Critères d'acceptation :**
1. Les réponses s'affichent sous la question, triées par pertinence (score puis date)
2. Chaque réponse montre : texte, auteur (photo, nom, badge, score), date
3. La note moyenne de la réponse est affichée (étoiles)
4. Les réponses de Local Supporters sont visuellement mises en avant
5. Un indicateur montre si l'utilisateur a déjà noté cette réponse
6. La pagination charge les réponses supplémentaires au scroll

---

### Story 3.3 : Noter une réponse

**En tant qu'** utilisateur,
**Je veux** pouvoir noter une réponse,
**Afin d'** indiquer sa qualité et aider au calcul du score de confiance.

**Critères d'acceptation :**
1. Chaque réponse affiche un système de notation (1-5 étoiles)
2. L'utilisateur peut noter en tapant sur les étoiles
3. La note est enregistrée immédiatement avec feedback visuel
4. L'utilisateur peut modifier sa note
5. L'auteur d'une réponse ne peut pas noter sa propre réponse
6. La note moyenne est recalculée après chaque vote
7. L'endpoint POST `/api/answers/{id}/rate` enregistre la note
8. L'endpoint retourne la nouvelle moyenne

---

### Story 3.4 : Calcul et affichage du score de confiance

**En tant qu'** utilisateur,
**Je veux** voir le score de confiance des autres utilisateurs,
**Afin de** juger la fiabilité de leurs conseils.

**Critères d'acceptation :**
1. Le score de confiance est affiché sur chaque profil et à côté de chaque réponse
2. Le score est calculé selon : moyenne des notes reçues × log(nombre de réponses + 1)
3. Le score est affiché sur une échelle de 0 à 5 avec une décimale
4. Les nouveaux utilisateurs affichent "Nouveau" au lieu d'un score
5. Le score est recalculé automatiquement après chaque nouvelle note
6. Un tooltip explique le calcul du score au tap

---

### Story 3.5 : Signalement de contenu

**En tant qu'** utilisateur,
**Je veux** pouvoir signaler un contenu inapproprié,
**Afin de** maintenir une communauté saine.

**Critères d'acceptation :**
1. Un bouton "Signaler" (icône drapeau) est accessible sur chaque question et réponse
2. Cliquer ouvre un menu avec les raisons : Spam, Contenu offensant, Information fausse, Autre
3. L'utilisateur peut ajouter un commentaire optionnel
4. Une confirmation s'affiche après le signalement
5. Le contenu signalé est marqué pour revue dans l'admin
6. L'endpoint POST `/api/reports` crée un signalement
7. Un utilisateur ne peut signaler le même contenu qu'une fois

---

## Epic 4 : Notifications & Engagement

**Objectif :** Maximiser l'engagement et la réactivité de la communauté grâce aux notifications push et au fil d'actualité. Ces fonctionnalités sont essentielles pour atteindre l'objectif de temps de réponse < 2h.

---

### Story 4.1 : Configuration Firebase Cloud Messaging

**En tant que** développeur,
**Je veux** intégrer Firebase Cloud Messaging,
**Afin d'** envoyer des notifications push aux utilisateurs.

**Critères d'acceptation :**
1. Le projet Firebase est configuré pour iOS et Android
2. L'app Flutter demande la permission de notifications au premier lancement
3. Le token FCM de chaque appareil est envoyé et stocké au backend
4. Le backend peut envoyer des notifications via l'API Firebase Admin
5. Les notifications sont reçues app en foreground et background
6. L'endpoint POST `/api/user/fcm-token` enregistre le token FCM

---

### Story 4.2 : Notifications de nouvelles réponses

**En tant qu'** auteur d'une question,
**Je veux** recevoir une notification quand quelqu'un répond,
**Afin de** ne pas manquer les conseils reçus.

**Critères d'acceptation :**
1. Une notification push est envoyée à l'auteur quand une réponse est postée
2. La notification contient : "Nouvelle réponse à [titre question]" + aperçu
3. Cliquer sur la notification ouvre le détail de la question
4. Les notifications sont envoyées même si l'app est fermée
5. L'utilisateur peut désactiver ce type de notification dans les paramètres

---

### Story 4.3 : Notifications de questions proches

**En tant que** Local Supporter,
**Je veux** être notifié des nouvelles questions dans ma zone,
**Afin de** pouvoir aider rapidement les voyageurs.

**Critères d'acceptation :**
1. Les Local Supporters peuvent définir leur zone d'intérêt (ville/rayon)
2. Une notification est envoyée quand une question est postée dans cette zone
3. La notification contient : "Nouvelle question près de [lieu]" + titre
4. Maximum 5 notifications par jour pour éviter le spam
5. L'utilisateur peut ajuster le rayon ou désactiver dans les paramètres
6. L'endpoint PUT `/api/user/notification-zone` configure la zone

---

### Story 4.4 : Fil d'actualité des questions

**En tant qu'** utilisateur,
**Je veux** voir une liste des questions récentes,
**Afin de** découvrir les questions sans utiliser la carte.

**Critères d'acceptation :**
1. Un onglet "Forum" est accessible depuis la navigation principale
2. Le fil affiche les questions récentes triées par date
3. Chaque item montre : titre, localisation, auteur, nombre de réponses, temps écoulé
4. Un filtre permet de sélectionner une destination/ville
5. Pull-to-refresh actualise la liste
6. Scroll infini charge les questions plus anciennes
7. Cliquer sur une question ouvre son détail
8. L'endpoint GET `/api/questions?sort=recent&city={city}` supporte le filtrage

---

### Story 4.5 : Centre de notifications

**En tant qu'** utilisateur,
**Je veux** voir l'historique de mes notifications,
**Afin de** retrouver les alertes que j'ai manquées.

**Critères d'acceptation :**
1. Une icône cloche dans la navigation indique les notifications non lues
2. Un badge numérique montre le nombre de non lues
3. L'écran notifications liste toutes les alertes reçues
4. Les notifications non lues sont visuellement distinctes
5. Cliquer sur une notification la marque comme lue et ouvre le contenu lié
6. L'endpoint GET `/api/notifications` retourne les notifications de l'utilisateur
7. L'endpoint POST `/api/notifications/{id}/read` marque comme lue

---

## Epic 5 : Administration & Lancement

**Objectif :** Créer les outils d'administration nécessaires à la modération, finaliser les tests et préparer le déploiement sur les stores iOS et Android. Cette epic aboutit au lancement public de l'application.

---

### Story 5.1 : Interface d'administration - Authentification

**En tant qu'** administrateur,
**Je veux** accéder à une interface d'administration sécurisée,
**Afin de** gérer le contenu et les utilisateurs.

**Critères d'acceptation :**
1. Une page de login admin est accessible à `/admin`
2. L'authentification utilise email/mot de passe (pas OAuth)
3. Les comptes admin sont créés manuellement en base de données
4. La session admin expire après 8 heures d'inactivité
5. Le tableau de bord affiche les statistiques clés (utilisateurs, questions, réponses)
6. L'interface est responsive et utilisable sur mobile

---

### Story 5.2 : Modération du contenu signalé

**En tant qu'** administrateur,
**Je veux** voir et traiter les contenus signalés,
**Afin de** maintenir la qualité de la communauté.

**Critères d'acceptation :**
1. Une liste affiche tous les signalements non traités, triés par date
2. Chaque signalement montre : contenu, raison, commentaire, signaleur
3. L'admin peut voir le contenu complet en contexte
4. Actions disponibles : Approuver (ignorer signalement), Supprimer contenu, Bannir utilisateur
5. Un champ permet d'ajouter une note interne
6. Le statut du signalement est mis à jour après action
7. L'historique des actions de modération est conservé

---

### Story 5.3 : Gestion des utilisateurs

**En tant qu'** administrateur,
**Je veux** pouvoir gérer les utilisateurs,
**Afin de** traiter les cas problématiques.

**Critères d'acceptation :**
1. Une liste affiche tous les utilisateurs avec recherche par nom/email
2. Le profil complet de chaque utilisateur est consultable
3. L'historique des questions et réponses est visible
4. Actions disponibles : Bannir (temporaire/permanent), Retirer badge Local
5. L'utilisateur banni ne peut plus se connecter
6. L'historique des actions est conservé avec timestamp et admin

---

### Story 5.4 : Configuration du serveur de production

**En tant que** développeur,
**Je veux** déployer l'API sur un serveur OVH de production,
**Afin que** l'application soit accessible aux utilisateurs.

**Critères d'acceptation :**
1. Un VPS OVH est provisionné avec les specs minimales requises
2. Nginx est configuré comme reverse proxy avec HTTPS (Let's Encrypt)
3. PHP-FPM est configuré pour Laravel
4. MySQL 8 est installé et sécurisé
5. Les variables d'environnement de production sont configurées
6. Les migrations de base de données sont exécutées
7. L'API répond correctement sur le domaine de production
8. Les logs sont configurés pour rotation automatique

---

### Story 5.5 : Déploiement sur App Store (iOS)

**En tant que** développeur,
**Je veux** soumettre l'application sur l'App Store,
**Afin que** les utilisateurs iOS puissent la télécharger.

**Critères d'acceptation :**
1. Le build de production Flutter iOS est généré et signé
2. Les assets App Store sont préparés (icône, screenshots, description)
3. La politique de confidentialité est publiée et liée
4. Le formulaire App Store Connect est complété en japonais
5. L'application passe la review Apple
6. L'app est publiée en "Disponible au Japon" initialement

---

### Story 5.6 : Déploiement sur Google Play (Android)

**En tant que** développeur,
**Je veux** soumettre l'application sur Google Play,
**Afin que** les utilisateurs Android puissent la télécharger.

**Critères d'acceptation :**
1. Le build de production Flutter Android (AAB) est généré et signé
2. Les assets Play Store sont préparés (icône, screenshots, description)
3. La politique de confidentialité est liée
4. Le formulaire Play Console est complété en japonais
5. Le questionnaire de classification du contenu est rempli
6. L'application passe la review Google
7. L'app est publiée en "Disponible au Japon" initialement
