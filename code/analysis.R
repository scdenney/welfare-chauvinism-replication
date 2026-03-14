# Replication analysis for job-training conjoint
#
# This script derives all subgroup variables from raw survey responses
# included in the replication data, then runs the conjoint analysis.

suppressPackageStartupMessages({
  library(tidyverse)
  library(cregg)
  library(ggthemes)
})

out_dir <- "output"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

fig_dir <- file.path(out_dir, "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# Load data (na = c("", "NA") prevents Record level "None" from being parsed as NA)
ge <- read_csv("data/germany_job_training.csv", show_col_types = FALSE, na = c("", "NA"))
sk <- read_csv("data/korea_job_training.csv", show_col_types = FALSE, na = c("", "NA"))

# =====================================================================
# Derive analysis variables from raw survey responses
# =====================================================================

# --- Germany ---
ge <- ge %>%
  mutate(
    # East/West/Berlin classification (from state at age 18)
    east.germany.F = case_when(
      state_at_18 %in% c("Brandenburg", "Mecklenburg-Vorpommern", "Sachsen",
                          "Sachsen-Anhalt", "Thüringen",
                          "Ost-Berlin (vor der Wiedervereinigung)") ~ "Eastern German",
      state_at_18 %in% c("Baden-Württemberg", "Bayern", "Bremen", "Hamburg",
                          "Hessen", "Niedersachsen", "Nordrhein-Westfalen",
                          "Rheinland-Pfalz", "Saarland", "Schleswig-Holstein",
                          "West-Berlin (vor der Wiedervereinigung)") ~ "Western German",
      state_at_18 == "Berlin" ~ "Berlin",
      TRUE ~ NA_character_
    ),

    # Ethnic German identification
    ethnic_german = as.integer(ethnicity == "Deutsch"),

    # University education
    university_education = as.integer(education %in% c(
      "(Fach)Hochschulabschluss (Bachelor)",
      "(Fach)Hochschulabschluss (Diplom, Master oder höher)",
      "Fachhochschulreife (Abschluss einer Fachoberschule etc.)"
    )),

    # North/South regional classification (Western states only)
    regions = case_when(
      current_state %in% c("Baden-Württemberg", "Saarland", "Rheinland-Pfalz",
                            "Hessen", "Bayern") ~ "South",
      current_state %in% c("Schleswig-Holstein", "Hamburg", "Bremen",
                            "Nordrhein-Westfalen", "Niedersachsen") ~ "North",
      TRUE ~ NA_character_
    ),

    # Western German generations (pre- vs post-unification cohorts)
    west.generations = case_when(
      east.germany.F == "Western German" & yob >= 1934 & yob <= 1971 ~
        "Western German (pre-unification)",
      east.germany.F == "Western German" & yob >= 1977 ~
        "Western German (post-unification)",
      TRUE ~ NA_character_
    ),

    # Partisan group (from party vote intention)
    partisan_group = case_when(
      party_vote %in% c("Sozialdemokratische Partei Deutschlands (SPD)",
                         "Bündnis 90/Die Grünen", "DIE LINKE") ~ "Left-wing",
      party_vote %in% c("Christlich Demokratische Union (CDU) Christlich-Soziale Union (CSU)",
                         "Freie Demokratische Partei (FDP)") ~ "Center",
      party_vote == "Alternative für Deutschland (AfD)" ~ "Right-wing",
      party_vote %in% c("Ich weiß es nicht", "Eine andere Partei") ~ "Other/unknown",
      TRUE ~ NA_character_
    ),
    partisan_group = factor(partisan_group,
                            levels = c("Left-wing", "Center", "Right-wing", "Other/unknown")),

    # National identity strength (median split on 0-10 scale)
    natidstrong = as.integer(national_identity >= median(national_identity, na.rm = TRUE)),

    # Ethnocentrism (importance of ancestry AND birthplace)
    ethnocentric = as.integer(
      ancestry_importance %in% c("Sehr wichtig", "Eher wichtig") &
      birthplace_importance %in% c("Sehr wichtig", "Eher wichtig")
    ),

    # Opposition to GDR-specific assistance
    opposeGDRsupport = factor(
      as.integer(support_needy_training == "Stimme zu" &
                 support_gdr_training == "Stimme nicht zu"),
      levels = c(0, 1),
      labels = c("Supports assistance", "Opposes assistance")
    ),

    # Age median split
    age.median = as.integer(age >= median(age, na.rm = TRUE))
  )

# --- South Korea ---
sk <- sk %>%
  mutate(
    # University education
    university_education = as.integer(education %in% c("대학교", "대학원 이상")),

    # Regional classification
    regions = case_when(
      province %in% c("서울", "경기도", "인천", "강원도") ~ "Capital Area",
      province %in% c("부산", "대구", "울산", "경북", "경남") ~ "Yeongnam",
      province %in% c("광주", "전북", "전남", "제주", "대전", "세종",
                       "충북", "충남") ~ "Chungcheong-Honam",
      TRUE ~ NA_character_
    ),

    # Generational cohort
    demogenF = factor(
      as.integer(yob >= 1975),
      levels = c(0, 1),
      labels = c("South Korea's \nDemocratic Generation",
                 "South Korea's \nAuthoritarian Generation")
    ),

    # Political ideology (from self-identification)
    progressive = as.integer(political_ideology %in% c("다소 진보적", "매우 진보적")),
    conservative = as.integer(political_ideology %in% c("다소 보수적", "매우 보수적")),

    # National identity strength (median split)
    natidstrong = as.integer(national_identity >= median(national_identity, na.rm = TRUE)),

    # Ethnocentrism
    ethnocentric = as.integer(
      ancestry_importance %in% c("매우 중요하다", "대체로 중요하다") &
      birthplace_importance %in% c("매우 중요하다", "대체로 중요하다")
    ),

    # NK defector support
    nosupportnkdef = as.integer(support_nk_defectors == "동의하지 않는다"),
    nosupportnkdef.strict = as.integer(
      support_nk_engagement == "동의한다" & support_nk_defectors == "동의하지 않는다"
    ),
    nkoppose = case_when(
      support_nk_engagement == "동의한다" & support_nk_defectors == "동의하지 않는다" ~
        "Opposes assistance",
      support_nk_defectors == "동의한다" ~ "Supports assistance",
      TRUE ~ NA_character_
    ),

    # Pride in being Korean
    pride = as.integer(korean_pride %in% c("매우 자랑스럽다", "어느 정도 자랑스럽다")),

    # National composition views
    natid2 = factor(
      case_when(
        national_composition == "다민족·다문화국가" ~ 1L,
        national_composition == "단일민족·단일문화국가" ~ 0L,
        TRUE ~ NA_integer_
      ),
      levels = c(0, 1),
      labels = c("Ethnically homogenous", "Multi-ethnic and cultural")
    ),

    # Age median split
    age.median = as.integer(age >= median(age, na.rm = TRUE))
  )

# Political leaners (need progressive/conservative computed first)
sk <- sk %>%
  mutate(
    conservative.leaners = as.integer(
      conservative == 1 |
      (political_ideology == "중도적" & party_vote == "국민의힘")
    ),
    progressive.leaners = as.integer(
      progressive == 1 |
      (political_ideology == "중도적" & party_vote == "더불어민주당") |
      party_vote == "정의당"
    )
  )

# =====================================================================
# Ensure conjoint attributes are factors for cregg
# =====================================================================
coerce_conjoint <- function(df) {
  df %>%
    mutate(
      across(c(Age, Family, Gender, Occupation, Record, Origin), as.factor),
      candidate_choice = as.numeric(candidate_choice)
    )
}

ge <- coerce_conjoint(ge)
sk <- coerce_conjoint(sk)

# Sample sizes (respondents)
cat("Germany respondents:", n_distinct(ge$ResponseId), "\n")
cat("Korea respondents:", n_distinct(sk$ResponseId), "\n")

# -----------------------------
# Main analysis samples
# Germany: Western Germans, ethnic German, exclude Berlin
ge_main <- ge %>%
  filter(east.germany.F == "Western German",
         ethnic_german == 1)

# Korea: all attention-pass respondents (already filtered)
sk_main <- sk

# AMCEs (main)
attrs <- candidate_choice ~ Age + Family + Gender + Occupation + Record + Origin

amce_ge <- cj(ge_main, attrs, id = ~ResponseId, estimate = "amce")
amce_sk <- cj(sk_main, attrs, id = ~ResponseId, estimate = "amce")

write_csv(amce_ge, file.path(out_dir, "amce_germany_main.csv"))
write_csv(amce_sk, file.path(out_dir, "amce_korea_main.csv"))

# Marginal means (main samples)
mm_ge <- cj(ge_main, attrs, id = ~ResponseId, estimate = "mm")
mm_sk <- cj(sk_main, attrs, id = ~ResponseId, estimate = "mm")

write_csv(mm_ge, file.path(out_dir, "mm_germany_main.csv"))
write_csv(mm_sk, file.path(out_dir, "mm_korea_main.csv"))

# Germany marginal means including East (SI Figure C2)
ge_all <- ge %>%
  filter(ethnic_german == 1, east.germany.F != "Berlin")
mm_ge_all <- cj(ge_all, attrs, id = ~ResponseId, estimate = "mm")
write_csv(mm_ge_all, file.path(out_dir, "mm_germany_with_east.csv"))

# Interaction: Origin by Record (as in manuscript discussion)
int_ge <- cj(ge_main, candidate_choice ~ Age + Family + Gender + Occupation + Origin,
             id = ~ResponseId, estimate = "amce", by = ~Record)
int_sk <- cj(sk_main, candidate_choice ~ Age + Family + Gender + Occupation + Origin,
             id = ~ResponseId, estimate = "amce", by = ~Record)

write_csv(int_ge, file.path(out_dir, "amce_germany_origin_by_record.csv"))
write_csv(int_sk, file.path(out_dir, "amce_korea_origin_by_record.csv"))

# -----------------------------
# Plots

save_plot <- function(plot, outfile_base, width, height) {
  ggsave(paste0(outfile_base, ".png"), plot = plot, width = width, height = height, units = "in", dpi = 300)
  ggsave(paste0(outfile_base, ".pdf"), plot = plot, width = width, height = height, units = "in")
}

plot_amce <- function(df, title, subtitle, outfile_base) {
  df_plot <- df %>%
    filter(!is.na(level)) %>%
    group_by(feature) %>%
    mutate(level = reorder(level, estimate)) %>%
    ungroup()

  p <- ggplot(df_plot, aes(x = level, y = estimate)) +
    geom_hline(yintercept = 0, color = "gray50") +
    geom_point(size = 2) +
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0) +
    coord_flip() +
    labs(title = title, subtitle = subtitle, x = "", y = "AMCE") +
    theme_clean() +
    facet_grid(feature ~ ., scales = "free_y", space = "free_y")

  save_plot(p, outfile_base, width = 10, height = 8)
}

