
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Money Visualiser for expenses"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("income",
                  "Yearly Income:",
                  min = 0,
                  max = 250000,
                  value = 100000),
      numericInput("super_percentage", 
                   "Super annuation contribution percentage from base salary", 
                   value = 9.5,
                   min = 0,
                   step = 0.1),
      sliderInput("health_insurance",
                  "Private health insurance cost",
                  min = 0,
                  max = 10000,
                  value = 3000),
      sliderInput("super_annuation",
                  "Extra Super Annutation Bonus",
                  min = 0,
                  max = 25000,
                  value = 0),
      sliderInput("tax_deductibles",
                  "How much to deduct from tax",
                  min = 0,
                  max = 25000,
                  value = 0),
      sliderInput("utilities",
                  "How much will utilities cost per week:",
                  min = 0,
                  max = 2500,
                  value = 0),
      textOutput("weekly_spending"),
      textOutput("remaing_weekly_money")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      plotOutput("tax_deduction_maximum"),
      plotOutput("tax_deduction_ratio")
    )
  )
))
