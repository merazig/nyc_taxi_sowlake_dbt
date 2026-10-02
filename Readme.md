# 🚕 NYC Taxi Data Warehouse — Snowflake & dbt
Projet de Data Engineering réalisé autour des données **NYC Yellow Taxi 2025**.

L'objectif est de construire un Data Warehouse dans Snowflake permettant d'ingérer, nettoyer, enrichir, contrôler et analyser plusieurs dizaines de millions de trajets de taxis new-yorkais.

Le projet intègre également **dbt** pour structurer les transformations, automatiser les tests de qualité et générer la documentation, ainsi qu'un dashboard **Streamlit** pour la visualisation des principaux KPIs.

Enfin, un workflow **GitHub Actions** permet de vérifier automatiquement le projet dbt.

## 📋 Sommaire
- Objectifs

- Architecture

- Technologies

- Source des données

- 1. Ingestion des données

- 2. Architecture Snowflake

- 3. Nettoyage et transformation

- 4. Règles de qualité

- 5. Résultats

- 6. Analyses

- 7. Projet dbt

- 8. Tests dbt

- 9. Dashboard Streamlit

- 10. GitHub Actions

- 11. Structure du repository

- 12. Installation et reproduction

- 13. Sécurité

- 14. Conclusion

## 🎯 Objectifs
Les objectifs du projet sont :

- construire un Data Warehouse sous Snowflake ;

- travailler sur des données volumineuses au format Parquet ;

- séparer les différentes étapes du traitement des données ;

- nettoyer et contrôler la qualité des données ;

- créer des indicateurs analytiques ;

- structurer les transformations avec dbt ;

- automatiser les tests de qualité ;

- documenter les modèles ;

- créer un dashboard interactif ;

- versionner le projet avec Git ;

- mettre en place une première automatisation CI avec GitHub Actions.

## 🏗️ Architecture
L'architecture globale du projet est la suivante :
```
                Fichiers Parquet 2025
                         │
                         ▼
                ┌─────────────────┐
                │ Snowflake Stage │
                │     RAW         │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │     STAGING     │
                │ Nettoyage /     │
                │ standardisation │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │   INTERMEDIATE  │
                │ Enrichissements │
                │ analytiques     │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │      FINAL      │
                │ Tables analytiques
                └────────┬────────┘
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        Analyses SQL          Dashboard Streamlit
              │
              ▼
          Marts dbt
```
## 🛠️ Technologies
Les principales technologies utilisées sont :

Technologie | Utilisation
 --- | ---
Snowflake |	Data Warehouse
SQL |	Chargement, nettoyage et analyses
Parquet |	Format des données sources
Python |	Téléchargement des fichiers
dbt |	Transformation, tests et documentation
Streamlit |	Dashboard
Git / GitHub |	Versionnement
GitHub Actions |	CI du projet dbt

## 📊 Source des données
Les données utilisées sont les données publiques **NYC Yellow Taxi Trip Records**.

Source :

- NYC Taxi & Limousine Commission

- Fichiers mensuels au format Parquet

- Année analysée : **2025**

Les fichiers utilisés sont :
```
yellow_tripdata_2025-01.parquet
yellow_tripdata_2025-02.parquet
yellow_tripdata_2025-03.parquet
yellow_tripdata_2025-04.parquet
yellow_tripdata_2025-05.parquet
yellow_tripdata_2025-06.parquet
yellow_tripdata_2025-07.parquet
yellow_tripdata_2025-08.parquet
yellow_tripdata_2025-09.parquet
yellow_tripdata_2025-10.parquet
yellow_tripdata_2025-11.parquet
yellow_tripdata_2025-12.parquet
```
Les fichiers Parquet ne sont pas versionnés dans Git.

## 1. 📥 Ingestion des données
Un script Python permet de télécharger les fichiers Parquet mensuels.

Le script se trouve dans :
```
python/download_parquet.py
```
Le rôle de Python est volontairement limité au téléchargement des données.

Les transformations sont réalisées directement dans Snowflake avec SQL et dbt.

### Chargement dans Snowflake
Les fichiers ont été chargés manuellement dans **un stage interne Snowflake** :
```
NYC_TAXI_DB.RAW.NYC_TAXI_STAGE
```
Un File Format Parquet dédié a également été créé :
```
NYC_TAXI_DB.RAW.PARQUET_FORMAT
```
avec :
```
TYPE = PARQUET
```
La présence des fichiers dans le stage a été contrôlée avant le chargement.