plot_mm <- function(df, title, subtitle, outfile_base) {
  df_plot <- df %>%
    filter(!is.na(level)) %>%
    group_by(feature) %>%
    mutate(level = reorder(level, estimate)) %>%
    ungroup()

  p <- ggplot(df_plot, aes(x = level, y = estimate)) +
    geom_hline(yintercept = 0.5, color = "gray50") +
    geom_point(size = 2) +
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0) +
    coord_flip() +
    labs(title = title, subtitle = subtitle, x = "", y = "Marginal Means") +
    theme_clean() +
    facet_grid(feature ~ ., scales = "free_y", space = "free_y")

  save_plot(p, outfile_base, width = 10, height = 8)
}

plot_origin_by_group <- function(df, title, subtitle, outfile_base, group_var) {
  df_plot <- df %>%
    filter(feature == "Origin", !is.na(level))

  p <- ggplot(df_plot, aes(x = reorder(level, estimate), y = estimate, color = !!sym(group_var))) +
    geom_hline(yintercept = 0.5, color = "gray50") +
    geom_point(size = 2, position = position_dodge(width = 0.5)) +
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, position = position_dodge(width = 0.5)) +
    coord_flip() +
    labs(title = title, subtitle = subtitle, x = "", y = "Marginal Means", color = "") +
    theme_clean()

  save_plot(p, outfile_base, width = 10, height = 6)
}

