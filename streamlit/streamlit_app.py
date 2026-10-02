import streamlit as st
from snowflake.snowpark.context import get_active_session

# ============================================================
# CONFIGURATION
# ============================================================

st.set_page_config(
    page_title="NYC Yellow Taxi 2025",
    page_icon="🚕",
    layout="wide",
)

# ============================================================
# CONNEXION SNOWFLAKE
# ============================================================

session = get_active_session()

# ============================================================
# TITRE
# ============================================================

st.title("🚕 NYC Yellow Taxi — 2025")

st.write("Dashboard analytique basé sur les données NYC Yellow Taxi 2025.")

st.divider()

# ============================================================
# KPI GLOBAUX
# ============================================================

kpi_query = """
SELECT
    total_trips,
    total_revenue,
    avg_trip_amount,
    total_tips,
    avg_tip_amount,
    avg_distance_miles,
    avg_duration_minutes,
    avg_speed_mph
FROM NYC_TAXI_DB.FINAL.VW_DASHBOARD_KPI
"""

kpi_df = session.sql(kpi_query).to_pandas()
kpi = kpi_df.iloc[0]

# ============================================================
# PREMIERE LIGNE DE KPI
# ============================================================

st.subheader("📊 Vue d'ensemble")

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("🚕 Total trajets", f"{kpi['TOTAL_TRIPS']:,.0f}")

with col2:
    st.metric("💰 Chiffre d'affaires", f"${kpi['TOTAL_REVENUE']:,.2f}")

with col3:
    st.metric("💵 Montant moyen", f"${kpi['AVG_TRIP_AMOUNT']:,.2f}")

with col4:
    st.metric("💸 Total pourboires", f"${kpi['TOTAL_TIPS']:,.2f}")

# ============================================================
# DEUXIEME LIGNE DE KPI
# ============================================================

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("Pourboire moyen", f"${kpi['AVG_TIP_AMOUNT']:,.2f}")

with col2:
    st.metric("Distance moyenne", f"{kpi['AVG_DISTANCE_MILES']:,.2f} mi")

with col3:
    st.metric("Durée moyenne", f"{kpi['AVG_DURATION_MINUTES']:,.2f} min")

with col4:
    st.metric("Vitesse moyenne", f"{kpi['AVG_SPEED_MPH']:,.2f} mph")

st.divider()

# ============================================================
# DONNEES MENSUELLES
# ============================================================

monthly_query = """
SELECT
    month,
    total_trips,
    total_revenue,
    avg_trip_amount,
    total_tips,
    avg_distance_miles,
    avg_duration_minutes,
    avg_speed_mph
FROM NYC_TAXI_DB.FINAL.VW_MONTHLY_KPI
ORDER BY month
"""

monthly_df = session.sql(monthly_query).to_pandas()
monthly_df["MONTH_LABEL"] = monthly_df["MONTH"].dt.strftime("%b")

# ============================================================
# EVOLUTION MENSUELLE
# ============================================================

st.header("📈 Évolution mensuelle")

col1, col2 = st.columns(2)

with col1:
    st.subheader("Nombre de trajets")
    st.line_chart(monthly_df, x="MONTH_LABEL", y="TOTAL_TRIPS")

with col2:
    st.subheader("Chiffre d'affaires")
    st.line_chart(monthly_df, x="MONTH_LABEL", y="TOTAL_REVENUE")

# ============================================================
# WEEKDAY VS WEEKEND
# ============================================================

day_type_query = """
SELECT
    day_type,
    total_trips,
    total_revenue,
    avg_trip_amount,
    total_tips,
    avg_tip_amount,
    avg_distance_miles,
    avg_duration_minutes,
    avg_speed_mph
FROM NYC_TAXI_DB.FINAL.VW_DAY_TYPE_KPI
ORDER BY day_type
"""

day_type_df = session.sql(day_type_query).to_pandas()

st.header("📅 Semaine vs week-end")

col1, col2 = st.columns(2)

with col1:
    st.subheader("Nombre de trajets")
    st.bar_chart(day_type_df, x="DAY_TYPE", y="TOTAL_TRIPS")

with col2:
    st.subheader("Chiffre d'affaires")
    st.bar_chart(day_type_df, x="DAY_TYPE", y="TOTAL_REVENUE")

# ============================================================
# TABLEAU MENSUEL
# ============================================================

st.header("📋 Données mensuelles")

display_df = monthly_df[
    [
        "MONTH_LABEL",
        "TOTAL_TRIPS",
        "TOTAL_REVENUE",
        "AVG_TRIP_AMOUNT",
        "TOTAL_TIPS",
        "AVG_DISTANCE_MILES",
        "AVG_DURATION_MINUTES",
        "AVG_SPEED_MPH",
    ]
].copy()

display_df.columns = [
    "Mois",
    "Trajets",
    "Chiffre d'affaires",
    "Montant moyen",
    "Pourboires",
    "Distance moyenne",
    "Durée moyenne",
    "Vitesse moyenne",
]

st.dataframe(display_df, use_container_width=True, hide_index=True)

# ============================================================
# INFORMATIONS
# ============================================================

st.divider()

st.caption("Source : NYC_TAXI_DB.FINAL.YELLOW_TRIPS — NYC Yellow Taxi 2025")