#!/bin/bash
# ============================================================
#  BI AUTOMATISATION - Recrée toutes les bases + exports CSV
#  Usage (WSL/Linux) :  ./automatisation.sh
#  -----------------------------------------------------------
#  1. Vérifie/démarre MariaDB (XAMPP)
#  2. Recrée les 3 bases : bi_finance, bi_ventes, bi_rh
#  3. Exporte toutes les tables et vues en CSV
#  4. Affiche le résumé des données
# ============================================================

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
MYSQL_BIN="/mnt/c/xampp/mysql/bin/mysql.exe"
MYSQLD_BIN="/mnt/c/xampp/mysql/bin/mysqld.exe"
DB_USER="root"
DB_PASS=""

rouge()   { echo -e "\033[0;31m$1\033[0m"; }
vert()    { echo -e "\033[0;32m$1\033[0m"; }
jaune()   { echo -e "\033[1;33m$1\033[0m"; }

echo "=============================================="
echo "  AUTOMATISATION DES BASES BI"
echo "=============================================="

# ---------- 1. Vérification MySQL ----------
echo ""
jaune "[1/5] Vérification de MariaDB..."

mysql_ok() {
    "$MYSQL_BIN" -u "$DB_USER" -e "SELECT 1;" >/dev/null 2>&1
}

if mysql_ok; then
    vert "      MariaDB déjà démarré (port 3306)."
else
    echo "      Démarrage de MariaDB (XAMPP)..."
    cmd.exe /c "cd /d C:\\xampp\\mysql\\bin && start /b mysqld.exe --defaults-file=C:\\xampp\\mysql\\bin\\my.ini" >/dev/null 2>&1 || true
    sleep 12
    if mysql_ok; then
        vert "      MariaDB démarré avec succès."
    else
        rouge "      ERREUR : impossible de démarrer MariaDB."
        echo "      Démarre-le via XAMPP Control Panel puis relance ce script."
        exit 1
    fi
fi

# ---------- 2. Recréation des bases ----------
echo ""
jaune "[2/5] Recréation des bases de données..."

"$MYSQL_BIN" -u "$DB_USER" < "$DIR/01_schema.sql" >/dev/null 2>&1
vert "      bi_finance  : schéma OK"
"$MYSQL_BIN" -u "$DB_USER" < "$DIR/02_data.sql"   >/dev/null 2>&1
vert "      bi_finance  : données OK"
"$MYSQL_BIN" -u "$DB_USER" < "$DIR/03_ventes.sql" >/dev/null 2>&1
vert "      bi_ventes   : OK"
"$MYSQL_BIN" -u "$DB_USER" < "$DIR/04_rh.sql"     >/dev/null 2>&1
vert "      bi_rh       : OK"

# ---------- 3. Export CSV ----------
echo ""
jaune "[3/5] Export des CSV..."

export_table() {
    local db="$1" table="$2" dossier="$3"
    "$MYSQL_BIN" -u "$DB_USER" --batch --raw -e "SELECT * FROM $db.$table;" 2>/dev/null \
        | python3 -c "
import csv, sys
rows = list(csv.reader(sys.stdin, delimiter='\t'))
with open('$dossier/$table.csv', 'w', newline='', encoding='utf-8-sig') as f:
    csv.writer(f).writerows(rows)
print('      $table : %d lignes' % (len(rows)-1))"
}

mkdir -p "$DIR/csv/finance" "$DIR/csv/ventes" "$DIR/csv/rh"

for t in dim_date dim_client dim_compte fact_transaction fact_budget \
         v_flux_financier v_revenus_mensuels v_depenses_mensuelles v_budget_vs_reel; do
    export_table bi_finance "$t" "$DIR/csv/finance"
done

for t in dim_produit dim_vendeur fact_commande fact_ligne_commande fact_stock \
         v_ventes_detail v_ventes_mensuelles v_ventes_produits v_performance_vendeurs v_stock_actuel; do
    export_table bi_ventes "$t" "$DIR/csv/ventes"
done

for t in dim_departement dim_employe fact_paie fact_absence fact_formation \
         v_effectif v_paie_mensuelle v_absences_mensuelles v_formations v_budget_rh_vs_reel; do
    export_table bi_rh "$t" "$DIR/csv/rh"
done

# ---------- 4. Résumé ----------
echo ""
jaune "[4/5] Résumé des données..."
"$MYSQL_BIN" -u "$DB_USER" -e "
SELECT 'FINANCE' AS base, CONCAT('Transactions : ', COUNT(*)) AS info FROM bi_finance.fact_transaction
UNION ALL SELECT 'FINANCE', CONCAT('Revenus : ', FORMAT(SUM(CASE WHEN type_flux='REVENU' AND statut='VALIDE' THEN montant END),0)) FROM bi_finance.v_flux_financier
UNION ALL SELECT 'FINANCE', CONCAT('Dépenses : ', FORMAT(SUM(CASE WHEN type_flux='DEPENSE' AND statut='VALIDE' THEN montant END),0)) FROM bi_finance.v_flux_financier
UNION ALL SELECT 'VENTES', CONCAT('Commandes : ', COUNT(*)) FROM bi_ventes.fact_commande
UNION ALL SELECT 'VENTES', CONCAT('CA : ', FORMAT(SUM(montant_ligne),0)) FROM bi_ventes.v_ventes_detail
UNION ALL SELECT 'RH', CONCAT('Employés : ', COUNT(*)) FROM bi_rh.dim_employe
UNION ALL SELECT 'RH', CONCAT('Masse salariale : ', FORMAT(SUM(salaire_brut),0)) FROM bi_rh.fact_paie;" 2>/dev/null

# ---------- 5. Fin ----------
echo ""
vert "[5/5] Terminé !"
echo ""
echo "  Bases : bi_finance | bi_ventes | bi_rh (MariaDB, port 3306, user: root)"
echo "  CSV   : $DIR/csv/"
echo "  Power BI : Obtenir des données -> Base de données MySQL -> localhost:3306"
echo "=============================================="