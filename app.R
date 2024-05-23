library(shiny)
source("prompt_checker_function.R")

ui <- fluidPage(
  titlePanel("Zero-Shot Klassifikation mit der OpenAI API"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("api_key", "API Key:"),
      numericInput("max_tokens", "Maximum of tokens:", value = 40L),
      textAreaInput("prompt", "Prompt:", rows = 8,
                    value = "Your task is to evaluate whether a comment contains incivility.\n\nIncivility is defined as a statement that contains any of the following features: Vulgarity, Inappropriate Language, Swearing, Insults, Name Calling, Profanity, Dehumanization, Sarcasm, Mockery, Cynicism, Negative Stereotypes, Discrimination, Threats of Violence, Denial of Rights, Accusations of Lying, Degradation, Disrespect, Devaluation.\n\nYou should assign the comment a numeric label, 1 or 0.\n1. The comment is incivil. It contains any of the mentioned features.\n0. The comment is civil. It does not contain any of the mentioned features.\n\nAnswer in JSON format with the template below.\n\n{\n  \"label\": 1,\n  \"motivation\": \"The comment is incivil. It has many elements of an uncivil comment, such as name-calling, mockery, and threats of violence.\"\n}\n"),
      textAreaInput("texts", "Texts to Classify:", rows = 5, 
                    value = "du föllidiöt!\nmei bist du ein hübsches mädel"),
      actionButton("submit", "Submit")
    ),
    
    mainPanel(
      tableOutput("results")
    )
  )
)

server <- function(input, output, session) {
  
  results <- eventReactive(input$submit, {
    txts = strsplit(input$texts, "\n")[[1]]
    classify(api_key = input$api_key,
             text_file = txts,
             prompt_file = input$prompt,
             max_tokens = input$max_tokens)
  })
  
  output$results <- renderTable({
    results()
  })
}

shinyApp(ui, server)
