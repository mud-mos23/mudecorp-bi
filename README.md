# 📊 Dashboards BI — Mudecorp International SA

Trois dashboards Power BI sur des données fictives (01/01/2024 → 31/12/2027).

| Dashboard | Base MySQL | Contenu |
|---|---|---|
| **Finance** | `bi_finance` | ~11 000 transactions, 65 clients, budget vs réalisé |
| **Ventes** | `bi_ventes` | ~7 400 commandes, ~22 000 lignes, 35 produits, 12 vendeurs |
| **RH** | `bi_rh` | 120 employés, 4 464 lignes de paie, absences, formations |

## ⚡ 0. Tout régénérer en 1 commande

```bash
# WSL / Linux
./automatisation.sh

# Windows (double-clic)
automatisation.bat
```

Le script : démarre MariaDB si besoin → recrée les 3 bases → exporte les 29 CSV → affiche le résumé.
⚠️ Compte ~7 minutes (génération de 4 ans de données aléatoires).

---

## 🗄️ 1. Les bases MySQL (MariaDB 10.4, port 3306, user `root` sans mot de passe)

### Scripts

| Fichier | Contenu |
|---|---|
| `01_schema.sql` | Schéma `bi_finance` (tables + contraintes) |
| `02_data.sql` | Données finance + vues analytiques |
| `03_ventes.sql` | Base `bi_ventes` complète (schéma + données + vues) |
| `04_rh.sql` | Base `bi_rh` complète (schéma + données + vues) |

### Schéma Finance (étoile)

| Table | Type | Contenu |
|---|---|---|
| `dim_date` | Dimension | Calendrier 2024→2027 (année, mois, trimestre, weekend) |
| `dim_client` | Dimension | 65 clients (secteur, région, ville, segment) |
| `dim_compte` | Dimension | Plan comptable (15 comptes, groupes) |
| `fact_transaction` | Fait | ~11 000 transactions (montant, mode de paiement, statut) |
| `fact_budget` | Fait | Budget mensuel par compte (720 lignes) |

### Schéma Ventes

| Table | Type | Contenu |
|---|---|---|
| `dim_produit` | Dimension | 35 produits (catégorie, prix, coût, fournisseur) |
| `dim_vendeur` | Dimension | 12 vendeurs (région, ville, équipe) |
| `dim_client` | Dimension | 40 clients |
| `fact_commande` | Fait | ~7 400 commandes (canal, statut, montant) |
| `fact_ligne_commande` | Fait | ~22 000 lignes (quantité, prix, remise) |
| `fact_stock` | Fait | ~21 000 mouvements de stock |

### Schéma RH

| Table | Type | Contenu |
|---|---|---|
| `dim_departement` | Dimension | 10 départements (directeur, localisation, budget annuel) |
| `dim_employe` | Dimension | 120 employés (poste, contrat, salaire base, statut) |
| `fact_paie` | Fait | 4 464 bulletins mensuels (brut, primes, impôts, net) |
| `fact_absence` | Fait | ~280 absences (type, durée, motif) |
| `fact_formation` | Fait | ~2 900 formations (thème, type, durée, coût) |

### Vues prêtes pour Power BI

**Finance :** `v_flux_financier` (principale), `v_revenus_mensuels`,
`v_depenses_mensuelles`, `v_budget_vs_reel`

**Ventes :** `v_ventes_detail` (principale), `v_ventes_mensuelles`,
`v_ventes_produits`, `v_performance_vendeurs`, `v_stock_actuel`

**RH :** `v_effectif`, `v_paie_mensuelle`, `v_absences_mensuelles`,
`v_formations`, `v_budget_rh_vs_reel`

### Exports CSV (import direct sans MySQL)
- `csv/finance/` — 9 fichiers (tables + vues Finance)
- `csv/ventes/` — 10 fichiers (tables + vues Ventes)
- `csv/rh/` — 10 fichiers (tables + vues RH)

---

## 🔌 2. Ouvrir le dashboard dans Power BI

### Option A — Fichier Power BI fourni (RECOMMANDÉ)

Deux fichiers prêts à ouvrir sont fournis :

