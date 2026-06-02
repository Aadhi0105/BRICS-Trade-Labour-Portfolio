library(haven)
library(dplyr)
library(readr)

BASE <- path.expand(
  "~/Desktop/UZH/Pre-Doc/Prep/BRICS-Trade-Labour-Portfolio/03_labour_polarisation_india/data"
)

# Round configuration — exact file paths and column names per round
rounds <- list(
  list(
    round  = "2017-18",
    path   = file.path(BASE, "PLFS_Data_2017-18", "output", "hh_per_rv_2017_18.dta"),
    state  = "state_per_rv",    district = "district_per_rv",
    astat  = "b4q4_per_rv",    earnings = "b6q10_per_rv",
    mult   = "MULT_per_rv"
  ),
  list(
    round  = "2018-19",
    path   = file.path(BASE, "PLFS_Data_2018-19", "PerRV_2018-19.dta"),
    state  = "state_per_rv",    district = "district_per_rv",
    astat  = "b4q4_per_rv",    earnings = "b6q10_per_rv",
    mult   = "MULT_per_rv"
  ),
  list(
    round  = "2019-20",
    path   = file.path(BASE, "PLFS_Data_2019-20", "PERRV_2019-20.dta"),
    state  = "state_per_rv",    district = "district_per_rv",
    astat  = "b4q4_per_rv",    earnings = "b6q10_per_rv",
    mult   = "MULT_per_rv"
  ),
  list(
    round  = "2020-21",
    path   = file.path(BASE, "PLFS_Data_2020-21", "output", "perrv.dta"),
    state  = "state_perrv",     district = "dist_code_perrv",
    astat  = "b4q4_perrv",     earnings = "b6q10_perrv",
    mult   = "mult_perrv"
  ),
  list(
    round  = "2021-22",
    path   = file.path(BASE, "PLFS_Data_2021-22", "output", "perrv.dta"),
    state  = "state_perrv",     district = "dist_code_perrv",
    astat  = "b4q4_perrv",     earnings = "b6q10_perrv",
    mult   = "mult_perrv"
  ),
  list(
    round  = "2022-23",
    path   = file.path(BASE, "PLFS_Data_2022-23", "output", "perrv.dta"),
    state  = "state_perrv",     district = "dist_code_perrv",
    astat  = "b4q4_perrv",     earnings = "b6q10_perrv",
    mult   = "mult_perrv"
  )
)

all_wage <- list()

for (r in rounds) {
  cat(sprintf("\nLoading %s: %s\n", r$round, basename(r$path)))
  
  if (!file.exists(r$path)) {
    cat("  WARNING: file not found, skipping\n")
    next
  }
  
  df <- read_dta(r$path)
  
  df_clean <- df %>%
    select(
      state    = all_of(r$state),
      district = all_of(r$district),
      astat    = all_of(r$astat),
      earnings = all_of(r$earnings),
      mult     = all_of(r$mult)
    ) %>%
    mutate(
      state    = formatC(as.integer(state),    width=2, flag="0"),
      district = formatC(as.integer(district), width=2, flag="0"),
      state_district = paste0(state, "_", district),
      astat    = as.integer(astat),
      earnings = as.numeric(earnings),
      mult     = as.numeric(mult),
      round    = r$round
    ) %>%
    # Wage workers only: 3=regular salaried, 4=casual public, 5=casual other
    filter(
      astat %in% c(3, 4, 5),
      !is.na(earnings), earnings > 0,
      !is.na(mult),     mult > 0
    )
  
  cat(sprintf("  Wage workers with positive earnings: %d\n", nrow(df_clean)))
  cat(sprintf("  Unique districts: %d\n", n_distinct(df_clean$state_district)))
  
  all_wage[[r$round]] <- df_clean
}

# Combine all rounds
wage_all <- bind_rows(all_wage)
cat(sprintf("\nTotal wage worker observations: %d\n", nrow(wage_all)))
cat("By round:\n")
print(table(wage_all$round))

# Aggregate to state_district × round
# Weighted mean weekly earnings using survey multiplier as weight
wage_panel <- wage_all %>%
  group_by(state_district, round) %>%
  summarise(
    mean_wage_wtd = weighted.mean(earnings, w = mult, na.rm = TRUE),
    n_obs         = n(),
    .groups       = "drop"
  ) %>%
  mutate(
    ln_wage = log(mean_wage_wtd),
    year    = as.integer(substr(round, 1, 4)),
    sector  = "rural"
  )

cat(sprintf("\nWage panel: %d rows × %d cols\n", nrow(wage_panel), ncol(wage_panel)))
cat(sprintf("Unique state_districts: %d\n", n_distinct(wage_panel$state_district)))
cat(sprintf("Rounds: %s\n", paste(unique(wage_panel$round), collapse=", ")))

cat("\nWeekly wage summary (rupees):\n")
print(summary(wage_panel$mean_wage_wtd))

cat("\nLog wage summary:\n")
print(summary(wage_panel$ln_wage))

cat("\nDistricts per round:\n")
print(wage_panel %>% group_by(round) %>% summarise(n_districts = n()))

# Save
out_path <- file.path(BASE, "plfs_wage_panel.csv")
write_csv(wage_panel, out_path)
cat(sprintf("\nSaved: %s\n", out_path))
