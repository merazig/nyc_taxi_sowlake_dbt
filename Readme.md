NYC Taxi Data Warehouse — Snowflake & dbt
Projet de Data Engineering réalisé à partir des données NYC Yellow Taxi 2025.

L'objectif de ce projet est de construire un Data Warehouse analytique dans Snowflake, de transformer et contrôler les données avec SQL et dbt, puis de restituer les principaux indicateurs à travers un dashboard Streamlit.

Le projet traite les 12 fichiers mensuels de janvier à décembre 2025.

Après application des règles de qualité, le dataset final contient :

45 849 275 trajets

🎯 Objectifs du projet
Les objectifs principaux sont :

intégrer les données NYC Yellow Taxi au format Parquet dans Snowflake ;

construire une architecture Data Warehouse en couches RAW, STAGING et FINAL ;

nettoyer et standardiser les données ;

créer des indicateurs analytiques ;

appliquer des règles de qualité des données ;

reproduire et structurer les transformations avec dbt ;

mettre en place des tests dbt ;

documenter les modèles dbt ;

créer des marts analytiques ;

développer un dashboard Streamlit connecté à Snowflake ;

versionner le code avec Git.

🏗️ Architecture du projet
L'architecture globale est la suivante :

Fichiers Parquet NYC Taxi
          │
          ▼
  Snowflake Internal Stage
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
          ▼
       Marts dbt
          │
          ▼
  Dashboard Streamlit

Cette architecture permet de séparer clairement :

les données brutes ;

les données nettoyées ;

les transformations analytiques ;

les données finales ;

les restitutions analytiques.

🛠️ Technologies utilisées
Technologie	Utilisation
Snowflake	Data Warehouse et traitement SQL
SQL	Chargement, nettoyage, transformation et analyse
Parquet	Format des données sources
Python	Téléchargement des fichiers
dbt	Transformation, tests et documentation
Streamlit	Dashboard interactif
Git / GitHub	Versionnement du code

📊 Source des données
Le projet utilise les données NYC Yellow Taxi Trip Records, publiées par la New York City Taxi & Limousine Commission (TLC).

Les données sont fournies sous forme de fichiers Parquet mensuels.

Les fichiers utilisés sont :

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

Les données contiennent notamment :

les dates et heures de pickup et dropoff ;

la distance du trajet ;

les zones de départ et d'arrivée ;

le type de paiement ;

le tarif ;

les pourboires ;

le montant total ;

le fournisseur du service.

❄️ Architecture Snowflake
La base principale est :

NYC_TAXI_DB

Les trois schémas principaux sont :

NYC_TAXI_DB
│
├── RAW
├── STAGING
└── FINAL

RAW
La couche RAW contient les données provenant directement des fichiers Parquet.

Les principaux objets sont :

NYC_TAXI_DB.RAW.NYC_TAXI_STAGE
NYC_TAXI_DB.RAW.PARQUET_FORMAT
NYC_TAXI_DB.RAW.YELLOW_TRIPS

Un stage interne Snowflake a été créé afin de stocker les fichiers Parquet.

Les 12 fichiers mensuels ont été uploadés manuellement dans ce stage.

La couche RAW conserve les données sources avant les transformations analytiques.

STAGING
La couche STAGING prépare les données pour les transformations analytiques.

Table principale :

NYC_TAXI_DB.STAGING.YELLOW_TRIPS

Les principales transformations réalisées sont :

conversion des timestamps ;

standardisation des colonnes ;

calcul de la durée ;

création des dimensions temporelles ;

calcul de la vitesse ;

catégorisation des distances ;

préparation des indicateurs financiers.

FINAL
La couche FINAL contient les données nettoyées et validées destinées aux analyses.

Table principale :

NYC_TAXI_DB.FINAL.YELLOW_TRIPS

Le dataset final contient :

45 849 275 trajets

et couvre :

01/01/2025 → 31/12/2025

🧹 Nettoyage et qualité des données
Plusieurs règles de qualité ont été appliquées.

Validation des montants
Les trajets conservés doivent respecter :

