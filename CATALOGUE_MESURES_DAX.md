# 📐 Catalogue Officiel des Mesures DAX : « ENA W BONDIN »
**Projet Décisionnel BI & IA Client : BONDIN x FIDNESS**  
*Document Technique pour Power BI Desktop — Version Prête à l'Emploi*

---

## 🛠️ 1. Recommandations Préalables d'Intégration dans Power BI

### A. Création de la Table Dédiée aux Mesures (`_Mesures`)
Pour conserver un modèle propre et modulaire, il est fortement recommandé de ne pas disperser les mesures dans les tables de faits. Créez une table vide dédiée :
1. Dans le ruban Power BI : **Accueil** > **Entrer des données**.
2. Nommez la table : `_Mesures`.
3. Validez, puis créez toutes vos mesures dans cette table.
4. Supprimez ensuite la colonne vide par défaut `Colonne1` pour que la table prenne l'icône de calculatrice 🖩 en tête de liste.

### B. Configuration de la Dimension Temps (`Dim_Temps`)
1. Faites un clic droit sur `Dim_Temps` > **Marquer comme table de dates** > Choisir la colonne `Date`.
2. Sélectionnez la colonne `Nom_Mois` > Onglet **Outils de colonne** > **Trier par colonne** > Sélectionner `Mois` (pour un tri chronologique correct : Avril, Mai, Juin, Juillet, Août).

### C. Schéma Relationnel Actif
- `Dim_Temps[Date]` $1 \rightarrow \infty$ `Fait_Ventes_Fidelite[Date]`
- `Dim_Temps[Date]` $1 \rightarrow \infty$ `Fait_Mouvements_Points[Date]`
- `Dim_Client[ID_Client_Hache]` $1 \rightarrow \infty$ `Fait_Ventes_Fidelite[ID_Client_Hache]`
- `Dim_Client[ID_Client_Hache]` $1 \rightarrow \infty$ `Fait_Mouvements_Points[ID_Client_Hache]`
- `Dim_Client[ID_Client_Hache]` $1 \rightarrow \infty$ `Fait_Parrainages[ID_Parrain_Hache]`
- `Dim_Magasin[ID_Magasin]` $1 \rightarrow \infty$ `Fait_Ventes_Fidelite[ID_Magasin]`
- *Type de filtre croisé :* **Unique (Unidirectionnel)** pour toutes les relations.

---

## 📂 2. Répertoire Complet des Mesures DAX par Dossier

---

### 📁 Dossier 01 : Ventes & Chiffre d'Affaires

#### 1.1. Chiffre d'Affaires Fidélité Global
* **Nom :** `[CA_Fidelite_Total]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
* **Description :** Somme cumulée de tous les achats scannés par QR Code sur l'application mobile.
```dax
CA_Fidelite_Total = 
CALCULATE(
    SUM(Fait_Ventes_Fidelite[Montant_TND])
)
```

#### 1.2. Nombre de Transactions Scannées
* **Nom :** `[Nb_Transactions]`
* **Format :** Nombre entier (`#,##0`)
* **Description :** Volume total des actes d'achats scannés enregistrés par le système.
```dax
Nb_Transactions = 
COUNTROWS(Fait_Ventes_Fidelite)
```

#### 1.3. Nombre de Clients Actifs (Ayant au moins un scan)
* **Nom :** `[Nb_Clients_Actifs]`
* **Format :** Nombre entier (`#,##0`)
* **Description :** Nombre unique d'utilisateurs ayant scanné au moins un achat sur la période filtrée.
```dax
Nb_Clients_Actifs = 
DISTINCTCOUNT(Fait_Ventes_Fidelite[ID_Client_Hache])
```

#### 1.4. Chiffre d'Affaires par Gamme
* **Nom :** `[CA_Gamme_Moulu]`, `[CA_Gamme_Grains]`, etc.
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Gamme_Moulu = 
CALCULATE(
    [CA_Fidelite_Total],
    Dim_Produit[Gamme_Cafe] = "Gamme Café Moulu"
)
```

---

### 📁 Dossier 02 : Panier Moyen & Fréquence de Visite

#### 2.1. Panier Moyen Fidélité (AOV - Average Order Value)
* **Nom :** `[Panier_Moyen_AOV]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
* **Description :** Dépense moyenne par acte d'achat scanné.
```dax
Panier_Moyen_AOV = 
DIVIDE(
    [CA_Fidelite_Total],
    [Nb_Transactions],
    0
)
```