# Main AMCE plots
plot_amce(amce_ge, "Germany Job-Training Conjoint", "Western Germans, ethnic German", file.path(fig_dir, "amce_germany_main"))
plot_amce(amce_sk, "South Korea Job-Training Conjoint", "All respondents", file.path(fig_dir, "amce_korea_main"))

# Main MM plots
plot_mm(mm_ge, "Germany Job-Training Conjoint", "Western Germans, ethnic German", file.path(fig_dir, "mm_germany_main"))
plot_mm(mm_sk, "South Korea Job-Training Conjoint", "All respondents", file.path(fig_dir, "mm_korea_main"))
plot_mm(mm_ge_all, "Germany Job-Training Conjoint", "Includes East Germans (ethnic German only)", file.path(fig_dir, "mm_germany_with_east"))

# Combined origin AMCEs (main comparison)
amce_ge$sample <- "Western German"
amce_sk$sample <- "South Korean"
combined_amce <- bind_rows(amce_ge, amce_sk)
write_csv(combined_amce, file.path(out_dir, "amce_combined_main.csv"))

combined_origin <- combined_amce %>%
  filter(feature == "Origin")

p_combined <- ggplot(combined_origin, aes(x = level, y = estimate, color = sample)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_point(position = position_dodge(width = 0.5), size = 2) +
  geom_errorbar(aes(ymin = lower, ymax = upper), position = position_dodge(width = 0.5), width = 0) +
  coord_flip() +
  labs(title = "Origin AMCEs", subtitle = "Western German vs South Korean", x = "", y = "AMCE") +
  theme_clean()

save_plot(p_combined, file.path(fig_dir, "amce_origin_combined"), width = 10, height = 6)

# Origin by record interaction (AMCE)
plot_origin_by_group(int_ge, "Germany: Origin by Record", "Western Germans, ethnic German", file.path(fig_dir, "amce_origin_by_record_germany"), "Record")
plot_origin_by_group(int_sk, "South Korea: Origin by Record", "All respondents", file.path(fig_dir, "amce_origin_by_record_korea"), "Record")

# -----------------------------
# SI subgroup analyses (Origin only)

# Germany subgroups (Western Germans, ethnic German, no Berlin)
ge_sub <- ge %>%
  filter(east.germany.F == "Western German",
         ethnic_german == 1) %>%
  mutate(
    across(c(regions, west.generations, university_education, partisan_group,
             opposeGDRsupport, natidstrong, ethnocentric, age.median),
           as.factor)
  )

subgroups_ge <- list(
  regions = ~regions,
  west_generations = ~west.generations,
  education = ~university_education,
  partisan = ~partisan_group,
  gdr_support = ~opposeGDRsupport,
  natidstrong = ~natidstrong,
  ethnocentric = ~ethnocentric
)

for (nm in names(subgroups_ge)) {
  res <- cj(ge_sub, candidate_choice ~ Age + Family + Gender + Occupation + Origin,
            id = ~ResponseId, estimate = "mm", by = subgroups_ge[[nm]]) %>%
    filter(feature == "Origin")
  write_csv(res, file.path(out_dir, paste0("mm_germany_origin_by_", nm, ".csv")))

  # Plot
  plot_origin_by_group(
    res,
    paste("Germany: Origin by", nm),
    "Western Germans, ethnic German",
    file.path(fig_dir, paste0("mm_germany_origin_by_", nm)),
    "BY"
  )
}

# Korea subgroups
# political id (progressive vs conservative)
sk_sub <- sk %>%
  mutate(polid = case_when(
    progressive == 1 ~ "Progressive",
    conservative == 1 ~ "Conservative",
    TRUE ~ NA_character_
  )) %>%
  mutate(
    across(c(regions, university_education, nkoppose, natidstrong, ethnocentric,
             polid, demogenF, age.median),
           as.factor)
  )

subgroups_sk <- list(
  regions = ~regions,
  education = ~university_education,
  nk_support = ~nkoppose,
  natidstrong = ~natidstrong,
  ethnocentric = ~ethnocentric,
  polid = ~polid,
  generations = ~demogenF
)

for (nm in names(subgroups_sk)) {
  res <- cj(sk_sub, candidate_choice ~ Age + Family + Gender + Occupation + Origin,
            id = ~ResponseId, estimate = "mm", by = subgroups_sk[[nm]]) %>%
    filter(feature == "Origin")
  write_csv(res, file.path(out_dir, paste0("mm_korea_origin_by_", nm, ".csv")))

  # Plot
  plot_origin_by_group(
    res,
    paste("South Korea: Origin by", nm),
    "All respondents",
    file.path(fig_dir, paste0("mm_korea_origin_by_", nm)),
    "BY"
  )
}

# -----------------------------
# SI figure aliases (C1-C10)

# C1: Marginal means for Germany and South Korea (main samples)
plot_mm(mm_ge, "Germany Job-Training Conjoint", "Western Germans, ethnic German", file.path(fig_dir, "Figure_C1_DEU"))
plot_mm(mm_sk, "South Korea Job-Training Conjoint", "All respondents", file.path(fig_dir, "Figure_C1_KOR"))

# C2: Germany incl. East (ethnic German)
plot_mm(mm_ge_all, "Germany Job-Training Conjoint", "Includes East Germans (ethnic German only)", file.path(fig_dir, "Figure_C2"))

# C3: Support for assistance (Germany: GDR support; Korea: NK support)
plot_origin_by_group(
  cj(ge_sub, candidate_choice ~ Age + Family + Gender + Occupation + Origin,
     id = ~ResponseId, estimate = "mm", by = ~opposeGDRsupport) %>% filter(feature == "Origin"),
  "Germany: Origin by GDR Assistance Attitudes",
  "Western Germans, ethnic German",
  file.path(fig_dir, "Figure_C3_DEU"),
  "BY"
)
plot_origin_by_group(
  cj(sk_sub, candidate_choice ~ Age + Family + Gender + Occupation + Origin,
     id = ~ResponseId, estimate = "mm", by = ~nkoppose) %>% filter(feature == "Origin"),
  "South Korea: Origin by NK Assistance Attitudes",
  "All respondents",
  file.path(fig_dir, "Figure_C3_KOR"),
  "BY"
)

# C4-C10: subgroup plots from saved outputs
plot_origin_by_group(read_csv(file.path(out_dir, "mm_germany_origin_by_regions.csv"), show_col_types = FALSE),
                     "Germany: Origin by Region", "Western Germans, ethnic German",
                     file.path(fig_dir, "Figure_C4"), "BY")
plot_origin_by_group(read_csv(file.path(out_dir, "mm_korea_origin_by_regions.csv"), show_col_types = FALSE),
                     "South Korea: Origin by Region", "All respondents",
                     file.path(fig_dir, "Figure_C5"), "BY")
plot_origin_by_group(read_csv(file.path(out_dir, "mm_germany_origin_by_west_generations.csv"), show_col_types = FALSE),
                     "Germany: Origin by Western Generations", "Western Germans, ethnic German",
                     file.path(fig_dir, "Figure_C6"), "BY")
plot_origin_by_group(read_csv(file.path(out_dir, "mm_germany_origin_by_education.csv"), show_col_types = FALSE),
                     "Germany: Origin by Education", "Western Germans, ethnic German",
                     file.path(fig_dir, "Figure_C7"), "BY")
plot_origin_by_group(read_csv(file.path(out_dir, "mm_korea_origin_by_education.csv"), show_col_types = FALSE),
                     "South Korea: Origin by Education", "All respondents",
                     file.path(fig_dir, "Figure_C8"), "BY")
plot_origin_by_group(read_csv(file.path(out_dir, "mm_germany_origin_by_partisan.csv"), show_col_types = FALSE),
                     "Germany: Origin by Political ID", "Western Germans, ethnic German",
                     file.path(fig_dir, "Figure_C9"), "BY")
plot_origin_by_group(read_csv(file.path(out_dir, "mm_korea_origin_by_polid.csv"), show_col_types = FALSE),
                     "South Korea: Origin by Political ID", "All respondents",
                     file.path(fig_dir, "Figure_C10"), "BY")

# Session info for reproducibility
sink(file.path(out_dir, "sessionInfo.txt"))
print(sessionInfo())
sink()

cat("Outputs written to", out_dir, "\n")