fare_amount > 0
AND total_amount > 0

Les montants nuls ou négatifs sont donc exclus de la table finale.

Validation des distances
Les trajets dont la distance est supérieure à :

1000 miles

sont considérés comme des valeurs extrêmes et sont exclus de FINAL.

Les trajets avec :

trip_distance = 0

sont conservés afin de ne pas supprimer inutilement des données.

Ratio tarif / distance
Le ratio suivant a également été contrôlé :

fare_amount / trip_distance

Les trajets présentant un ratio supérieur à :

10 000 $ / mile

sont considérés comme des anomalies extrêmes et sont exclus.

Lorsque trip_distance = 0, le ratio n'est pas calculé.

Validation des dates
Les données finales sont limitées à l'année 2025 :

2025-01-01 → 2025-12-31

🔧 Enrichissement des données
Plusieurs indicateurs analytiques ont été ajoutés.

Durée du trajet
La durée est calculée en secondes avec :

DATEDIFF(
    'second',
    pickup_datetime,
    dropoff_datetime
)

Elle peut ensuite être convertie en minutes pour les analyses.

Vitesse moyenne
La vitesse moyenne est calculée en miles par heure lorsque :

durée > 0
ET
distance > 0

Dans les autres cas, la valeur est NULL.

Jour de la semaine
Une dimension pickup_day_name permet de classer les trajets selon :

Mon
Tue
Wed
Thu
Fri
Sat
Sun

Weekday / Weekend
Les trajets sont également classés en :

Weekday
Weekend

Périodes de la journée
La classification finale suit le découpage du brief :

00h–05h → night
06h–09h → morning
10h–15h → day
16h–19h → evening_rush
20h–23h → evening

Cette dimension permet notamment d'analyser les volumes, revenus, distances, durées et vitesses selon la période de la journée.

Catégories de distance
Les trajets sont classés selon les règles suivantes :

invalid       distance <= 0
short         distance < 1
medium        distance < 5
long          distance < 10
very_long     distance >= 10

📈 KPIs globaux
Les principaux KPIs calculés sur le dataset final sont :

KPI	Valeur
Nombre de trajets	45 849 275
Chiffre d'affaires	1 325 793 722,17 $
Montant moyen	28,92 $
Total des pourboires	138 445 889,46 $
Pourboire moyen	3,02 $
Distance moyenne	3,40 miles
Durée moyenne	17,33 minutes
Vitesse moyenne	11,31 mph

📅 Analyse mensuelle
Les 12 mois de 2025 sont présents dans les données finales.

Mois	Nombre de trajets
Janvier	3 329 561
Février	3 393 280
Mars	3 934 642
Avril	3 782 082
Mai	4 264 147
Juin	4 045 163
Juillet	3 650 249
Août	3 311 245
Septembre	3 996 343
Octobre	4 105 093
Novembre	3 783 645
Décembre	4 253 825

🗓️ Analyse Weekday / Weekend
La répartition des trajets est :

Type de jour	Nombre de trajets
Weekday	32 782 000
Weekend	13 067 275

Les analyses permettent de comparer notamment :

le nombre de trajets ;

le chiffre d'affaires ;

le montant moyen ;

les pourboires ;

la distance moyenne ;

la durée moyenne ;

la vitesse moyenne.

🔎 Analyses SQL
Plusieurs analyses ont été réalisées à partir de la table FINAL.

Elles portent notamment sur :

les volumes mensuels ;

les périodes de la journée ;

les jours de la semaine ;

Weekday / Weekend ;

les types de paiement ;

les zones de pickup ;

les zones de dropoff ;

les couples pickup / dropoff ;

les revenus par zone ;

les catégories de distance ;

les indicateurs opérationnels.

Les scripts SQL sont regroupés dans :

sql/

🧱 Projet dbt
Un projet dbt a été créé et exécuté directement dans Snowflake Workspace.

Le projet est organisé en trois niveaux :

dbt/
│
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
│
├── tests/
├── macros/
├── analyses/
├── seeds/
└── snapshots/

Modèles Staging
stg_yellow_trips

