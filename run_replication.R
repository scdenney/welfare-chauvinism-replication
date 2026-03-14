packages <- c("tidyverse", "ggthemes", "remotes")
installed <- rownames(installed.packages())
missing <- setdiff(packages, installed)
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

if (!"cregg" %in% rownames(installed.packages())) {
  remotes::install_github("leeper/cregg")
}

source("code/analysis.R")
