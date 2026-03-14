# prepare_data.R
# Builds replication CSVs from original Qualtrics exports and processed conjoint data.
# Replaces derived binary variables with raw survey question responses.
#
# Input:  Raw Qualtrics CSVs + existing replication CSVs (for filtered respondent list & conjoint data)
# Output: replication/data/germany_job_training.csv
#         replication/data/korea_job_training.csv

suppressPackageStartupMessages(library(tidyverse))

# ---- Paths ----
base <- "/Users/scdenney/Documents/GitHub/IFES2023"

ge_qualtrics <- file.path(base, "Germans/Data/IFES 2023 - German_February 12, 2024_18.11-choice_text.csv")
sk_qualtrics <- file.path(base, "South Koreans/Data/IFES 2023 - ROK_February 12, 2024_16.45.csv")

ge_repl <- file.path(base, "replication/data/germany_job_training.csv")
sk_repl <- file.path(base, "replication/data/korea_job_training.csv")

out_dir <- file.path(base, "replication/data")

# ---- Helper: read Qualtrics CSV (3 header rows: names, labels, ImportId) ----
read_qualtrics <- function(path) {
  # Row 1 = column names, rows 2-3 = labels/ImportId -> skip
  read_csv(path, skip = 3,
           col_names = read_csv(path, n_max = 0, show_col_types = FALSE) %>% names(),
           show_col_types = FALSE)
}

# ===========================================================================
# GERMANY
# ===========================================================================
cat("Processing Germany...\n")

# Existing replication data (filtered respondents + conjoint attributes in English)
# na = c("", "NA") prevents "None" in Record column from being treated as NA
ge_existing <- read_csv(ge_repl, show_col_types = FALSE, na = c("", "NA"))

# Get unique filtered ResponseIds
ge_ids <- unique(ge_existing$ResponseId)
cat("  Existing respondents:", length(ge_ids), "\n")

# Read raw Qualtrics
ge_raw <- read_qualtrics(ge_qualtrics)
cat("  Qualtrics rows:", nrow(ge_raw), "\n")

# Extract raw survey variables for filtered respondents
ge_survey <- ge_raw %>%
  filter(ResponseId %in% ge_ids) %>%
  select(
    ResponseId,
    gender_raw = Q7,        # birth gender
    yob        = Q2,        # year of birth (German Q2)
    state_at_18 = Q5,       # German state at age 18 (east/west classification)
    current_state = Q6,     # current state of residence (regional classification)
    education  = Q8,        # highest education level
    ethnicity  = Q27,       # ethnic identification
    party_vote = Q11,       # party would vote for
    national_identity = Q28_1,  # national identity strength (0-10 scale)
    ancestry_importance = Q63_1,    # importance of German ancestors
    birthplace_importance = Q63_2,  # importance of born in Germany
    support_needy_training = Q60,   # support job training for needy citizens
    support_gdr_training = Q62      # support job training for former GDR citizens
  ) %>%
  mutate(
    # Clean national identity: endpoint labels to numeric
    national_identity = case_when(
      national_identity == "sehr deutsch" ~ "10",
      national_identity == "überhaupt nicht deutsch" ~ "0",
      TRUE ~ national_identity
    ),
    national_identity = as.numeric(national_identity),
    # Compute age and female from raw
    yob = as.numeric(yob),
    age = 2023 - yob,
    female = as.integer(gender_raw == "Weiblich")
  ) %>%
  select(-gender_raw)

cat("  Matched survey respondents:", nrow(ge_survey), "\n")

# Keep conjoint columns from existing data, drop old covariates
# Restore Record "None" which read_csv may convert to NA
ge_conjoint <- ge_existing %>%
  select(ResponseId, question_profile, candidate_choice,
         Age, Family, Gender, Occupation, Record, Origin) %>%
  mutate(Record = replace_na(Record, "None"))

# Join: conjoint (many rows per respondent) + survey (one row per respondent)
ge_new <- ge_conjoint %>%
  left_join(ge_survey, by = "ResponseId")

# Reorder columns
ge_new <- ge_new %>%
  select(
    ResponseId, question_profile, candidate_choice,
    Age, Family, Gender, Occupation, Record, Origin,
    age, yob, female,
    state_at_18, current_state, education, ethnicity, party_vote,
    national_identity, ancestry_importance, birthplace_importance,
    support_needy_training, support_gdr_training
  )

cat("  Output rows:", nrow(ge_new), " cols:", ncol(ge_new), "\n")
write_csv(ge_new, file.path(out_dir, "germany_job_training.csv"), na = "")

# ===========================================================================
# SOUTH KOREA
# ===========================================================================
cat("\nProcessing South Korea...\n")

# Existing replication data
sk_existing <- read_csv(sk_repl, show_col_types = FALSE, na = c("", "NA"))
sk_ids <- unique(sk_existing$ResponseId)
cat("  Existing respondents:", length(sk_ids), "\n")

# Read raw Qualtrics
sk_raw <- read_qualtrics(sk_qualtrics)
cat("  Qualtrics rows:", nrow(sk_raw), "\n")

# Extract raw survey variables
sk_survey <- sk_raw %>%
  filter(ResponseId %in% sk_ids) %>%
  select(
    ResponseId,
    gender_raw = Q2,         # birth gender
    yob        = Q4,         # year of birth
    province   = Q3,         # current province of residence
    education  = Q5,         # highest education level (Korean Q5)
    political_ideology = Q12,  # political self-identification
    party_vote = Q13,        # party would vote for
    korean_pride = Q28,      # pride in being Korean
    national_identity = Q123_1,   # national identity strength (scale)
    ancestry_importance = Q31_1,  # importance of Korean ancestry
    birthplace_importance = Q31_2,  # importance of born in Korea
    national_composition = Q34,   # ethnic homogeneous vs multicultural
    support_nk_engagement = Q46,  # support for NK engagement
    support_nk_defectors  = Q48   # support for NK defector assistance
  ) %>%
  mutate(
    national_identity = as.numeric(national_identity),
    yob = as.numeric(yob),
    age = 2023 - yob,
    female = as.integer(gender_raw == "여성")
  ) %>%
  select(-gender_raw)

cat("  Matched survey respondents:", nrow(sk_survey), "\n")

# Keep conjoint columns
# Restore Record "None" which read_csv may convert to NA
sk_conjoint <- sk_existing %>%
  select(ResponseId, question_profile, candidate_choice,
         Age, Family, Gender, Occupation, Record, Origin) %>%
  mutate(Record = replace_na(Record, "None"))

# Join
sk_new <- sk_conjoint %>%
  left_join(sk_survey, by = "ResponseId")

# Reorder columns
sk_new <- sk_new %>%
  select(
    ResponseId, question_profile, candidate_choice,
    Age, Family, Gender, Occupation, Record, Origin,
    age, yob, female,
    province, education, political_ideology, party_vote,
    korean_pride, national_identity, ancestry_importance, birthplace_importance,
    national_composition, support_nk_engagement, support_nk_defectors
  )

cat("  Output rows:", nrow(sk_new), " cols:", ncol(sk_new), "\n")
write_csv(sk_new, file.path(out_dir, "korea_job_training.csv"), na = "")

cat("\nDone. Files written to", out_dir, "\n")