Matérialisation :

VIEW

Ce modèle constitue la première étape de transformation dans dbt.

Modèle Intermediate
int_yellow_trips_enriched

Matérialisation :

VIEW

Ce modèle contient les enrichissements analytiques :

durée ;

vitesse ;

jour ;

type de jour ;

période ;

catégorie de distance.

Modèles Marts
Les modèles analytiques sont :

fct_yellow_trips
mart_dashboard_kpi
mart_monthly_kpi
mart_day_type_kpi

Ils sont matérialisés en :

TABLE

Le modèle factuel contient :

45 849 275 trajets

🧪 Tests dbt
Une suite de tests a été mise en place afin de contrôler la qualité des données.

Les tests vérifient notamment :

les catégories de distance ;

les jours de la semaine ;

les périodes temporelles ;

la qualité de la table factuelle ;

la plage de dates.

Les tests métier sont :

fct_yellow_trips_quality
fct_yellow_trips_date_range

Le dernier dbt test exécuté donne :

PASS = 5
WARN = 0
ERROR = 0
SKIP = 0
TOTAL = 5

Le dernier dbt run donne :

PASS = 6
WARN = 0
ERROR = 0
SKIP = 0
TOTAL = 6

Le projet a également été compilé avec succès :

dbt compile → SUCCESS

📚 Documentation dbt
Les modèles et les principales colonnes sont documentés dans :

dbt/models/schema.yml

La documentation dbt a été générée avec succès.

Le projet reconnaît actuellement :

6 models
5 data tests
1 source

La documentation permet notamment de décrire :

les modèles ;

les colonnes ;

les indicateurs calculés ;

les règles métier ;

les dépendances entre transformations.

📊 Dashboard Streamlit
Un dashboard Streamlit a été développé pour présenter les principaux résultats.

L'application utilise la session Snowflake active :

from snowflake.snowpark.context import get_active_session

session = get_active_session()

Aucune connexion externe à Snowflake n'est donc nécessaire.

Le dashboard présente notamment :

les KPIs globaux ;

le chiffre d'affaires ;

le nombre de trajets ;

le montant moyen ;

les pourboires ;

la distance moyenne ;

la durée moyenne ;

la vitesse moyenne ;

l'évolution mensuelle ;

la comparaison Weekday / Weekend ;

un tableau récapitulatif mensuel.

Les principaux composants Streamlit utilisés sont :

st.metric()
st.line_chart()
st.bar_chart()
st.dataframe()

L'application est située dans :

streamlit/streamlit_app.py

📁 Structure du repository
nyc_taxi_snowflake_dbt/
│
├── .gitignore
├── README.md
├── test.ipynb
│
├── data/
│   ├── jeudi.md
│   ├── plan.md
│   └── wen.md
│
├── dbt/
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── profiles.yml
│   │
│   ├── models/
│   │   ├── schema.yml
│   │   ├── _sources.yml
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   │
│   └── tests/
│
├── python/
│   └── download_parquet.py
│
├── sql/
│   ├── load_raw.sql
│   ├── clean_staging.sql
│   ├── transform_final.sql
│   ├── analysis.sql
│   └── dashboard_views.sql
│
└── streamlit/
    └── streamlit_app.py

🚀 Reproduction du projet
Prérequis
Pour reproduire le projet, il faut notamment :

un compte Snowflake ;

un warehouse Snowflake ;

Python ;

dbt avec l'adaptateur Snowflake ;

Git.

1. Télécharger les données
Le script Python utilisé pour télécharger les fichiers est :

python/download_parquet.py

Les fichiers Parquet sont ensuite disponibles localement avant leur upload dans Snowflake.

Les fichiers Parquet ne sont pas destinés à être versionnés dans Git en raison de leur taille.

2. Préparer Snowflake
Créer la base et les schémas :

CREATE DATABASE NYC_TAXI_DB;

CREATE SCHEMA NYC_TAXI_DB.RAW;
CREATE SCHEMA NYC_TAXI_DB.STAGING;
CREATE SCHEMA NYC_TAXI_DB.FINAL;

