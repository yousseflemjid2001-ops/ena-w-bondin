# 📊 Projet BI & IA Client : « ENA W BONDIN »
**Partenariat Stratégique : BONDIN x FIDNESS**  
*Document de Cadrage, Architecture & Spécifications Métier — Version 2.2 (Post-Retours Clients)*

---

## 🎯 1. Résumé Exécutif & Objectifs du Projet

Le projet a pour mission de concevoir et déployer une **plateforme décisionnelle (BI) moderne et prédictive (IA)** afin de piloter les performances de l'application mobile de fidélité **« Ena w Bondin »**.

### Les Objectifs Majeurs :
1. **Piloter le Chiffre d'Affaires Fidélité** : Mesurer le volume d'affaires scanné, le panier moyen et la fréquence d'achat.
2. **Segmenter la Base Consommateurs & Détecter les Grossistes (Retours Clients)** : 
   - Isoler les profils particuliers des profils grossistes/commerçants (achats volumineux en Succursale vs consommation au comptoir en Cafétéria).
   - Suivre les habitués ultra-fréquents scannant **plus de 3 fois par semaine**.
3. **Sécuriser la Rentabilité de la Cagnotte (Earn & Burn) & Mesurer la LTV (Customer Lifetime Value)** :
   - Surveiller le passif financier des points en circulation (dette TND provisionnée).
   - Mesurer le **chiffre d'affaires réel dépensé par un client avant de débloquer son premier cadeau**.
   - Calculer la **LTV stratifiée** par couche de clients (Champions, Réguliers, Occasionnels, Grossistes).
4. **Activer l'IA & Personnaliser l'Expérience** :
   - Prédire l'attrition client (**Churn ML à 30 jours**).
   - Recommander des cadeaux à forte valeur perçue.
   - Analyser le panier d'achat (**Market Basket Analysis**).

---

## 📐 2. Architecture des Données Cible (Schéma en Étoile Enrichi)

```
                          +-------------------+
                          |     Dim_Temps     |
                          +-------------------+
                                    |
+---------------------+             |             +---------------------+
|     Dim_Client      |------+      |      +------|     Dim_Produit     |
+---------------------+      |      |      |      +---------------------+
| ID_Client_Hache     |   +--------------------+  | ID_Produit          |
| Genre, Date_Inscr.  |---|Fait_Ventes_Fidelite|--| Nom, Gamme, Prix    |
| Segment_Client(RFM) |   +--------------------+  +---------------------+
| Profil_Reseau (B2B) |             |                        |
| Flag_Grossiste      |             |                        |
| Flag_Ultra_Frequent |             |             +---------------------+
+---------------------+             +-------------|     Dim_Magasin     |
         |                          |             +---------------------+
         |                +--------------------+  | ID_Magasin          |
         +----------------|Fait_Mouvements_Pts |  | Nom, Type (Succ/Caf)|
         |                +--------------------+  | Region_Gouvernorat  |
         |                          |             +---------------------+
         |                +--------------------+  +---------------------+
         +----------------|  Fait_Parrainages  |  |   Dim_Recompense    |
                          +--------------------+  +---------------------+
```

### 📋 Tables de Faits (Activité)
- **`Fait_Ventes_Fidelite`** (6 360 lignes) : Transactions scannées (Date, Client, Magasin, Montant TND, Points gagnés).
- **`Fait_Mouvements_Points`** (6 306 flux) : Crédits (Earn) et Débits de cadeaux (Burn).
- **`Fait_Parrainages`** (206 parrainages) : Relations parrains-filleuls et primes attribuées.

### 🏷️ Tables de Dimensions (Contexte)
- **`Dim_Client`** (2 161 profils) : Base pseudonymisée (MD5), scores RFM, **Profil Réseau (Grossiste vs Particulier)**, **Indicateur Ultra-Fréquent ($\ge$ 3 scans/semaine)**, et **CA avant premier cadeau**.
- **`Dim_Magasin`** (23 PDV) : Points de vente officiels BONDIN, gouvernorats et distinction **Succursale vs Cafétéria**.
- **`Dim_Produit`** (538 articles) : Catalogue et gammes de café (*Grains, Moulu, Capsules, Accessoires*).
- **`Dim_Recompense`** (14 cadeaux) : Catalogue cadeaux, coût en points et segmentation IA.
- **`Dim_Temps`** (121 jours) : Calendrier journalier dynamique avril-août 2026.
- **`Dim_Segment_Client`** (5 segments) : Typologie RFM officielle.

---

## 🔍 3. Avenant Métier : Retours Clients & Personnalisation BONDIN

Suite à l'analyse des retours audio de la Direction Métier, **3 exigences opérationnelles prioritaires** ont été intégrées :

