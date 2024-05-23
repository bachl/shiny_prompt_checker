# Erstelle Anfrage an OpenAI API ####
create_request = function(api_key, model = "gpt-4o",
                          instruction = "", coding_unit = "Hello, World",
                          temperature = 0, max_tokens = 40, throttle = 5000/60) {
  request(base_url = "https://api.openai.com/v1/chat/completions") |> 
    req_auth_bearer_token(api_key) |> 
    req_body_json(list(
      model = model,
      response_format = list(type = "json_object"),
      messages = list(
        list(role = "system", content = instruction),
        list(role = "user", content = coding_unit)
      ),
      temperature = temperature,
      max_tokens = max_tokens
    )) |> 
    req_throttle(rate = throttle)
}

# Funktion zum Ergänzen des JSON-Endes
add_json_end = function(output) {
  if (str_ends(output, fixed('\"\n}'))) {
    output
  } else if (str_ends(output, fixed('\n'))) {
    paste0(output, '}')
  } else if (str_ends(output, fixed('\"'))) {
    paste0(output, '\n}')
  } else {
    paste0(output, '\"\n}')
  }
}

# Klassifikation von Testmaterial mit einem Zero-shot Prompt ####
classify = function(api_key, text_file, prompt_file,
                    out_file = "classifications.html",
                    model = "gpt-4o",
                    temperature = 0, max_tokens = 40, throttle = 5000/60) {
  
  # Lade Pakete
  library(httr2)
  library(jsonlite)
  library(tidyverse)

  # Datei für Test-Material
  # Eine Codiereinheit pro Zeile
  test = text_file

  # Datei für den Prompt
  prompt = prompt_file
  
  # Anfragen an API erstellen
  requests = test |> 
    map(~create_request(api_key = api_key,
                        model = model,
                        temperature = temperature,
                        max_tokens = max_tokens,
                        throttle = throttle,
                        instruction = prompt,
                        coding_unit = .x))
  
  # Anfragen an API senden und Antworten erhalten
  responses = requests |> 
    req_perform_sequential()

  # Klassifikation und Begründung aus Antworten extrahieren
  classifications = responses |> 
    resps_data(
      \(resp) {
        resp |> 
          resp_body_json() |> 
          pluck("choices") |>
          pluck(1) |>
          pluck("message") |>
          pluck("content")
      }
    ) |> 
    map_chr(add_json_end) |> 
    map(~fromJSON(.x)) |> 
    map_dfr(as_tibble)

  # Ergebnisse im Viewer ausgeben
  classifications |> 
    mutate(text = test) |> 
    relocate(text, .before = 1)
}
