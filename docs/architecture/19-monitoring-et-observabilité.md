# 19. Monitoring et Observabilité

## 19.1 Stack de Monitoring

| Composant | Outil | Objectif |
|-----------|-------|----------|
| **Crash Reporting Mobile** | Firebase Crashlytics | Erreurs et crashes app |
| **Analytics Mobile** | Firebase Analytics | Événements utilisateur |
| **Logs Backend** | Laravel Log (fichiers) | Logs applicatifs |
| **Monitoring Serveur** | OVH Monitoring | CPU, RAM, disque |
| **Uptime** | UptimeRobot (gratuit) | Disponibilité API |

## 19.2 Métriques Clés

**Métriques Frontend :**
- Crashs par session
- Temps de chargement carte
- Taux de conversion login → création question
- Sessions actives par jour

**Métriques Backend :**
- Requêtes par seconde
- Temps de réponse (p50, p95, p99)
- Taux d'erreur (4xx, 5xx)
- Requêtes de base de données lentes
