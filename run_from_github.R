if (!require("shiny")) install.packages("shiny")
if (!require("httr2")) install.packages("httr2")
if (!require("tidyverse")) install.packages("tidyverse")
shiny::runGitHub( "shiny_prompt_checker", "bachl")