#### 2.2. Fréquence Moyenne d'Achat (Visites par client actif)
* **Nom :** `[Frequence_Achat_Moyenne]`
* **Format :** Décimal (`0.00 "scans/client"`)
* **Description :** Nombre moyen de passages en caisse par client actif sur la période.
```dax
Frequence_Achat_Moyenne = 
DIVIDE(
    [Nb_Transactions],
    [Nb_Clients_Actifs],
    0
)
```

#### 2.3. Chiffre d'Affaires Moyen par Client Actif
* **Nom :** `[CA_Moyen_Par_Client]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Moyen_Par_Client = 
DIVIDE(
    [CA_Fidelite_Total],
    [Nb_Clients_Actifs],
    0
)
```

---

### 📁 Dossier 03 : Intelligence Temporelle (Time Intelligence N vs N-1)

#### 3.1. Chiffre d'Affaires du Mois Précédent (M-1)
* **Nom :** `[CA_Mois_Precedent]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Mois_Precedent = 
CALCULATE(
    [CA_Fidelite_Total],
    DATEADD(Dim_Temps[Date], -1, MONTH)
)
```

#### 3.2. Croissance Mensuelle du CA (MoM %)
* **Nom :** `[Croissance_CA_MoM_%]`
* **Format :** Pourcentage (`+0.0 %;-0.0 %;0.0 %`)
```dax
Croissance_CA_MoM_% = 
VAR _CAMoisActuel = [CA_Fidelite_Total]
VAR _CAMoisPrecedent = [CA_Mois_Precedent]
RETURN
IF(
    NOT ISBLANK(_CAMoisPrecedent) && _CAMoisPrecedent > 0,
    DIVIDE(_CAMoisActuel - _CAMoisPrecedent, _CAMoisPrecedent, 0),
    BLANK()
)
```

#### 3.3. Chiffre d'Affaires Cumulé Annuel (YTD)
* **Nom :** `[CA_YTD]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_YTD = 
TOTALYTD(
    [CA_Fidelite_Total],
    Dim_Temps[Date]
)
```

---

### 📁 Dossier 04 : Segmentation Consommateurs & Analyse Pareto (RFM)

#### 4.1. Base Clients Inscrits Totale
* **Nom :** `[Nb_Clients_Inscrits]`
* **Format :** Nombre entier (`#,##0`)
```dax
Nb_Clients_Inscrits = 
COUNTROWS(Dim_Client)
```

#### 4.2. Taux d'Activation de la Base (%)
* **Nom :** `[Taux_Activation_Clients_%]`
* **Format :** Pourcentage (`0.0 %`)
* **Description :** Pourcentage d'inscrits ayant franchi le pas du premier scan.
```dax
Taux_Activation_Clients_% = 
DIVIDE(
    [Nb_Clients_Actifs],
    [Nb_Clients_Inscrits],
    0
)
```

#### 4.3. CA Généré par les Champions VIP (Top Consommateurs)
* **Nom :** `[CA_Champions_VIP]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Champions_VIP = 
CALCULATE(
    [CA_Fidelite_Total],
    Dim_Client[Segment_Client] = "Gros Consommateur (Champion)"
)
```

#### 4.4. Part de Concentration du CA des Champions (%)
* **Nom :** `[Part_CA_Champions_%]`
* **Format :** Pourcentage (`0.0 %`)
* **Description :** Vérifie le principe de Pareto (part du CA générée par le groupe de tête).
```dax
Part_CA_Champions_% = 
DIVIDE(
    [CA_Champions_VIP],
    [CA_Fidelite_Total],
    0
)
```

#### 4.5. Panier Moyen des Champions vs Occasionnels
* **Nom :** `[Panier_Moyen_Champions]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
Panier_Moyen_Champions = 
CALCULATE(
    [Panier_Moyen_AOV],
    Dim_Client[Segment_Client] = "Gros Consommateur (Champion)"
)
```

* **Nom :** `[Panier_Moyen_Occasionnels]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
Panier_Moyen_Occasionnels = 
CALCULATE(
    [Panier_Moyen_AOV],
    Dim_Client[Segment_Client] = "Consommateur Occasionnel"
)
```

---

### 📁 Dossier 05 : Cagnotte, Économie des Points (Earn & Burn Analytics)

