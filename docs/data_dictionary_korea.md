# South Korea Job-Training Conjoint: Data Dictionary

File: `data/korea_job_training.csv`

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
- `Origin`: `North Hamgyong, DPRK`; `Busan, ROK`; `Gyeonggi, ROK`; `Hanoi, Vietnam`

## Respondent demographics

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `age` | derived | Respondent age (2023 - yob) | integer |
| `yob` | Q4 | Year of birth | integer (e.g., 1985) |
| `female` | Q2 | Gender at birth | `1` = female ("여성"), `0` = other |

## Geographic variable

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `province` | Q3 | Current province/city of residence | Korean province name (see below) |

### Province response values (Q3)
서울, 경기도, 인천, 강원도, 부산, 대구, 울산, 경북, 경남, 광주, 전북, 전남, 제주, 대전, 세종, 충북, 충남

## Education and political identification

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `education` | Q5 | Highest education level | Korean education levels (see below) |
| `political_ideology` | Q12 | Political self-identification | Korean ideology labels (see below) |
| `party_vote` | Q13 | Party vote intention | Korean party names (see below) |

### Education response values (Q5)
- `중학교` (middle school)
- `고등학교` (high school)
- `전문 대학교(기술 학교 포함)` (technical college)
- `대학교` (university)
- `대학원 이상` (graduate school or higher)

### Political ideology response values (Q12)
- `매우 진보적` (very progressive)
- `다소 진보적` (somewhat progressive)
- `중도적` (moderate)
- `다소 보수적` (somewhat conservative)
- `매우 보수적` (very conservative)
- `잘 모르겠다` (don't know)

### Party vote response values (Q13)
- `더불어민주당` (Democratic Party of Korea)
- `국민의힘` (People Power Party)
- `정의당` (Justice Party)
- Other party names and "잘 모르겠다" (don't know)

## Pre- and post-treatment survey items

| Variable | Survey Q | Description | Values |
|----------|----------|-------------|--------|
| `korean_pride` | Q28 | Pride in being Korean | `매우 자랑스럽다` (very proud), `어느 정도 자랑스럽다` (somewhat proud), `별로 자랑스럽지 않다` (not very proud), `전혀 자랑스럽지 않다` (not proud at all) |
| `national_identity` | Q123_1 | National identity strength (numeric scale) | numeric (0-10) |
| `ancestry_importance` | Q31_1 | Importance of Korean ancestry | `매우 중요하다` (very important), `대체로 중요하다` (somewhat important), `별로 중요하지 않다` (not very important), `전혀 중요하지 않다` (not at all important) |
| `birthplace_importance` | Q31_2 | Importance of being born in Korea | same as Q31_1 |
| `national_composition` | Q34 | Views on ethnic/cultural composition | `다민족·다문화국가` (multi-ethnic/multicultural), `단일민족·단일문화국가` (ethnically homogeneous), `잘 모르겠다` (don't know) |
| `support_nk_engagement` | Q46 | Support for engaging with North Korea | `동의한다` (agree), `동의하지 않는다` (disagree) |
| `support_nk_defectors` | Q48 | Support for NK defector assistance | `동의한다` (agree), `동의하지 않는다` (disagree) |

## Derived variables (constructed in analysis code)

The analysis script (`analysis.R`) derives the following variables from the raw survey responses above:

- `university_education`: binary from `education` ("대학교" or "대학원 이상" = 1)
- `regions`: Capital Area/Yeongnam/Chungcheong-Honam from `province`
- `demogenF`: democratic/authoritarian generation from `yob` (cutoff: 1975)
- `progressive`: binary from `political_ideology` (progressive self-ID = 1)
- `conservative`: binary from `political_ideology` (conservative self-ID = 1)
- `progressive.leaners`: progressive + moderate who vote Democratic/Justice Party, from `political_ideology` + `party_vote`
- `conservative.leaners`: conservative + moderate who vote People Power, from `political_ideology` + `party_vote`
- `natidstrong`: above-median national identity from `national_identity`
- `ethnocentric`: both ancestry and birthplace rated important, from `ancestry_importance` + `birthplace_importance`
- `nkoppose`: opposition to NK assistance from `support_nk_engagement` + `support_nk_defectors`
- `nosupportnkdef`: opposes NK defector support from `support_nk_defectors`
- `nosupportnkdef.strict`: strict opposition from `support_nk_engagement` + `support_nk_defectors`
- `pride`: proud of being Korean from `korean_pride`
- `natid2`: multi-ethnic vs homogeneous from `national_composition`
- `age.median`: above-median age from `age`

## Notes
- This dataset includes respondents who passed the attention check. Overseas residents (해외) were excluded during data preparation. Filters for specific SI subgroups are applied in the analysis code.
- The `Record` level `None` is a literal string; some software (e.g., pandas) may auto-convert it to missing unless you disable default NA parsing.
- The `Age` levels are standardized to `25`, `35`, `46`, `62` to match the published design in the manuscript.
- All survey response values are in the original Korean language; English translations are provided in parentheses in this dictionary.
