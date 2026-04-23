library(shiny)
library(DBI)
library(RSQLite)

ui <- fluidPage(
  sliderInput("nrows", "Enter the number of rows to display:",
              min = 1, max = 519, value = 15),
  dataTableOutput("tbl")
)

server <- function(input, output) {
  table <- renderDataTable({
    conn <- dbConnect(RSQLite::SQLite(), dbname = 'nba.db')
    sql <- "SELECT p.id, p.first_name, p.last_name, p.full_name, pp.urlPlayerHeadshot FROM player p INNER JOIN player_photos pp ON pp.idplayer = p.id WHERE p.is_active = 1"
    on.exit(dbDisconnect(conn), add = TRUE)
    table_df <- dbGetQuery(conn, paste0(sql, " LIMIT ", input$nrows, ";"))
    table_df$headshot <- paste0('<img src="', table_df$urlPlayerHeadshot, '"></img>')
    table_df[c('full_name', 'headshot')]
  }, escape = FALSE)
  output$tbl <- table
}

shinyApp(ui = ui, server = server)
