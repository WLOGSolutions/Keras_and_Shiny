#' @export
ui <- function() {
  # Layout definition for Shiny app

  ui <- fluidPage(
    titlePanel("Digit identification"),
    sidebarLayout(
      sidebarPanel(
        fileInput("model1", "Choose HDF5 model file"),
        fileInput("image1", "Choose image"),
        tags$b("Click to identify a digit"),
        tags$br(),
        actionButton("action1", "Identify!"),
        tags$br(), tags$br(),
        tags$b("Identified class:"),
        tags$br(),
        tags$b(textOutput("pred_class")),
        tags$style("#pred_class{color: red; font-size: 30px;}"),
        tags$br(),
        tags$b("Class probabilities:"),
        tags$br(),
        tableOutput("pred_probs"),
        width = 3
      ),
      mainPanel(
        tags$style(type="text/css",
                   ".shiny-output-error { visibility: hidden; }",
                   ".shiny-output-error:before { visibility: hidden; }"),
        tags$b("Image as matrix:"),
        tags$br(),
        verbatimTextOutput("image_mtrx"),
        tags$br(),
        tags$b("Model architecture:"),
        tags$br(),
        verbatimTextOutput("model_params")
      )
    )
  )

  return(ui)
}