| Fichier | Type | Comment l'ouvrir |
|---|---|---|
| `MudecorpFinance.pbip` | **Projet Power BI** (dossier) | Power BI Desktop → **Fichier → Ouvrir → Power BI project (.pbip)** → sélectionner le fichier `MudecorpFinance.pbip` DANS le dossier |

> ⚠️ **N'ouvrez PAS un `.pbix`** : le seul fichier ouvrable est le **`.pbip`** (dossier
> `MudecorpFinance.pbip/` contenant le fichier `MudecorpFinance.pbip`). Le `.pbix` binaire
> ne peut être créé que par Power BI Desktop lui-même (Fichier → Enregistrer sous).

**Le `.pbip`** est le format moderne (texte + TMDL + PBIR) : tout est lisible dans un éditeur. Il contient :
- le **modèle sémantique** (`MudecorpFinance.SemanticModel/`) : 3 tables importées depuis MySQL (`FluxFinancier`, `Calendrier`, `BudgetVsReel`), 11 mesures DAX, 1 relation
- le **rapport** (`MudecorpFinance.Report/`) : 3 pages et 14 visuals déjà placés

### ✅ Prérequis avant d'ouvrir le `.pbip`

Le format `.pbip` est un **aperçu (preview)** : il nécessite Power BI Desktop de juillet 2025 ou plus récent
et les fonctionnalités d'aperçu activées :

1. Power BI Desktop → **Fichier → Options et paramètres → Options**
2. Onglet **Fonctionnalités en préversion (Preview features)**
3. Activer :
   - **Power BI project (.pbip) save option**
   - **Store semantic model using TMDL format**
4. **OK** → redémarrer Power BI Desktop

À l'ouverture, Power BI demandera les identifiants MySQL :
- Serveur : `localhost:3306` — Base : `bi_finance` — User : `root` (sans mot de passe)

> 💡 Pour obtenir un `.pbix` : ouvrir le `.pbip` dans Power BI Desktop, puis
> **Fichier → Enregistrer sous → .pbix**.

### Option B — MySQL direct (créer ses propres pages)
1. Démarrer MySQL : XAMPP Control Panel → **Start** sur *MySQL*
2. Power BI Desktop → **Obtenir des données** → **Base de données MySQL**
3. Serveur : `localhost:3306` — Base : `bi_finance` ou `bi_ventes` ou `bi_rh`
4. Utilisateur `root` (sans mot de passe) → OK

### Option C — Script Power Query fourni
1. **Transformer les données** → Éditeur Power Query → **Nouvelle source** → **Requête vide**
2. Coller `chargement_finance.pq` ou `chargement_ventes.pq`
3. Modifier `CheminCSV` ou passer `ModeSource = "MySQL"` puis **Utiliser**

### Option D — Import CSV manuel
**Obtenir des données** → **Texte/CSV** → importer les fichiers de `csv/finance/`, `csv/ventes/` ou `csv/rh/`

---

## 🧮 3. Mesures DAX — Dashboard Finance

```dax
Total Revenus = CALCULATE(SUM(v_flux_financier[montant]),
    v_flux_financier[type_flux] = "REVENU", v_flux_financier[statut] = "VALIDE")

Total Dépenses = CALCULATE(SUM(v_flux_financier[montant]),
    v_flux_financier[type_flux] = "DEPENSE", v_flux_financier[statut] = "VALIDE")

Résultat Net = [Total Revenus] - [Total Dépenses]
Marge Nette % = DIVIDE([Résultat Net], [Total Revenus], 0)
Nb Transactions = COUNT(v_flux_financier[tx_id])
Panier Moyen = DIVIDE([Total Revenus], [Nb Transactions])

Réalisation Budget % = DIVIDE([Total Dépenses],
    SUM(v_budget_vs_reel[budget]), 0)

Revenus Mois Précédent = CALCULATE([Total Revenus],
    PREVIOUSMONTH(v_flux_financier[date_tx]))
Variation Revenus % = DIVIDE([Total Revenus] - [Revenus Mois Précédent],
    [Revenus Mois Précédent], 0)
```

## 🧮 4. Mesures DAX — Dashboard Ventes