## 2. ❄️ Architecture Snowflake
La base de données principale est :
```
NYC_TAXI_DB
```
Les trois schémas principaux sont :
```
NYC_TAXI_DB.RAW
NYC_TAXI_DB.STAGING
NYC_TAXI_DB.FINAL
```
### RAW
La couche RAW conserve les données provenant directement des fichiers Parquet.

Table principale :
```
NYC_TAXI_DB.RAW.YELLOW_TRIPS
```
Le chargement est effectué avec **COPY INTO**.
### STAGING
La couche STAGING prépare les données pour les traitements analytiques.

Table :
```
NYC_TAXI_DB.STAGING.YELLOW_TRIPS
```
Les principales colonnes utilisées sont notamment :
```
vendor_id
pickup_datetime
dropoff_datetime
trip_distance
pickup_location_id
dropoff_location_id
payment_type
fare_amount
tip_amount
total_amount
```
Certaines colonnes fortement incomplètes et non nécessaires aux analyses retenues ont été écartées.
### FINAL
La couche FINAL contient les données nettoyées et validées destinées aux analyses.

Table principale :
```
NYC_TAXI_DB.FINAL.YELLOW_TRIPS
```
## 3. 🧹 Nettoyage et transformation
Plusieurs transformations ont été réalisées.
### Gestion des timestamps
Les timestamps provenant du format Parquet ont été convertis explicitement :
```
TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)
```
et :
```
TO_TIMESTAMP_NTZ("tpep_dropoff_datetime", 6)
```
Cette conversion permet de disposer de véritables timestamps Snowflake exploitables dans les calculs temporels.
### Durée du trajet
La durée est calculée en secondes :
```
DATEDIFF(
    'second',
    pickup_datetime,
    dropoff_datetime
)
```
### Vitesse moyenne
La vitesse moyenne est calculée en miles par heure lorsque la durée et la distance sont valides.
```
distance > 0
ET
duration > 0
```
Sinon, la vitesse est définie à `NULL`.

### Jour de la semaine
Une dimension temporelle permet d'identifier :
```
Mon
Tue
Wed
Thu
Fri
Sat
Sun
```
### Weekday / Weekend
Une variable permet de distinguer :
```
Weekday
Weekend
```

### Période de la journée
Les trajets sont regroupés en cinq périodes :
```
night
morning
day
evening_rush
evening
```
La logique utilisée est :
```SQL
CASE
    WHEN HOUR(pickup_datetime) < 6
        THEN 'night'
    WHEN HOUR(pickup_datetime) < 12
        THEN 'morning'
    WHEN HOUR(pickup_datetime) < 18
        THEN 'day'
    WHEN HOUR(pickup_datetime) < 20
        THEN 'evening_rush'
    ELSE 'evening'
END
```
Cette catégorisation a été adaptée afin de disposer de cinq périodes temporelles exploitables dans les analyses.

### Catégories de distance
Les distances sont classées selon les catégories suivantes :
```
invalid
short
medium
long
very_long
```
avec notamment :
```
distance <= 0       → invalid
distance < 1        → short
distance < 5        → medium
distance < 10       → long
distance >= 10      → very_long
```

## 4. 🔎 Règles de qualité
La qualité des données a été analysée avant la constitution de la table finale.

Plusieurs anomalies ont été identifiées dans les données sources :
```
48 722 602 trajets observés
 2 870 234 trajets avec anomalie de montant
   980 522 trajets avec anomalie de distance
     2 037 autres anomalies identifiées
       906 autres contrôles/anomalies
45 849 304 trajets après filtrage
```
Un contrôle complémentaire a identifié :
```
29 trajets avec une date antérieure à 2025
```
Ces contrôles ont permis de définir les règles de filtrage de la couche FINAL.

### Règles appliquées
Les trajets conservés doivent respecter :
```
fare_amount > 0
AND total_amount > 0
AND trip_distance <= 1000
AND (
    trip_distance = 0
    OR fare_amount / trip_distance <= 10000
)
```
Les trajets avec une distance égale à zéro sont conservés afin de ne pas supprimer automatiquement une information potentiellement exploitable.

