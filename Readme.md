📦 Repository GitHub
│
├── 🏔️ Snowflake
│   └── NYC_TAXI_DB
│       ├── RAW
│       ├── STAGING
│       └── FINAL
│
├── 📝 SQL
│   ├── Infrastructure
│   ├── Ingestion
│   ├── Qualité
│   ├── Nettoyage
│   └── Transformations
│
├── 📖 README
│   ├── Architecture
│   ├── Installation
│   ├── Exécution
│   └── Choix techniques
│
├── 🔧 dbt
│   ├── Staging
│   ├── Intermediate
│   ├── Marts
│   ├── Tests
│   └── Documentation
│
├── ⚙️ GitHub Actions
│   └── Pipeline automatisé
│
└── 📊 Dashboard
    └── KPIsRapport de travail — NYC Taxi Data Warehouse
1. Objectif du projet

Mise en place d'un Data Warehouse Snowflake à partir des données NYC Yellow Taxi au format Parquet.

Architecture retenue :

Parquet
   ↓
RAW
   ↓
STAGING
   ↓
FINAL


Le projet est développé directement dans un projet Snowflake avec :

des fichiers SQL pour les différentes étapes ;

un fichier Python uniquement prévu pour télécharger les fichiers Parquet.

Il n'y aura pas de compte AWS S3/Azure personnel. Les fichiers sont chargés manuellement dans un stage interne Snowflake.

2. Infrastructure Snowflake créée

Base de données :

NYC_TAXI_DB


Schéma RAW utilisé :

NYC_TAXI_DB.RAW


Un stage interne a été créé dans Snowflake.

Un fichier Parquet de janvier 2025 a ensuite été uploadé manuellement dans ce stage.

Les données ont déjà été inspectées précédemment avec Pandas.

3. Difficulté rencontrée avec Python

Une tentative de téléchargement direct depuis Python vers :

https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-01.parquet


a échoué à cause d'un problème de résolution DNS / accès réseau depuis l'environnement Snowflake.

Le choix retenu est donc :

Python → téléchargement des fichiers uniquement lorsque nécessaire
Snowflake → stockage, chargement et transformations


Pour le fichier utilisé aujourd'hui, le Parquet a été uploadé manuellement dans le stage.

4. Couche RAW

Le fichier Parquet a été chargé dans :

NYC_TAXI_DB.RAW.YELLOW_TRIPS


Nombre de lignes :

3 475 226


Nous avons notamment rencontré un problème de timestamp provenant des valeurs Parquet. Les colonnes de dates ont été converties correctement avec :

TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)
TO_TIMESTAMP_NTZ("tpep_dropoff_datetime", 6)


Les noms des colonnes Parquet nécessitent également des guillemets lorsqu'ils conservent leur casse d'origine.

5. Couche STAGING

Une table :

NYC_TAXI_DB.STAGING.YELLOW_TRIPS


a été créée.

Elle contient les données nettoyées et enrichies, mais sans supprimer les anomalies afin de conserver la possibilité de les analyser.

Nombre de lignes :

3 475 226

Colonnes retenues
vendor_id
pickup_datetime
dropoff_datetime
trip_distance
distance_category
pickup_location_id
dropoff_location_id
payment_type
fare_amount
tip_amount
total_amount
trip_duration_seconds
speed_mph
pickup_day_name
is_weekend
pickup_period


RatecodeID et passenger_count ont été écartés car ils contenaient beaucoup de valeurs nulles et n'étaient pas nécessaires pour notre analyse.

6. Enrichissements réalisés
Durée du trajet

Calculée en secondes :

DATEDIFF(
    'second',
    pickup_datetime,
    dropoff_datetime
)

Vitesse

Calculée en miles par heure lorsque :

durée > 0
distance > 0


Les autres cas produisent NULL.

Nous avons vérifié :

2 051 trajets avec durée <= 0
90 893 trajets avec distance <= 0
692 avec les deux problèmes


Donc :

2 051 + 90 893 - 692 = 92 252


ce qui correspond exactement aux 92 252 speed_mph NULL.

Jour de la semaine

Une colonne :

pickup_day_name


a été ajoutée.

Exemple :

Thu
Mon
Tue

Week-end

Une colonne :

is_weekend


a été ajoutée.

Nombre de trajets le week-end :

878 993

Période de la journée

Une colonne :

pickup_period


avec les catégories :

night
morning
afternoon
evening

Catégorie de distance

Une colonne :

distance_category


a été ajoutée :

invalid       trip_distance <= 0
short         trip_distance < 1
medium        trip_distance < 5
long          trip_distance < 10
very_long     trip_distance >= 10


Distribution observée :

medium       2 063 682
short          794 766
long           290 230
very_long      235 655
invalid         90 893