```dax
Chiffre d'affaires = SUM(v_ventes_detail[montant_ligne])
Marge brute = SUM(v_ventes_detail[marge_brute])
Taux de marge % = DIVIDE([Marge brute], [Chiffre d'affaires], 0)
Nb Commandes = DISTINCTCOUNT(v_ventes_detail[commande_id])
Panier moyen = DIVIDE([Chiffre d'affaires], [Nb Commandes])
Remise moyenne % = AVERAGE(v_ventes_detail[remise_pct])
Articles vendus = SUM(v_ventes_detail[quantite])

CA Mois Précédent = CALCULATE([Chiffre d'affaires],
    PREVIOUSMONTH(v_ventes_detail[date_commande]))
Variation CA % = DIVIDE([Chiffre d'affaires] - [CA Mois Précédent],
    [CA Mois Précédent], 0)
```

## 🧮 5. Mesures DAX — Dashboard RH

```dax
Effectif = COUNT(v_effectif[employe_id])
Masse salariale brute = SUM(v_paie_mensuelle[masse_salariale_brute])
Masse salariale nette = SUM(v_paie_mensuelle[masse_salariale_nette])
Total Primes = SUM(v_paie_mensuelle[total_primes])
Salaire moyen = DIVIDE([Masse salariale brute], [Effectif], 0)

Nb Absences = SUM(v_absences_mensuelles[nb_absences])
Jours perdus = SUM(v_absences_mensuelles[jours_perdus])
Taux d'absentéisme % = DIVIDE([Jours perdus],
    [Effectif] * 260, 0)

Heures de formation = SUM(v_formations[duree_heures])
Coût formation = SUM(v_formations[cout])
Coût formation par employé = DIVIDE([Coût formation], [Effectif], 0)

Réalisation budget RH % = DIVIDE([Masse salariale brute],
    SUM(v_budget_rh_vs_reel[budget_annuel]), 0)
```

---

## 📈 6. Structure des dashboards (3 pages chacun)

### Finance
1. **Vue d'ensemble** — 4 KPI (Revenus, Dépenses, Résultat, Marge), courbes Revenus vs Dépenses par mois, gauge budget
2. **Revenus** — matrice groupe × mois, Top 10 clients, anneau mode de paiement, barres par secteur
3. **Dépenses & Budget** — barres par groupe, table budget vs réalisé, treemap par région

### Ventes
1. **Vue d'ensemble** — 4 KPI (CA, Marge, Commandes, Panier moyen), courbes CA par mois, gauge taux de marge
2. **Produits & Catégories** — barres CA par catégorie, top produits, treemap sous-catégories, stock actuel (alerte rupture)
3. **Vendeurs & Clients** — barres CA par vendeur, matrice vendeur × mois, top clients, répartition par canal (DIRECT/EN_LIGNE/GROSSISTE/PARTENAIRE)

### RH
1. **Vue d'ensemble** — 4 KPI (Effectif, Masse salariale, Salaire moyen, Réalisation budget), courbes masse salariale par mois, gauge budget RH
2. **Effectifs** — barres effectif par département, donut par contrat, répartition par genre, ancienneté
3. **Absences & Formations** — barres jours perdus par mois/type, matrice absences par département, coût formation par type, top thèmes de formation

---

## 🛠️ 7. Recréer les bases depuis zéro

```bash
# MySQL démarré (XAMPP)
mysql -u root < 01_schema.sql   # base bi_finance (schéma)
mysql -u root < 02_data.sql     # base bi_finance (données + vues)
mysql -u root < 03_ventes.sql   # base bi_ventes (tout)
mysql -u root < 04_rh.sql       # base bi_rh (tout)
```

> Les scripts sont réexécutables : ils réinitialisent et régénèrent les données.
> ⚠️ Les montants varient à chaque exécution (génération aléatoire RAND()).
> Astuce : pour changer l'échelle, modifier les montants/quantités dans les
> procédures `gen_transactions` (02_data.sql), `gen_ventes` (03_ventes.sql)
> et `gen_paie`/`gen_absences`/`gen_formations` (04_rh.sql).