Les ratios tarif/distance extrêmement élevés sont considérés comme des anomalies.

## 5. 📈 Résultats
Après nettoyage et application des règles de qualité :
```
45 849 275 trajets
```
sont présents dans la table finale.

La période couverte est :
```
01/01/2025 → 31/12/2025
```

### KPIs globaux
KPI	| Valeur
--- | --- 
Nombre de trajets |	45 849 275
Chiffre d'affaires |	$1 325 793 722,17
Montant moyen |	$28,92
Pourboires |	$138 445 889,46
Pourboire moyen |	$3,02
Distance moyenne |	3,40 miles
Durée moyenne |	17,33 min
Vitesse moyenne |	11,31 mph

## 6. 📊 Analyses
Plusieurs analyses ont été réalisées à partir de la table finale.

### Évolution mensuelle
Les volumes mensuels sont :
Mois |	Trajets
--- | ---
Janvier |	3 329 561
Février |	3 393 280
Mars |	3 934 642
Avril |	3 782 082
Mai	 | 4 264 147
Juin |	4 045 163
Juillet |	3 650 249
Août |	3 311 245
Septembre |	3 996 343
Octobre |	4 105 093
Novembre |	3 783 645
Décembre |	4 253 825

### Weekday / Weekend
La répartition observée est :

Type de jour |	Trajets
--- | ---
Weekday |	32 782 000
Weekend	 | 13 067 275

Les indicateurs suivants ont été comparés :

- nombre de trajets ;

- chiffre d'affaires ;

- montant moyen ;

- pourboires ;

- distance moyenne ;

- durée moyenne ;

- vitesse moyenne.

### Analyse des périodes de la journée
Les résultats sont :

Période |	Trajets |	CA	| Montant moyen |	Pourboires |	Distance moyenne |	Durée moyenne |	Vitesse
--- | --- | --- | --- | --- | --- | --- | --- 
Night |	4 059 022 |	$116,14 M |	$28,61 |	$9,61 M |	4,09 mi	| 14,60 min |	15,59 mph
Morning |	5 666 109 |	$156,76 M |	$27,67 |	$14,97 M |	3,62 mi |	17,33 min |	12,21 mph
Day |	14 216 497	| $410,17 M |	$28,85 |	$45,65 M |	3,31 mi |	18,77 min |	9,98 mph
Evening rush |	12 029 821 |	$358,48 M |	$29,80 |	$38,94 M |	2,99 mi |	17,95 min |	9,87 mph
Evening |	9 877 826 |	$284,25 M |	$28,78 |	$29,28 M |	3,61 mi |	15,65 min |	12,63 mph

Cette analyse permet notamment de comparer les volumes, revenus, distances et vitesses selon les différentes périodes de la journée.

### Top trajets Pickup → Dropoff
Une analyse des couples de zones de départ et d'arrivée a été réalisée.

Les trajets les plus fréquents sont notamment :

Pickup |	Dropoff |	Trajets |	Part |	CA |	Montant moyen |	Distance |	Durée
--- | --- | --- | --- | --- | --- | --- | --- 
237	| 236	| 297 562	| 0,65 % |	$4 713 241 |	$15,84 |	1,03 mi |	7,65 min
236	| 237 |	254 528 |	0,56 % |	$4 123 240 |	$16,20 |	1,01 mi |	8,28 min
237 |	237 |	207 881 |	0,45 % |	$3 070 386 |	$14,77 |	0,61 mi |	5,82 min
236	| 236	| 191 562 |	0,42 % |	$2 647 288 |	$13,82 |	0,59 mi |	4,96 min
161 |	237 |	139 867 |	0,31 % |	$2 618 530 |	$18,72 |	1,05 mi |	10,41 min
237	| 161 |	130 385 |	0,28 % |	$2 414 309 |	$18,52 |	1,03 mi	| 10,54 min
161 |	236 |	113 098 |	0,25 % |	$2 650 480 |	$23,44 |	1,89 mi |	14,25 min
237 |	162 |	104 419 |	0,23 % |	$1 822 880 |	$17,46 |	0,96 mi |	9,26 min
142 |	239 |	103 076 |	0,22 % |	$1 567 024	| $15,20 |	0,97 mi |	6,38 min