#### 5.1. Total Points Attribués / Gagnés (Earn)
* **Nom :** `[Points_Earn_Distribues]`
* **Format :** Nombre entier (`#,##0 "pts"`)
* **Description :** Volume de points crédités lors des passages en caisse.
```dax
Points_Earn_Distribues = 
CALCULATE(
    SUM(Fait_Ventes_Fidelite[Points_Gagnes])
)
```

#### 5.2. Total Points Consommés en Cadeaux (Burn)
* **Nom :** `[Points_Burn_Consommes]`
* **Format :** Nombre entier (`#,##0 "pts"`)
* **Description :** Volume de points débités lors de l'obtention d'articles cadeaux.
```dax
Points_Burn_Consommes = 
CALCULATE(
    ABS(SUM(Fait_Mouvements_Points[Points])),
    Fait_Mouvements_Points[Points] < 0
)
```

#### 5.3. Solde Net de Points en Circulation
* **Nom :** `[Solde_Points_En_Circulation]`
* **Format :** Nombre entier (`#,##0 "pts"`)
* **Description :** Capital de points cumulé restant entre les mains des clients.
```dax
Solde_Points_En_Circulation = 
[Points_Earn_Distribues] - [Points_Burn_Consommes]
```

#### 5.4. Ratio d'Équilibre Earn & Burn (%)
* **Nom :** `[Ratio_Earn_Burn_%]`
* **Format :** Pourcentage (`0.0 %`)
* **Description :** Taux de consommation de la fidélité. Idéal entre 45% et 60%.
```dax
Ratio_Earn_Burn_% = 
DIVIDE(
    [Points_Burn_Consommes],
    [Points_Earn_Distribues],
    0
)
```

#### 5.5. Dette Financière Provisionnée des Points (Encours Passif)
* **Nom :** `[Dette_Financiere_Points_TND]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
* **Hypothèse officielle du modèle :** 1 point de fidélité équivaut à 0,010 TND (soit 10 millimes) de provision de récompense.
```dax
Dette_Financiere_Points_TND = 
VAR _CoutMoyenParPoint = 0.010 // 1 pt = 10 millimes TND
RETURN
[Solde_Points_En_Circulation] * _CoutMoyenParPoint
```

#### 5.6. Taux de Rédemption Clients (%)
* **Nom :** `[Taux_Redemption_Clients_%]`
* **Format :** Pourcentage (`0.0 %`)
* **Description :** Pourcentage des clients ayant déjà converti leurs points au moins une fois contre un cadeau.
```dax
Taux_Redemption_Clients_% = 
VAR _ClientsAyantBrule = 
    CALCULATE(
        DISTINCTCOUNT(Fait_Mouvements_Points[ID_Client_Hache]),
        Fait_Mouvements_Points[Points] < 0
    )
RETURN
DIVIDE(
    _ClientsAyantBrule,
    [Nb_Clients_Actifs],
    0
)
```

---

### 📁 Dossier 06 : Rétention, Parrainage & Prédiction IA

#### 6.1. Nombre de Parrainages Réussis
* **Nom :** `[Nb_Parrainages]`
* **Format :** Nombre entier (`#,##0`)
```dax
Nb_Parrainages = 
COUNTROWS(Fait_Parrainages)
```

#### 6.2. Points de Prime Distribués pour Parrainage
* **Nom :** `[Points_Primes_Parrainage]`
* **Format :** Nombre entier (`#,##0 "pts"`)
```dax
Points_Primes_Parrainage = 
SUM(Fait_Parrainages[Points_Parrainage])
```

#### 6.3. Nombre de Clients en Risque d'Attrition (Alerte Churn)
* **Nom :** `[Nb_Clients_Risque_Churn]`
* **Format :** Nombre entier (`#,##0`)
```dax
Nb_Clients_Risque_Churn = 
CALCULATE(
    COUNTROWS(Dim_Client),
    Dim_Client[Segment_Client] = "En Risque d'Attrition (Churn)"
)
```

#### 6.4. Taux d'Attrition Prédictif (Taux de Churn %)
* **Nom :** `[Taux_Churn_%]`
* **Format :** Pourcentage (`0.0 %`)
```dax
Taux_Churn_% = 
DIVIDE(
    [Nb_Clients_Risque_Churn],
    [Nb_Clients_Actifs],
    0
)
```

---

### 📁 Dossier 07 : Simulation Dynamique What-If (Ajustement de Barème)