### 3.1. Détection des Clients Grossistes / Comportements Mixtes (Alerte Sous Surveillance)
* **Constat dans les données réelles :** 227 clients réalisent à la fois des achats en Succursale et en Cafétéria.
  - Parmi eux, **144 clients** réalisent des achats très élevés en Succursale ($\ge$ 50 TND ou ticket $\ge$ 20 TND) et de petits achats en Cafétéria ($\sim$ 2 à 6 TND de consommation au comptoir).
  - Ces profils « Grossistes / B2B » représentent **57,8 % du CA total scanné** (34 410 TND) !
* **Traitement dans la solution :**
  - Tag automatique dans `Dim_Client` : `Flag_Grossiste_Suspect = 1`.
  - Deux filtres slicers dans Power BI : *Vue Consommateurs Particuliers* vs *Vue Grossistes & Mixtes sous surveillance*.

### 3.2. Analyse des Clients Ultra-Fréquents (Règle 20/80 & Passages $\ge$ 3 fois/semaine)
* **Constat dans les données réelles :** **147 clients** scannent en moyenne $\ge$ 3 fois par semaine d'activité (clients réguliers de salons/cafétérias).
* **Traitement dans la solution :**
  - Tag automatique : `Flag_Ultra_Frequent = 1`.
  - Mesure DAX dédiée pour mesurer le CA et le panier moyen de cette population clé.

### 3.3. Rentabilité de la Cagnotte / Production : LTV Stratifiée & CA Pré-Cadeau
* **Constat dans les données réelles :**
  - **35 clients** ont déjà consommé au moins un cadeau (Burn).
  - En moyenne, un client dépense **60,63 TND de CA réel** avant de débloquer et consommer son premier cadeau.
* **Traitement dans la solution :**
  - Mesure de la LTV moyenne segmentée :
    * LTV Champions : **289,83 TND**
    * LTV Grossistes / B2B : **238,96 TND**
    * LTV Réguliers : **51,70 TND**
    * LTV Occasionnels : **14,14 TND**
  - Calcul du ratio de rentabilité : $\frac{\text{Coût de la récompense}}{\text{CA généré avant cadeau}}$.

---

## 📊 4. Spécifications des 3 Dashboards Power BI

| Dashboard | Public Cible | Contenu Clé & Nouvelles Fonctionnalités |
| :--- | :--- | :--- |
| **1. Cockpit Direction & CA Fidélité** | Direction Générale BONDIN & Direction FIDNESS | • Cartes KPI (CA scanné total, panier moyen global, dette financière des points en circulation)<br>• **Comparatif Panier Moyen :** Succursale vs Cafétéria<br>• Tendances N vs N-1 & Time Intelligence MoM/YTD<br>• Simulateur **What-If DAX** (ajustement du barème points)<br>• Cartographie par gouvernorat des 23 points de vente |
| **2. Segmentation, Habitudes & Grossistes** | Responsables Marketing FIDNESS & Ventes BONDIN | • Matrice comportementale RFM & Pareto<br>• **Slicer Réseau :** Particuliers vs Grossistes/B2B<br>• Suivi des **Clients Ultra-Fréquents** (> 3 passages/semaine)<br>• **Table interactive des Grossistes sous surveillance** (alertes achats massifs)<br>• Pénétration par gamme de café (Grains, Moulu, Capsules) |
| **3. Cagnotte, LTV & Rentabilité Cadeaux** | Marketing, CRM & Contrôle de Gestion | • Jauge de santé économique **Earn & Burn** (équilibre cible 50%)<br>• **LTV Stratifiée :** Comparatif de la valeur client par segment<br>• **Rentabilité des Récompenses :** Suivi du CA moyen avant 1er cadeau (~60,6 TND)<br>• **Scoring Prédictif de Churn** (alerte clients à risque à 30 jours)<br>• Table du catalogue cadeaux et propositions IA |

---

## 🔒 5. Sécurité des Données (Row-Level Security - RLS)

4 rôles métier sont configurés dans Power BI :
1. **Direction Générale :** Vision globale sans restriction.
2. **Équipe Marketing B2C :** Visualisation exclusive des clients particuliers (exclut les grossistes/revendeurs et inactifs).
3. **Équipe Grands Comptes & Grossistes :** Suivi ciblé des 226 profils B2B et revendeurs suspects.
4. **Responsable Régional Grand Tunis :** Filtre automatique sur les 13 points de vente du Grand Tunis.

---

## 🚀 6. Planning & Statut d'Exécution

- [x] **Sprint 1 : Cadrage & Audit des Données** (Validé)
- [x] **Sprint 2 : Pipeline ETL, DWH & Rapport Technique 4 pages** (Validé)
- [x] **Sprint 3 (Partie 1) : Enrichissement Grossistes / LTV & Catalogue DAX** (Validé)
- [ ] **Sprint 3 (Partie 2) : Montage visuel des 3 Dashboards dans Power BI** (En cours)
- [ ] **Sprint 4 : Moteurs IA (Churn ML & Recommandation) & Recette** (À venir)