L'analyse porte volontairement sur les **couples Pickup → Dropoff** plutôt que sur un classement indépendant des zones de pickup.

### Autres analyses
Le projet contient également des analyses concernant :

- les catégories de distance ;

- les types de paiement ;

- les périodes de la journée ;

- les jours de la semaine ;

- les zones de pickup ;

- les zones de dropoff ;

- les couples pickup/dropoff ;

- les revenus par zone.

## 7. 🧩 Projet dbt
Un projet dbt a été intégré directement dans Snowflake.

Le projet utilise :
```
dbt 1.9.4
Snowflake adapter 1.9.2
```
Le projet contient :
```
models/
tests/
macros/
analyses/
seeds/
snapshots/
```
Les modèles sont organisés en trois niveaux :
```
models/
├── staging/
├── intermediate/
└── marts/
```
### Staging
```
stg_yellow_trips
```
Matérialisation :
```
VIEW
```
### Intermediate
```
int_yellow_trips_enriched
```
Matérialisation :
```
VIEW
```
Cette couche contient les enrichissements analytiques.

### Marts
```
fct_yellow_trips
mart_dashboard_kpi
mart_monthly_kpi
mart_day_type_kpi
```
Matérialisation :
```
TABLE
```

## 8. 🧪 Tests dbt
Des tests de qualité ont été ajoutés au projet.

Les tests vérifient notamment :

- les catégories de distance ;

- les jours de la semaine ;

- les périodes temporelles ;

- les règles de qualité des trajets ;

- la période temporelle des données.

### Résultat
```
PASS = 5
WARN = 0
ERROR = 0
SKIP = 0
TOTAL = 5
```
Le pipeline dbt complet a également été exécuté avec succès :
```
PASS = 6
WARN = 0
ERROR = 0
SKIP = 0
TOTAL = 6
```
Le modèle factuel contient :
```
45 849 275 trajets
```
et correspond aux données finales produites dans Snowflake.

## 9. 📊 Dashboard Streamlit
Un dashboard Streamlit a été développé pour présenter les principaux KPIs.

Le dashboard utilise la session Snowflake active :
```python
from snowflake.snowpark.context import get_active_session

session = get_active_session()
```
Aucune connexion Snowflake externe n'est donc nécessaire depuis l'application.

Le dashboard présente notamment :

- nombre total de trajets ;

- chiffre d'affaires ;

- montant moyen ;

- pourboires ;

- distance moyenne ;

- durée moyenne ;

- vitesse moyenne ;

- évolution mensuelle ;

- comparaison Weekday / Weekend ;

- tableau récapitulatif mensuel.

Les principaux composants Streamlit utilisés sont :
```python
st.metric()
st.line_chart()
st.bar_chart()
st.dataframe()
```
Application :
```
streamlit/streamlit_app.py
```

## 10. ⚙️ GitHub Actions
Une pipeline CI a été mise en place avec GitHub Actions.

Architecture :
```
GitHub
   │
   │ Push / Pull Request
   ▼
GitHub Actions
   │
   ▼
Installation Python + dbt
   │
   ▼
Connexion Snowflake
   │
   ▼
dbt build
   │
   ├── Models
   └── Tests
   │
   ▼
SUCCESS / FAILURE
```
Les informations de connexion Snowflake sont stockées dans **GitHub Secrets**.

Les secrets utilisés sont :
```
SNOWFLAKE_ACCOUNT
SNOWFLAKE_DATABASE
SNOWFLAKE_PASSWORD
SNOWFLAKE_ROLE
SNOWFLAKE_USER
SNOWFLAKE_WAREHOUSE
```
Aucun mot de passe ou secret Snowflake n'est stocké dans le repository.

Le workflow a été exécuté avec succès.

