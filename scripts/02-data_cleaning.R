#### Preamble ####
# Purpose: Cleans the raw Prime Ministers of Canada data recorded by Wikipedia.
# Author: Irene Huynh
# Date: 6 February 2024
# License: MIT

#### Workspace setup ####
library(tidyverse)

#### Clean data ####
raw_data <- read_html("inputs/data/pms.html")
parse_data_selector_gadget <-
  raw_data |>
  html_element(".wikitable") |>
  html_table()

parsed_data <-
  parse_data_selector_gadget |> 
  clean_names() |> 
  rename(raw_text = name_birth_death) |> 
  select(raw_text) |> 
  filter(raw_text != "Name(Birth–Death)") |> 
  distinct()

initial_clean <-
  parsed_data |>
  separate(
    raw_text, into = c("name", "not_name"), sep = "\\(", extra = "merge",
  ) |> 
  mutate(date = str_extract(not_name, "[[:digit:]]{4}–[[:digit:]]{4}"),
         born = str_extract(not_name, "[[:digit:]]{4}")
  ) |>
  select(name, date, born)

cleaned_data <-
  initial_clean |>
  separate(date, into = c("birth", "died"), 
           sep = "–") |>   # PMs who have died have their birth and death years 
  # separated by a hyphen, but we need to be careful with the hyphen as it seems 
  # to be a slightly odd type of hyphen and we need to copy/paste it.
  mutate(
    born = str_remove_all(born, "born[[:space:]]"),
    birth = if_else(!is.na(born), born, birth)
  ) |> # Alive PMs have slightly different format
  select(-born) |>
  rename(born = birth) |> 
  mutate(across(c(born, died), as.integer)) |> 
  mutate(Age_at_Death = died - born) |> 
  distinct() # Some of the PMs had two goes at it.

cleaned_data <- cleaned_data |> filter(substring(name, 1, 1) != ".")

cleaned_data |>
  head() |>
  kable(
    col.names = c("Prime Minister", "Birth year", "Death year", "Age at death")
  )

#### Save data ####
write_csv(cleaned_data, "outputs/data/cleaned_data.csv")