#### Procédure de création du paramètre What-If dans Power BI :
1. Ruban **Modélisation** > **Nouveau paramètre** > **Numérique**.
2. Nom : `Param_Taux_Points`.
3. Type : Nombre décimal (Minimum: `0.5`, Maximum: `3.0`, Incrément: `0.1`, Défaut: `1.0`).
4. Cela génère automatiquement une table de paramètre et la mesure `[Valeur Param_Taux_Points]`.

#### 7.1. Simulation du Volume de Points Attribués
* **Nom :** `[Points_Earn_Simules]`
* **Format :** Nombre entier (`#,##0 "pts"`)
```dax
Points_Earn_Simules = 
VAR _Multiplicateur = 'Param_Taux_Points'[Valeur Param_Taux_Points]
RETURN
[Points_Earn_Distribues] * _Multiplicateur
```

#### 7.2. Simulation de l'Impact sur la Dette Financière (TND)
* **Nom :** `[Dette_Simulee_TND]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
Dette_Simulee_TND = 
VAR _PointsEarnFuturs = [Points_Earn_Simules]
VAR _PointsBurnEstimes = _PointsEarnFuturs * [Ratio_Earn_Burn_%]
VAR _SoldeFutur = _PointsEarnFuturs - _PointsBurnEstimes
VAR _CoutMoyenParPoint = 0.010
RETURN
_SoldeFutur * _CoutMoyenParPoint
```

#### 7.3. Écart Financier vs Dette Actuelle
* **Nom :** `[Ecart_Dette_Simulation_TND]`
* **Format :** Monétaire (`+#,##0.000 "TND";-#,##0.000 "TND";0.000 "TND"`)
```dax
Ecart_Dette_Simulation_TND = 
[Dette_Simulee_TND] - [Dette_Financiere_Points_TND]
```

---

### 📁 Dossier 08 : Dimension Magasins & Territoire (Bonus Pro Option B)

#### 8.1. Nombre de Points de Vente Actifs
* **Nom :** `[Nb_Magasins_Actifs]`
* **Format :** Nombre entier (`#,##0`)
```dax
Nb_Magasins_Actifs = 
DISTINCTCOUNT(Fait_Ventes_Fidelite[ID_Magasin])
```

#### 8.2. Chiffre d'Affaires par Magasin
* **Nom :** `[CA_Par_Magasin]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Par_Magasin = 
CALCULATE(
    [CA_Fidelite_Total]
)
```

#### 8.3. Part de Trafic Scanné par Magasin (%)
* **Nom :** `[Part_Trafic_Magasin_%]`
* **Format :** Pourcentage (`0.0 %`)
```dax
Part_Trafic_Magasin_% = 
DIVIDE(
    [Nb_Transactions],
    CALCULATE([Nb_Transactions], ALL(Dim_Magasin)),
    0
)
```

---

### 📁 Dossier 09 : Grossistes B2B & Profils Mixtes (Succursale vs Cafétéria)

#### 9.1. Chiffre d'Affaires Réalisé en Succursale vs Cafétéria
* **Nom :** `[CA_Succursale_Total]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Succursale_Total = 
CALCULATE(
    [CA_Fidelite_Total],
    Dim_Magasin[Type_Etablissement] = "Succursale"
)
```

* **Nom :** `[CA_Cafeteria_Total]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Cafeteria_Total = 
CALCULATE(
    [CA_Fidelite_Total],
    Dim_Magasin[Type_Etablissement] = "Cafétéria"
)
```

#### 9.2. Panier Moyen en Succursale vs Cafétéria
* **Nom :** `[Panier_Moyen_Succursale]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
Panier_Moyen_Succursale = 
CALCULATE(
    [Panier_Moyen_AOV],
    Dim_Magasin[Type_Etablissement] = "Succursale"
)
```

* **Nom :** `[Panier_Moyen_Cafeteria]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
Panier_Moyen_Cafeteria = 
CALCULATE(
    [Panier_Moyen_AOV],
    Dim_Magasin[Type_Etablissement] = "Cafétéria"
)
```

#### 9.3. Nombre de Clients Grossistes / B2B Détectés (Alerte Sous Surveillance)
* **Nom :** `[Nb_Clients_Grossistes]`
* **Format :** Nombre entier (`#,##0`)
* **Description :** Compte les clients réalisant des volumes de gros en succursale (ou profils mixtes suspectés).
```dax
Nb_Clients_Grossistes = 
CALCULATE(
    COUNTROWS(Dim_Client),
    Dim_Client[Flag_Grossiste_Suspect] = 1
)
```

