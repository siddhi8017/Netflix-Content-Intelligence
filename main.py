import numpy as np
import pandas as pd
import matplotlib.pyplot as plt 
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="YOUR_MYSQL_PASSWOR",
    database="netflix_project"
)

print("MySQL connected successfully!")

query = "SELECT * FROM netflix"

df = pd.read_sql(query, conn)

print(df.head())
print("Dataset shape:", df.shape)

print("\nFirst 5 rows:")
print(df.head())

print("\nColumn names:")
print(df.columns.tolist())


# ============================================
# 3. BASIC DATA INFORMATION
# ============================================

print("\n========== DATA INFORMATION ==========")

print("\nData types:")
print(df.dtypes)

print("\nMissing values:")
print(df.isnull().sum())


# ============================================
# 4. MOVIES VS TV SHOWS
# ============================================

print("\n========== MOVIES VS TV SHOWS ==========")

type_count = df["type"].value_counts()

print(type_count)

print("\nPercentage:")
print((type_count / len(df) * 100).round(2))


# ============================================
# 5. RELEASE YEAR ANALYSIS
# ============================================

print("\n========== RELEASE YEAR ANALYSIS ==========")

release_year = (
    df.groupby("release_year")
    .size()
    .reset_index(name="total")
    .sort_values("release_year")
)

print(release_year.tail(10))


# ============================================
# 6. TOP GENRES
# ============================================

print("\n========== TOP GENRES ==========")

genre_data = (
    df["listed_in"]
    .dropna()
    .str.split(", ")
    .explode()
    .value_counts()
    .reset_index()
)

genre_data.columns = ["genre", "total"]

print(genre_data.head(15))


# ============================================
# 7. TOP COUNTRIES
# ============================================

print("\n========== TOP COUNTRIES ==========")

country_data = (
    df["country"]
    .dropna()
    .str.split(", ")
    .explode()
    .value_counts()
    .reset_index()
)

country_data.columns = ["country", "total"]

print(country_data.head(15))


# ============================================
# 8. RATING DISTRIBUTION
# ============================================

print("\n========== RATING DISTRIBUTION ==========")

rating_data = (
    df["rating"]
    .dropna()
    .value_counts()
    .reset_index()
)

rating_data.columns = ["rating", "total"]

print(rating_data)


# ============================================
# 9. MOVIE DURATION ANALYSIS
# ============================================

print("\n========== MOVIE DURATION ==========")

movie_df = df[df["type"] == "Movie"].copy()

movie_df["duration_minutes"] = (
    movie_df["duration"]
    .str.replace(" min", "", regex=False)
    .astype(float)
)

average_movie_duration = movie_df["duration_minutes"].mean()

print(
    "Average movie duration:",
    round(average_movie_duration, 2),
    "minutes"
)


# ============================================
# 10. TV SHOW SEASON ANALYSIS
# ============================================

print("\n========== TV SHOW SEASONS ==========")

tv_df = df[df["type"] == "TV Show"].copy()

tv_df["seasons"] = (
    tv_df["duration"]
    .str.replace(" Seasons", "", regex=False)
    .str.replace(" Season", "", regex=False)
    .astype(float)
)

average_seasons = tv_df["seasons"].mean()

print(
    "Average TV show seasons:",
    round(average_seasons, 2)
)


# ============================================
# 11. CONTENT ADDED TO NETFLIX BY YEAR
# ============================================

print("\n========== CONTENT ADDED BY YEAR ==========")

df["date_added_clean"] = pd.to_datetime(
    df["date_added_clean"],
    errors="coerce"
)

df["added_year"] = df["date_added_clean"].dt.year

content_added = (
    df.groupby("added_year")
    .size()
    .reset_index(name="total_added")
)

print(content_added)


# ============================================
# 12. CONTENT FRESHNESS
# ============================================

print("\n========== CONTENT FRESHNESS ==========")

df["content_age"] = (
    df["added_year"] - df["release_year"]
)

print(df["content_age"].describe())


# ============================================
# 13. COUNTRY-GENRE ANALYSIS
# ============================================

print("\n========== COUNTRY-GENRE ANALYSIS ==========")

country_genre = df[
    ["country", "listed_in"]
].dropna().copy()

country_genre["country"] = country_genre["country"].str.split(", ")
country_genre["listed_in"] = country_genre["listed_in"].str.split(", ")

country_genre = country_genre.explode("country")
country_genre = country_genre.explode("listed_in")

country_genre.columns = ["country", "genre"]

country_genre_count = (
    country_genre
    .groupby(["country", "genre"])
    .size()
    .reset_index(name="total")
    .sort_values("total", ascending=False)
)

print(country_genre_count.head(20))


# ============================================
# 14. OVERALL GENRE BASELINE
# ============================================

print("\n========== GENRE BASELINE ==========")

overall_genre = (
    country_genre["genre"]
    .value_counts()
    .reset_index()
)

overall_genre.columns = ["genre", "overall_total"]

overall_total = overall_genre["overall_total"].sum()

overall_genre["overall_percentage"] = (
    overall_genre["overall_total"]
    / overall_total
    * 100
)

print(overall_genre.head(15))


