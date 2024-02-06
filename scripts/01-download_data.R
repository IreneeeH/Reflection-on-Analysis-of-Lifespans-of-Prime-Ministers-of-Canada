#### Preamble ####
# Purpose: Downloads and saves the data from https://en.wikipedia.org/wiki/List_of_prime_ministers_of_Canada
# Author: Irene Huynh
# Date: 6 February 2024
# License: MIT


#### Workspace setup ####
library(tidyverse)
library(pdftools)
library(rvest)
library(xml2)

#### Download data ####
raw_data <-
  read_html(
    "https://en.wikipedia.org/wiki/List_of_prime_ministers_of_Canada"
  )

#### Save data ####
write_html(raw_data, "inputs/data/pms.html")