#### 9.4. Part de Chiffre d'Affaires Générée par les Grossistes (%)
* **Nom :** `[Part_CA_Grossistes_%]`
* **Format :** Pourcentage (`0.0 %`)
```dax
Part_CA_Grossistes_% = 
VAR _CAGrossistes = 
    CALCULATE(
        [CA_Fidelite_Total],
        Dim_Client[Flag_Grossiste_Suspect] = 1
    )
RETURN
DIVIDE(_CAGrossistes, [CA_Fidelite_Total], 0)
```

---

### 📁 Dossier 10 : Fréquence Hebdomadaire & Clients Ultra-Fidèles (> 3 scans/semaine)

#### 10.1. Nombre de Clients Ultra-Fréquents (Passages $\ge$ 3 fois/semaine)
* **Nom :** `[Nb_Clients_Ultra_Frequents]`
* **Format :** Nombre entier (`#,##0`)
```dax
Nb_Clients_Ultra_Frequents = 
CALCULATE(
    COUNTROWS(Dim_Client),
    Dim_Client[Flag_Ultra_Frequent] = 1
)
```

#### 10.2. Part des Clients Ultra-Fréquents sur les Clients Actifs (%)
* **Nom :** `[Part_Clients_Ultra_Frequents_%]`
* **Format :** Pourcentage (`0.0 %`)
```dax
Part_Clients_Ultra_Frequents_% = 
DIVIDE(
    [Nb_Clients_Ultra_Frequents],
    [Nb_Clients_Actifs],
    0
)
```

#### 10.3. Chiffre d'Affaires Généré par les Clients Ultra-Fréquents
* **Nom :** `[CA_Clients_Ultra_Frequents]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
CA_Clients_Ultra_Frequents = 
CALCULATE(
    [CA_Fidelite_Total],
    Dim_Client[Flag_Ultra_Frequent] = 1
)
```

---

### 📁 Dossier 11 : Customer Lifetime Value (LTV Stratifiée) & Rentabilité Cadeaux

#### 11.1. LTV Moyenne Globale par Client Actif
* **Nom :** `[LTV_Moyenne_Actifs]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
* **Description :** Valeur cumulée moyenne générée sur la durée de vie du client sur l'application.
```dax
LTV_Moyenne_Actifs = 
DIVIDE(
    [CA_Fidelite_Total],
    [Nb_Clients_Actifs],
    0
)
```

#### 11.2. LTV par Segment de Consommation (LTV Stratifiée)
* **Nom :** `[LTV_Champions]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
LTV_Champions = 
CALCULATE(
    AVERAGE(Dim_Client[CA_Total]),
    Dim_Client[Segment_Client] = "Gros Consommateur (Champion)"
)
```

* **Nom :** `[LTV_Reguliers]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
LTV_Reguliers = 
CALCULATE(
    AVERAGE(Dim_Client[CA_Total]),
    Dim_Client[Segment_Client] = "Consommateur Régulier"
)
```

* **Nom :** `[LTV_Occasionnels]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
LTV_Occasionnels = 
CALCULATE(
    AVERAGE(Dim_Client[CA_Total]),
    Dim_Client[Segment_Client] = "Consommateur Occasionnel"
)
```

* **Nom :** `[LTV_Grossistes_B2B]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
```dax
LTV_Grossistes_B2B = 
CALCULATE(
    AVERAGE(Dim_Client[CA_Total]),
    Dim_Client[Flag_Grossiste_Suspect] = 1
)
```

#### 11.3. CA Moyen Dépensé avant Déblocage du Premier Cadeau
* **Nom :** `[CA_Moyen_Avant_1er_Cadeau]`
* **Format :** Monétaire (`#,##0.000 "TND"`)
* **Description :** Chiffre d'affaires réel généré par un client avant qu'il n'effectue son premier Burn (valeur observée réelle : 60,63 TND).
```dax
CA_Moyen_Avant_1er_Cadeau = 
CALCULATE(
    AVERAGE(Dim_Client[CA_Avant_Premier_Cadeau_TND]),
    Dim_Client[CA_Avant_Premier_Cadeau_TND] > 0
)
```