# ============================================
# 15. COUNTRY-GENRE REPRESENTATION
# ============================================

print("\n========== REPRESENTATION ANALYSIS ==========")

country_total = (
    country_genre
    .groupby("country")
    .size()
    .reset_index(name="country_total")
)

country_genre_analysis = country_genre_count.merge(
    country_total,
    on="country"
)

country_genre_analysis["country_percentage"] = (
    country_genre_analysis["total"]
    / country_genre_analysis["country_total"]
    * 100
)

country_genre_analysis = country_genre_analysis.merge(
    overall_genre[["genre", "overall_percentage"]],
    on="genre"
)

country_genre_analysis["representation_index"] = (
    country_genre_analysis["country_percentage"]
    / country_genre_analysis["overall_percentage"]
)

print(
    country_genre_analysis[
        [
            "country",
            "genre",
            "total",
            "country_percentage",
            "overall_percentage",
            "representation_index"
        ]
    ].head(20)
)


# ============================================
# 16. UNIQUE FEATURE — CONTENT GAP SCORE
# ============================================

print("\n========== CONTENT GAP DETECTION ==========")

country_genre_analysis["gap_score"] = 0.0

underrepresented = (
    country_genre_analysis["representation_index"] < 1
)

country_genre_analysis.loc[
    underrepresented,
    "gap_score"
] = (
    1
    - country_genre_analysis.loc[
        underrepresented,
        "representation_index"
    ]
) * 100

country_genre_analysis["gap_score"] = (
    country_genre_analysis["gap_score"].round(2)
)

# Remove very small samples
gap_analysis = country_genre_analysis[
    country_genre_analysis["total"] >= 20
].copy()

gap_analysis = gap_analysis.sort_values(
    "gap_score",
    ascending=False
)

print("\nTop content gap indicators:")
print(
    gap_analysis[
        [
            "country",
            "genre",
            "total",
            "representation_index",
            "gap_score"
        ]
    ].head(20)
)


# ============================================
# 17. SAVE ANALYSIS TO EXCEL
# ============================================

print("\n========== CREATING EXCEL REPORT ==========")

with pd.ExcelWriter(
    "netflix_analysis_report.xlsx",
    engine="openpyxl"
) as writer:

    df.to_excel(
        writer,
        sheet_name="Netflix_Data",
        index=False
    )

    type_count.reset_index().to_excel(
        writer,
        sheet_name="Movies_vs_TV",
        index=False
    )

    release_year.to_excel(
        writer,
        sheet_name="Release_Year",
        index=False
    )

    genre_data.to_excel(
        writer,
        sheet_name="Genres",
        index=False
    )

    country_data.to_excel(
        writer,
        sheet_name="Countries",
        index=False
    )

    rating_data.to_excel(
        writer,
        sheet_name="Ratings",
        index=False
    )

    content_added.to_excel(
        writer,
        sheet_name="Content_Added",
        index=False
    )

    country_genre_count.to_excel(
        writer,
        sheet_name="Country_Genre",
        index=False
    )

    gap_analysis.to_excel(
        writer,
        sheet_name="Content_Gaps",
        index=False
    )

print(
    "\nExcel report created successfully:"
    " netflix_analysis_report.xlsx"
)


# ============================================
# 18. CHART 1 — MOVIES VS TV SHOWS
# ============================================

plt.figure(figsize=(7, 5))

type_count.plot(
    kind="bar"
)

plt.title("Movies vs TV Shows")
plt.xlabel("Type")
plt.ylabel("Number of Titles")
plt.xticks(rotation=0)
plt.tight_layout()

plt.savefig(
    "movies_vs_tv.png",
    dpi=300
)

plt.show()


# ============================================
# 19. CHART 2 — TOP 10 GENRES
# ============================================

plt.figure(figsize=(9, 5))

genre_data.head(10).plot(
    x="genre",
    y="total",
    kind="bar"
)

plt.title("Top 10 Netflix Genres")
plt.xlabel("Genre")
plt.ylabel("Number of Titles")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()

plt.savefig(
    "top_10_genres.png",
    dpi=300
)

plt.show()


# ============================================
# 20. CHART 3 — TOP 10 COUNTRIES
# ============================================

plt.figure(figsize=(9, 5))

country_data.head(10).plot(
    x="country",
    y="total",
    kind="bar"
)

plt.title("Top 10 Countries")
plt.xlabel("Country")
plt.ylabel("Number of Titles")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()

plt.savefig(
    "top_10_countries.png",
    dpi=300
)

plt.show()


# ============================================
# 21. CHART 4 — CONTENT ADDED OVER TIME
# ============================================

plt.figure(figsize=(9, 5))

plt.plot(
    content_added["added_year"],
    content_added["total_added"],
    marker="o"
)

plt.title("Netflix Content Added Over Time")
plt.xlabel("Year")
plt.ylabel("Titles Added")

plt.tight_layout()

plt.savefig(
    "content_added_over_time.png",
    dpi=300
)

plt.show()


# ============================================
# 22. FINISH
# ============================================

conn.close()

print("\n===================================")
print("NETFLIX ANALYSIS COMPLETED!")
print("===================================")
print("Excel report created.")
print("Charts created.")
print("Content Gap Detection completed.")