Total :

3 475 226

7. Analyse de qualité des données

Plusieurs anomalies ont été identifiées.

Montants

Avant filtrage :

fare_amount <= 0       145 516
total_amount <= 0        63 596


Les deux catégories se recouvrent.

La règle retenue pour FINAL est :

fare_amount > 0
AND total_amount > 0

Distance

Nous avons trouvé :

116 trajets avec trip_distance > 1000


La règle retenue est :

trip_distance <= 1000

Ratio tarif / distance

Des valeurs extrêmes ont été identifiées.

Exemple :

trip_distance = 1.6
fare_amount   = 863 372.12
total_amount  = 863 380.37


Le ratio était :

539 607.575 $ / mile


Nous avons analysé les ratios et obtenu :

> 100       : 15 964
> 1 000     : 8 856
> 5 000     : 687
> 10 000    : 30


Les 30 observations avec :

fare_amount / trip_distance > 10 000


ont été considérées comme des anomalies extrêmes et exclues de FINAL.

Important : les trajets avec :

trip_distance = 0


sont conservés. Le ratio tarif/distance n'est appliqué que lorsque la distance est strictement positive.

8. Couche FINAL

Le fichier SQL :

transform_final.sql


a été créé.

La table :

NYC_TAXI_DB.FINAL.YELLOW_TRIPS


est créée à partir de STAGING.

Règles actuelles :

WHERE fare_amount > 0
  AND total_amount > 0
  AND trip_distance <= 1000
  AND (
      trip_distance = 0
      OR fare_amount / trip_distance <= 10000
  )


Nombre final de lignes :

3 329 553

Contrôle final

Les contrôles donnent :

invalid_fare       = 0
invalid_total      = 0
invalid_distance   = 0
extreme_ratio      = 0


La couche FINAL de janvier est donc validée.

9. Structure actuelle du projet

Le projet Snowflake est organisé autour des étapes suivantes :

NYC_TAXI_DWH/
│
├── python/
│   └── ...
│
└── sql/
    ├── ...
    ├── clean_staging.sql
    └── transform_final.sql


Le fichier Python servira uniquement à gérer le téléchargement des fichiers Parquet.

10. Ce qui reste à faire
Étape 1 — Finaliser la structure SQL

Vérifier que les fichiers SQL sont correctement organisés et que les scripts peuvent être rejoués dans l'ordre.

Ordre logique :

RAW
 ↓
STAGING
 ↓
FINAL

Étape 2 — Charger les autres mois

Nous devons récupérer les autres fichiers Yellow Taxi 2025 :

janvier
février
mars
avril
mai
juin
juillet
août
septembre
octobre
novembre
décembre


Janvier est déjà notre référence.

Étape 3 — Automatiser le chargement

L'objectif sera d'éviter de refaire manuellement :

upload
COPY
transformation
DROP
CREATE


pour chaque mois.

Il faudra définir une stratégie permettant de charger les différents Parquet dans RAW puis d'appliquer le même traitement SQL.

Étape 4 — Construire la table annuelle

À terme, FINAL devra représenter l'ensemble de l'année et non uniquement janvier.

L'objectif sera donc d'obtenir une table contenant les données des 12 mois avec exactement la même structure.

Étape 5 — Contrôles qualité sur l'ensemble de l'année

Une fois les 12 mois chargés, refaire les contrôles :

nombre de lignes ;

dates min/max ;

valeurs nulles ;

distances invalides ;

montants invalides ;

ratios tarif/distance ;

catégories de distance ;

répartition semaine/week-end ;

périodes de la journée.

Étape 6 — Partie analytique

Une fois le Data Warehouse terminé, nous pourrons construire les analyses demandées par le projet, par exemple :

nombre de trajets ;

chiffre d'affaires ;

montant moyen ;

pourboires ;

durée moyenne ;

distance moyenne ;

évolution mensuelle ;

comportement semaine/week-end ;

analyse par période de la journée ;

analyse par zone de pickup/dropoff.

11. Point de reprise pour demain

Ne pas modifier la logique de janvier pour l'instant.

La prochaine étape logique est :

Automatiser le chargement des autres fichiers Parquet
                    ↓
                RAW annuel
                    ↓
              STAGING annuel
                    ↓
               FINAL annuel
                    ↓
             analyses SQL


Janvier sert désormais de modèle validé pour les transformations.

État actuel :

Infrastructure Snowflake      ✅
Stage interne                 ✅
RAW janvier                   ✅
STAGING janvier               ✅
Enrichissements               ✅
Analyse qualité               ✅
FINAL janvier                 ✅
Contrôles FINAL               ✅

11 autres mois                ⏳
Automatisation                ⏳
FINAL annuel                  ⏳
Analyses finales              ⏳