#### 11.4. Ratio Coût Cadeau vs CA Généré (Rentabilité de la Récompense %)
* **Nom :** `[Ratio_Rentabilite_Recompense_%]`
* **Format :** Pourcentage (`0.0 %`)
* **Description :** Part du CA redistribuée en cadeau (Provision moyenne / CA avant cadeau).
```dax
Ratio_Rentabilite_Recompense_% = 
VAR _CoutMoyenCadeauTND = 
    VAR _ClientsBrule = 
        CALCULATE(
            DISTINCTCOUNT(Fait_Mouvements_Points[ID_Client_Hache]),
            Fait_Mouvements_Points[Points] < 0
        )
    RETURN
    DIVIDE([Points_Burn_Consommes] * 0.010, _ClientsBrule, 0)
RETURN
DIVIDE(
    _CoutMoyenCadeauTND,
    [CA_Moyen_Avant_1er_Cadeau],
    0
)
```

---

## 📋 3. Matrice de Répartition des Mesures par Dashboard Power BI

| Dashboard Cible | Mesures Clés à Insérer | Visuels Recommandés |
| :--- | :--- | :--- |
| **Dashboard 1 : Cockpit Direction & CA** | • `[CA_Fidelite_Total]`<br>• `[Nb_Transactions]`<br>• `[Panier_Moyen_AOV]` (`[Panier_Moyen_Succursale]` vs `[Panier_Moyen_Cafeteria]`)<br>• `[Dette_Financiere_Points_TND]`<br>• `[Croissance_CA_MoM_%]`<br>• Mesures What-If de simulation | • Cartes KPI multi-lignes<br>• Graphique en aires (CA par jour/mois)<br>• Arbre de décomposition IA (Expliquer le CA par Segment > Gamme)<br>• Carte choroplèthe (Gouvernorats de Tunisie) |
| **Dashboard 2 : Segmentation, Habitudes & Grossistes** | • `[Nb_Clients_Actifs]`<br>• `[Taux_Activation_Clients_%]`<br>• `[Nb_Clients_Ultra_Frequents]` (> 3 scans/semaine)<br>• `[Nb_Clients_Grossistes]` & `[Part_CA_Grossistes_%]`<br>• `[LTV_Champions]`, `[LTV_Reguliers]`, `[LTV_Grossistes_B2B]`<br>• Filtre Slicer : `Profil_Reseau` (*Particulier* vs *Grossiste / Mixte*) | • Anneau / Treemap par `Segment_Client` & `Profil_Reseau`<br>• Barres comparatives du Panier Moyen par segment<br>• Nuage de points (Fréquence hebdo vs CA total)<br>• Table « Zoom Grossistes & B2B sous surveillance » |
| **Dashboard 3 : Cagnotte, LTV & Rentabilité Cadeaux** | • `[Points_Earn_Distribues]`<br>• `[Points_Burn_Consommes]`<br>• `[Ratio_Earn_Burn_%]`<br>• `[Solde_Points_En_Circulation]`<br>• `[CA_Moyen_Avant_1er_Cadeau]` (~60,6 TND)<br>• `[Ratio_Rentabilite_Recompense_%]`<br>• `[Nb_Clients_Risque_Churn]` | • Jauge tachymétrique (Ratio Earn & Burn cible 50%)<br>• Graphique en cascade (Points Earn $\rightarrow$ Burn $\rightarrow$ Solde)<br>• Histogramme du CA avant 1er cadeau par palier de récompense<br>• Table interactive des clients à risque (Alerte Churn avec bouton Push) |

---

## 🔒 4. Expressions DAX pour les Rôles de Sécurité (RLS)

Pour configurer les rôles dans **Modélisation** > **Gérer les rôles** :

### Rôle 1 : `Direction_Generale`
* **Accès :** Visualisation complète sans filtre (Particuliers + Grossistes + Toutes régions).
* **Expression DAX :** *(Laisser vide sur toutes les tables)*.

### Rôle 2 : `Equipe_Marketing_B2C`
* **Accès :** Focus sur les consommateurs particuliers de café (exclut les grossistes/revendeurs et les inactifs).
* **Filtre sur `Dim_Client` :**
```dax
[Segment_Client] <> "Inactif / Jamais scanné" && [Flag_Grossiste_Suspect] = 0
```

### Rôle 3 : `Equipe_Grands_Comptes_Grossistes`
* **Accès :** Suivi exclusif des profils B2B et revendeurs suspects pour négociation commerciale.
* **Filtre sur `Dim_Client` :**
```dax
[Flag_Grossiste_Suspect] = 1
```

### Rôle 4 : `Responsable_Region_Grand_Tunis`
* **Accès :** Filtre automatique sur les établissements du Grand Tunis (Menzah, Marsa, Liberté, etc.).
* **Filtre sur `Dim_Magasin` :**
```dax
[Region_Gouvernorat] = "Grand Tunis"
```
