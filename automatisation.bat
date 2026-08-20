@echo off
REM ============================================================
REM  BI AUTOMATISATION (Windows) - Recrée toutes les bases + CSV
REM  Usage : double-clic sur automatisation.bat
REM  Prérequis : XAMPP installé dans C:\xampp
REM ============================================================

setlocal EnableDelayedExpansion
cd /d "%~dp0"

set MYSQL=C:\xampp\mysql\bin\mysql.exe
set MYSQLD=C:\xampp\mysql\bin\mysqld.exe

echo ==============================================
echo   AUTOMATISATION DES BASES BI
echo ==============================================

REM ---------- 1. Vérification MySQL ----------
echo.
echo [1/5] Verification de MariaDB...

"%MYSQL%" -u root -e "SELECT 1;" >nul 2>&1
if %errorlevel%==0 (
    echo       MariaDB deja demarre.
) else (
    echo       Demarrage de MariaDB...
    start /b "" "%MYSQLD%" --defaults-file=C:\xampp\mysql\bin\my.ini >nul 2>&1
    timeout /t 12 /nobreak >nul
    "%MYSQL%" -u root -e "SELECT 1;" >nul 2>&1
    if not %errorlevel%==0 (
        echo       ERREUR : impossible de demarrer MariaDB.
        echo       Demarre-le via XAMPP Control Panel puis relance.
        pause
        exit /b 1
    )
    echo       MariaDB demarre.
)

REM ---------- 2. Recréation des bases ----------
echo.
echo [2/5] Recreation des bases de donnees...

"%MYSQL%" -u root < "01_schema.sql" >nul 2>&1 && echo       bi_finance : schema OK
"%MYSQL%" -u root < "02_data.sql"   >nul 2>&1 && echo       bi_finance : donnees OK
"%MYSQL%" -u root < "03_ventes.sql" >nul 2>&1 && echo       bi_ventes  : OK
"%MYSQL%" -u root < "04_rh.sql"     >nul 2>&1 && echo       bi_rh      : OK

REM ---------- 3. Export CSV (via python si disponible) ----------
echo.
echo [3/5] Export des CSV...
where python >nul 2>&1
if %errorlevel%==0 (
    for %%b in (finance ventes rh) do if not exist "csv\%%b" mkdir "csv\%%b"

    for %%t in (dim_date dim_client dim_compte fact_transaction fact_budget v_flux_financier v_revenus_mensuels v_depenses_mensuelles v_budget_vs_reel) do (
        "%MYSQL%" -u root --batch --raw -e "SELECT * FROM bi_finance.%%t;" > csv\finance\%%t.tsv 2>nul
        python -c "import csv,sys; rows=list(csv.reader(open(r'csv\finance\%%t.tsv',encoding='utf-8-sig'),delimiter='\t')); csv.writer(open(r'csv\finance\%%t.csv','w',newline='',encoding='utf-8-sig')).writerows(rows)" 2>nul
        echo       finance\%%t.csv
    )
    for %%t in (dim_produit dim_vendeur fact_commande fact_ligne_commande fact_stock v_ventes_detail v_ventes_mensuelles v_ventes_produits v_performance_vendeurs v_stock_actuel) do (
        "%MYSQL%" -u root --batch --raw -e "SELECT * FROM bi_ventes.%%t;" > csv\ventes\%%t.tsv 2>nul
        python -c "import csv,sys; rows=list(csv.reader(open(r'csv\ventes\%%t.tsv',encoding='utf-8-sig'),delimiter='\t')); csv.writer(open(r'csv\ventes\%%t.csv','w',newline='',encoding='utf-8-sig')).writerows(rows)" 2>nul
        echo       ventes\%%t.csv
    )
    for %%t in (dim_departement dim_employe fact_paie fact_absence fact_formation v_effectif v_paie_mensuelle v_absences_mensuelles v_formations v_budget_rh_vs_reel) do (
        "%MYSQL%" -u root --batch --raw -e "SELECT * FROM bi_rh.%%t;" > csv\rh\%%t.tsv 2>nul
        python -c "import csv,sys; rows=list(csv.reader(open(r'csv\rh\%%t.tsv',encoding='utf-8-sig'),delimiter='\t')); csv.writer(open(r'csv\rh\%%t.csv','w',newline='',encoding='utf-8-sig')).writerows(rows)" 2>nul
        echo       rh\%%t.csv
    )
) else (
    echo       Python non trouve - export CSV ignore (les bases sont creees).
)

REM ---------- 4. Résumé ----------
echo.
echo [4/5] Resume des donnees...
"%MYSQL%" -u root -e "SELECT COUNT(*) AS 'Transactions finance' FROM bi_finance.fact_transaction; SELECT COUNT(*) AS 'Commandes ventes' FROM bi_ventes.fact_commande; SELECT COUNT(*) AS 'Employes RH' FROM bi_rh.dim_employe;" 2>nul

REM ---------- 5. Fin ----------
echo.
echo [5/5] Termine !
echo.
echo   Bases : bi_finance ^| bi_ventes ^| bi_rh (MariaDB, port 3306, user: root)
echo   CSV   : %~dp0csv\
echo   Power BI : Obtenir des donnees -^> Base de donnees MySQL -^> localhost:3306
echo ==============================================
pause