Créer ensuite le stage interne et le File Format Parquet.

Les fichiers mensuels sont uploadés dans le stage Snowflake.

3. Charger les données RAW
Le script :

sql/load_raw.sql

permet de charger les données Parquet dans :

NYC_TAXI_DB.RAW.YELLOW_TRIPS

4. Construire STAGING et FINAL
Les transformations SQL principales sont :

sql/clean_staging.sql
sql/transform_final.sql

Les analyses sont disponibles dans :

sql/analysis.sql

Les vues destinées au dashboard historique sont définies dans :

sql/dashboard_views.sql

⚙️ Exécution dbt
Le projet dbt se trouve dans :

dbt/

La configuration utilise Snowflake avec :

Warehouse : COMPUTE_WH
Database  : NYC_TAXI_DB
Schema    : DBT_DEV
Threads   : 8
Target    : dev

Le projet a été exécuté directement dans Snowflake Workspace.

Les commandes utilisées sont :

dbt compile --target dev
dbt run --target dev
dbt test --target dev

Résultats :

dbt compile → SUCCESS
dbt run     → 6/6 PASS
dbt test    → 5/5 PASS

🔐 Gestion des fichiers sensibles
Les fichiers contenant des informations sensibles ne doivent pas être versionnés.

Le .gitignore doit notamment exclure :

.env
.streamlit/secrets.toml
*.key
*.pem

Les fichiers générés par dbt doivent également être exclus :

dbt/target/
dbt/logs/
dbt/dbt_packages/

Les fichiers Parquet sont exclus du repository :

*.parquet

Le profil dbt contenant des informations d'authentification ne doit pas être publié s'il contient des credentials sensibles.

📌 État du projet
Élément	État
Base Snowflake	✅ Terminé
Schéma RAW	✅ Terminé
Schéma STAGING	✅ Terminé
Schéma FINAL	✅ Terminé
Stage interne	✅ Terminé
File Format Parquet	✅ Terminé
Chargement des données	✅ Terminé
Transformations SQL	✅ Terminé
Analyse qualité	✅ Terminé
Analyses SQL	✅ Terminé
Projet dbt	✅ Terminé
Modèles dbt	✅ Terminé
Tests dbt	✅ 5/5
Documentation dbt	✅ Générée
Dashboard Streamlit	✅ Terminé
Repository GitHub	🟡 Finalisation
GitHub Actions	⭕ Non implémenté

🔄 Orchestration
L'orchestration avec GitHub Actions faisait partie des options avancées du brief.

Elle n'a pas été implémentée dans cette version du projet.

Le projet se concentre sur le pipeline principal :

Ingestion
   ↓
Snowflake
   ↓
RAW
   ↓
STAGING
   ↓
INTERMEDIATE
   ↓
FINAL
   ↓
dbt
   ↓
Tests qualité
   ↓
Marts analytiques
   ↓
Streamlit

🎓 Conclusion
Ce projet met en œuvre un pipeline complet de Data Engineering autour des données NYC Yellow Taxi 2025.

Il permet de passer de fichiers Parquet bruts à un Data Warehouse structuré dans Snowflake, puis à des modèles analytiques testés avec dbt et à un dashboard Streamlit.

Le dataset final contient :

45 849 275 trajets

Le projet met en œuvre :

une architecture Data Warehouse en couches ;

l'ingestion de fichiers Parquet dans Snowflake ;

des transformations SQL ;

des règles de qualité ;

des enrichissements analytiques ;

des modèles dbt ;

des tests dbt ;

de la documentation dbt ;

des marts analytiques ;

un dashboard Streamlit.

Les principales validations obtenues sont :

Snowflake              ✅
RAW / STAGING / FINAL  ✅
Analyses SQL           ✅
dbt compile            ✅
dbt run                ✅ 6/6
dbt test               ✅ 5/5
Documentation dbt      ✅
Dashboard Streamlit    ✅

Le projet constitue ainsi une chaîne complète allant de l'ingestion des données jusqu'à leur exploitation analytique et leur visualisation.