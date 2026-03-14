# Germany Job-Training Conjoint: Data Dictionary

File: `data/germany_job_training.csv`

## Unit of observation
- One row per candidate profile shown in a conjoint task.
- Respondents evaluate two profiles per task; `question_profile` identifies the task/profile.

## Key analysis variables
- `ResponseId`: respondent identifier (string)
- `question_profile`: task/profile identifier (e.g., `1.1`, `1.2`)
- `candidate_choice`: binary; `1` if profile chosen, `0` otherwise

## Conjoint attributes (translated to English)
- `Age`: `25`, `35`, `46`, `62`
- `Family`: `Single, no children`; `Married, 1 child`; `Married, 2 children`; `Single, 1 child`
- `Gender`: `Male`; `Female`
- `Occupation`: `Part-time supermarket employee`; `Employee in a department store`; `Security guard`; `Store manager`
- `Record`: `None`; `Theft`; `Tax evasion`
- `Origin`: `Saxony, DE`; `Hamburg, DE`; `Bavaria, DE`; `Bucharest, RO`

## Respondent demographics

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `age` | derived | Respondent age (2023 - yob) | integer |
| `yob` | Q2 | Year of birth | integer (e.g., 1965) |
| `female` | Q7 | Gender at birth | `1` = female ("Weiblich"), `0` = other |

## Geographic variables

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `state_at_18` | Q5 | German state at age 18 | German state name (e.g., "Bayern", "Sachsen", "Ost-Berlin (vor der Wiedervereinigung)") |
| `current_state` | Q6 | Current state of residence | German state name |

## Education and political identification

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `education` | Q8 | Highest education level | German education levels (see below) |
| `ethnicity` | Q27 | Ethnic identification | e.g., "Deutsch", "Türkisch", "Polnisch", "Andere" |
| `party_vote` | Q11 | Party vote intention | German party names or "Ich weiß es nicht", "Eine andere Partei" |

### Education response values (Q8)
- `Grundschule nicht beendet`
- `Grundschule beendet, aber (noch) kein Abschluss einer weiterführenden Schule`
- `Volks-/Hauptschulabschluss bzw. Polytechnische Oberschule mit Abschluss 8. oder 9. Klasse`
- `Mittlere Reife/Realschulabschluss bzw. Polytechnische Oberschule mit Abschluss 10. Klasse`
- `Fachhochschulreife (Abschluss einer Fachoberschule etc.)`
- `Abitur bzw. Erweiterte Oberschule mit Abschluss 12. Klasse (Hochschulreife)`
- `(Fach)Hochschulabschluss (Bachelor)`
- `(Fach)Hochschulabschluss (Diplom, Master oder höher)`

### Party vote response values (Q11)
- `Sozialdemokratische Partei Deutschlands (SPD)`
- `Bündnis 90/Die Grünen`
- `DIE LINKE`
- `Christlich Demokratische Union (CDU) Christlich-Soziale Union (CSU)`
- `Freie Demokratische Partei (FDP)`
- `Alternative für Deutschland (AfD)`
- `Ich weiß es nicht`
- `Eine andere Partei`

## Pre- and post-treatment survey items

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `national_identity` | Q28_1 | "How German do you feel?" (0-10 scale) | `0` ("überhaupt nicht deutsch") to `10` ("sehr deutsch") |
| `ancestry_importance` | Q63_1 | Importance of having German ancestors | `Sehr wichtig`, `Eher wichtig`, `Nicht sehr wichtig`, `Überhaupt nicht wichtig` |
| `birthplace_importance` | Q63_2 | Importance of being born in Germany | same as Q63_1 |
| `support_needy_training` | Q60 | "The state should offer special support for job training to needy citizens" | `Stimme zu` (agree), `Stimme nicht zu` (disagree) |
| `support_gdr_training` | Q62 | "The state should offer special support for job training to citizens of former GDR districts" | `Stimme zu` (agree), `Stimme nicht zu` (disagree) |

## Derived variables (constructed in analysis code)

The analysis script (`analysis.R`) derives the following variables from the raw survey responses above:

- `east.germany.F`: East/West/Berlin classification from `state_at_18`
- `ethnic_german`: binary from `ethnicity == "Deutsch"`
- `university_education`: binary from `education` (tertiary = 1)
- `regions`: North/South from `current_state`
- `west.generations`: pre-/post-unification cohorts from `yob` + `east.germany.F`
- `partisan_group`: Left-wing/Center/Right-wing/Other from `party_vote`
- `natidstrong`: above-median national identity from `national_identity`
- `ethnocentric`: both ancestry and birthplace rated important, from `ancestry_importance` + `birthplace_importance`
- `opposeGDRsupport`: agrees with Q60 but disagrees with Q62, from `support_needy_training` + `support_gdr_training`
- `age.median`: above-median age from `age`

## Notes
- This dataset includes respondents who passed the attention check and have non-missing national identity strength. It retains East/West and Berlin respondents to allow SI subgroups; filters for Western Germans and ethnic Germans are applied in the analysis code.
- The `Record` level `None` is a literal string; some software (e.g., pandas) may auto-convert it to missing unless you disable default NA parsing.
- The `Age` levels are standardized to `25`, `35`, `46`, `62` to match the published design in the manuscript.
- All survey response values are in the original German language.
