
#' @export
server <- function(input, output){
  # Shiny app server logic

  model <- reactive({
    loadModel(input$model1$datapath)
  })
  image_matrix <- reactive({
    loadAndPrepareImage(input$image1$datapath)
  })
  image_tensor <- reactive({
    image_tensor <- createTensor(image_matrix())
    image_tensor <- normalizePixelIntensities(image_tensor)
  })
  class <- eventReactive(input$action1, {
    predictClass(model(), image_tensor())
  })
  probs <-   eventReactive(input$action1, {
    predictProbabilities(model(), image_tensor())
  })

  output$model_params <- renderPrint({
    print(model())
  }, width = 170)
  output$image_mtrx <- renderPrint({
    print(image_matrix()[, , 1])
  }, width = 200)
  output$pred_class <- renderText({
   class()
  })
  output$pred_probs <- renderTable({
    probs_to_print <- probs()
    probs_to_print$Probability <- as.character(probs_to_print$Probability)
    probs_to_print
  })
}
