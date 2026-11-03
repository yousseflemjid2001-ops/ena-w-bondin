# 📋 Cahier des Charges & Spécifications — Agent IA Fidness (Détection du Churn & Push Ciblés)

> **Source :** Note vocale client — Projet Ena w Bondin x Fidness  
> **Date de mise à jour :** 02 Novembre 2026  
> **Statut :** Spécification validée & Prête pour implémentation  

---

## 1. 🎯 Contexte & Objectif

Dans le cadre de l'optimisation continue de la fidélisation pour la marque **Bondin**, le client souhaite intégrer un module d'intelligence artificielle dédié à la **rétention et à la lutte contre l'attrition (churn)**.

### Problématique Métier :
- Plusieurs clientes fidèles ou régulières cessent progressivement de fréquenter les points de vente Bondin sans signal explicite.
- Le risque d'attrition élevé entraîne une perte de chiffre d'affaires récurrent.
- Nécessité d'agir **de manière proactive** plutôt que réactive grâce à un agent intelligent capable d'identifier les clientes sensibles et de déclencher des leviers de réactivation immédiats (notifications push personnalisées).

---

## 2. 📍 Emplacement dans le Dashboard Bondin

L'agent IA s'intègre harmonieusement dans l'architecture visuelle du Dashboard décisionnel :
- **Ordre de navigation :** 
  1. Cockpit Direction Générale & CA
  2. ⭐ **Agent IA Fidness (Anti-Churn & Notifications Push)** *(NOUVEL ONGLET)*
  3. Segmentation & Grossistes
  4. Réseau & Géographie
  5. Audit & Conformité DWH
- **Bouton / Onglet de Navigation :** Placé directement **après le Cockpit** et **avant la Segmentation**.
- **Nom du composant / onglet :** `Agent IA Fidness` (ou `Agent IA Fidness — Churn & Rétention`).

---

## 3. 🤖 Identité de l'Agent IA

- **Nom officiel :** **Agent IA Fidness**
- **Rôle :** Analyste Prédictif & Expert Rétention / CRM Ena w Bondin
- **Avatar & Style :** Identité visuelle Fidness (bordeaux impérial, or champagne, badge IA interactif)
- **Ton :** Directif, analytique, orienté action et ROI fidélité.

---

## 4. 🚀 Fonctionnalités Clés Attendues

### A. Détection Intelligente du Risque de Churn (Score d'Attrition)
Quand l'Agent IA Fidness est ouvert, il analyse les données en temps réel (RFM - Récence, Fréquence, Montant) pour classifier les clientes :
- **Score de Churn (%) :** Calcul prédictif basé sur l'écart par rapport au cycle moyen d'achat (ex: cliente sans scan depuis plus de 30, 45 ou 60 jours, baisse de fréquence de >50%).
- **Segmentation du Risque :**
  - 🔴 **Risque Critique (> 75%)** : Clientes régulières n'étant pas revenues depuis 45+ jours (clientes sensibles qui risquent de ne plus revenir).
  - 🟠 **Risque Élevé (50% - 75%)** : Ralentissement net des passages en caisse.
  - 🟡 **En Vigilance (30% - 50%)** : Espacement inhabituel des visites.

### B. Répertoire Dynamique des Clientes Sensibles
Affichage d'un tableau interactif et ergonomique répertoriant les clientes à risque dès l'ouverture de l'onglet :
- **Identité :** Nom / Prénom de la cliente, Téléphone / Contact sécurisé.
- **Historique & Valeur :** CA cumulé, Total de points fidélité en stock, Magasin de prédilection.
- **Récence :** Date et heure du dernier scan / achat, jours d'inactivité.
- **Indicateur visuel :** Badge d'alerte de churn (ex: *« Risque 88% - Abandon imminent »*).

### C. Recommandations IA de Réactivation
Pour chaque groupe de clientes sensibles ou de manière individualisée, l'Agent IA Fidness propose une stratégie concrète :
- Recommandation d'offres adaptées selon les préférences d'achat (ex: Café Torréfié, Arabica, Espresso Cafétéria).
- Calcul du bon d'incitation optimal (ex: *« Offrir 100 points de bienvenue retour »*, *« Dégustation offerte nouvelle récolte »*).
- Moment idéal d'envoi de la sollicitation.

### D. Déclencheur de Notifications Push Ciblées
- **Générateur de Messages Push :** Textes percutants rédigés par l'IA adaptés à la marque Bondin.
  - *Exemple :* *« Bonjour Sonia, votre café préféré vous attend chez Bondin Menzah ! Profitez de 50 points bonus offerts sur votre prochain passage ce week-end. »*
- **Action 1-Clic :** Bouton direct `Envoyer la Push Notification` avec simulation temps réel d'envoi et journalisation dans le cockpit.
- **Envoi groupé :** Option `Lancer la campagne Anti-Churn ciblée (X clientes sensibles)`.

---

## 5. 🛠️ Architecture Technique & Intégration

| Composant | Description |
| :--- | :--- |
| **Frontend (`index.html`)** | Nouvel onglet `#tab-agent-fidness` inséré entre `#tab-cockpit` et `#tab-segmentation`. Interface avec widget interactif de l'Agent IA Fidness, KPIs Churn, liste des clientes sensibles et simulateur d'envoi push. |
| **Logique Client (`app.js`)** | Module `FidnessChurnAgent` : tri par churn score, filtres par point de vente, prévisualisation push, envoi interactif. |
| **API Backend (`server.py`)** | Endpoints dédiés :<br>• `GET /api/agent/churn-clients` : Clientes avec score de churn calculé sur PostgreSQL 17.7.<br>• `POST /api/agent/send-push` : Déclenchement et historisation de la notification push. |
| **Base de Données** | Tables `public.user`, `public.purchase`, `public.sell_points` (Données réelles de production). |

---

## 6. 📊 Indicateurs de Succès (KPIs de l'Agent IA Fidness)

1. **Nombre de clientes sensibles identifiées** (ex: clientes à risque élevé).
2. **Volume de CA sécurisable / à sauver** (CA généré dans le passé par ces clientes).
3. **Taux de réactivité aux notifications push** (retours en magasin sous 7 jours).
4. **Taux de rétention global du programme Ena w Bondin**.