## 11. 📁 Structure du repository
```
nyc-taxi-snowflake-dbt/
│
├── .gitignore
├── Readme.md
│
├── python/
│   └── download_parquet.py
│
├── sql/
│   ├── analysis.sql
│   ├── clean_staging.sql
│   ├── dashboard_views.sql
│   ├── load_raw.sql
│   └── transform_final.sql
│
├── dbt/
│   ├── dbt_project.yml
│   ├── packages.yml
│   │
│   ├── models/
│   │   ├── schema.yml
│   │   ├── staging/
│   │   │   ├── _sources.yml
│   │   │   └── stg_yellow_trips.sql
│   │   │
│   │   ├── intermediate/
│   │   │   └── int_yellow_trips_enriched.sql
│   │   │
│   │   └── marts/
│   │       ├── fct_yellow_trips.sql
│   │       ├── mart_dashboard_kpi.sql
│   │       ├── mart_day_type_kpi.sql
│   │       └── mart_monthly_kpi.sql
│   │
│   └── tests/
│       ├── fct_yellow_trips_date_range.sql
│       └── fct_yellow_trips_quality.sql
│
├── streamlit/
│   └── streamlit_app.py
│
└── .github/
    └── workflows/
        └── dbt.yml
```

## 12. 🚀 Installation et reproduction
### Prérequis
- Compte Snowflake

- Python 3.x

- Git

- dbt

- Accès au repository GitHub

### Cloner le repository
```
git clone https://github.com/merazig/nyc_taxi_sowlake_dbt.git
cd nyc_taxi_sowlake_dbt
```
### Environnement Python
Créer un environnement virtuel :
```
python -m venv env
```
Activer l'environnement sous Windows :
```
env\Scripts\activate
```
Installer les dépendances nécessaires.

### Télécharger les données
Le script :
```
python/download_parquet.py
```
permet de télécharger les fichiers Parquet.

Les fichiers sont ensuite chargés dans un stage interne Snowflake.

### Préparer Snowflake
Créer :
```
NYC_TAXI_DB
```
avec les schémas :
```
RAW
STAGING
FINAL
```
Créer également :
```
RAW.NYC_TAXI_STAGE
RAW.PARQUET_FORMAT
```
Puis charger les fichiers Parquet dans le stage.

### Exécuter les scripts SQL
Les principaux scripts sont :
```
sql/load_raw.sql
sql/clean_staging.sql
sql/transform_final.sql
sql/analysis.sql
sql/dashboard_views.sql
```
Ils permettent respectivement de :

1. charger les données RAW ;

2. nettoyer et préparer les données STAGING ;

3. construire la couche FINAL ;

4. effectuer les analyses ;

5. créer les vues nécessaires au dashboard historique.

### Exécuter dbt
Depuis le dossier dbt :
```
dbt compile --target dev
```
Puis :
```
dbt run --target dev
```
Et :
```
dbt test --target dev
```
Le pipeline complet peut également être exécuté avec :
```
dbt build --target dev
```

## 13. 🔐 Sécurité
Les informations sensibles ne sont pas versionnées.

Le fichier suivant est volontairement exclu :
```
dbt/profiles.yml
```
Les secrets et fichiers sensibles sont également ignorés :
```
.env
.streamlit/secrets.toml
*.key
*.pem
```
Les fichiers Parquet sont exclus :
```
*.parquet
```
Les fichiers temporaires dbt sont exclus :
```
dbt/target/
dbt/logs/
dbt/dbt_packages/
```
Les credentials utilisés par GitHub Actions sont stockés dans :
```
GitHub → Settings → Secrets and variables → Actions
```
## 14. 🏁 Conclusion
Ce projet permet de mettre en œuvre un pipeline complet de Data Engineering autour d'un volume important de données réelles.

Le pipeline final est :
```
NYC Taxi Parquet 2025
        │
        ▼
Snowflake Stage
        │
        ▼
RAW
        │
        ▼
STAGING
        │
        ▼
INTERMEDIATE
        │
        ▼
FINAL
        │
        ├──────────────► Analyses SQL
        │
        ├──────────────► Marts dbt
        │
        └──────────────► Dashboard Streamlit
                             
GitHub
   │
   ▼
GitHub Actions
   │
   ▼
dbt build
   │
   ▼
Tests qualité
```
Les principaux résultats obtenus sont :
```
45 849 275 trajets analysés
$1,325 Md de chiffre d'affaires
$138,4 M de pourboires
3,40 miles de distance moyenne
17,33 minutes de durée moyenne
11,31 mph de vitesse moyenne

dbt compile  → SUCCESS
dbt run      → 6/6 PASS
dbt test     → 5/5 PASS
GitHub Actions → SUCCESS
```
Le projet couvre ainsi les principales étapes d'un pipeline moderne :

**ingestion → stockage → transformation → qualité → analyse → visualisation → versionnement → CI.**