
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(readr)
library(ggplot2)
library(ggrepel)

source("rebate_and_tax_helpers.R")

shinyServer(function(input, output, session) {
  
  health_care_rebate <- read_csv("~/git/R-Money-Maximiser/health_care_rebate.csv")
  Tax_Brackets <- read_csv("~/git/R-Money-Maximiser/Tax_Brackets.csv")
  hecs_payment <- read_csv("~/git/R-Money-Maximiser/hecs_payment.csv")

  observe({
    max_tax_free_supercontribution <- 25000 - input$income * (input$super_percentage/100) 
    updateSliderInput(session, "super_annuation", max = max_tax_free_supercontribution)
    updateSliderInput(session, "tax_deductibles", max = input$income)
  })
  
  
  output$distPlot <- renderPlot({
    
    taxable_income        <- input$income - input$super_annuation - input$tax_deductibles
    
    health_insurance_cost <-  get_health_insurance_after_rebate(input$health_insurance,taxable_income,health_care_rebate)
    tax_payed             <-  get_tax_owed(taxable_income,Tax_Brackets)
    hecs_repayment        <-  get_hecs_repayment(taxable_income,hecs_payment)
    
    remaining             <- input$income - health_insurance_cost - tax_payed - input$super_annuation - input$tax_deductibles - hecs_repayment - (input$utilities *52)
    
    updateSliderInput(session,"tax_deductibles",max = remaining)
    
    output$weekly_spending <- renderText({
      return(paste("Money spent per week: ",toString((input$income - remaining)/52)))
    })
    
    output$remaing_weekly_money <- renderText({
      return(paste("Money left after the week: ",toString((remaining)/52)))
    })
    
    Income <- c(rep("Income" , 7))
    condition <- rep(c("Tax" , "Health Insurance", "Super Annuation Payment", "Tax Deductibles", "HECS", "Utilities","Left Overs"))
    value <- abs(c(tax_payed,health_insurance_cost,input$super_annuation,input$tax_deductibles,hecs_repayment,input$utilities * 52 ,remaining))
    data <- data.frame(Income,condition,value)
    
    # Stacked
    ggplot(data, aes(fill=condition, y=value, x=Income)) + 
      geom_bar(position="stack", stat="identity") +
      geom_text(aes(label = value), size = 3, vjust = "center", hjust = "center",position = "stack") 

  })
  
  output$tax_deduction_maximum <- renderPlot({
    get_remaining <- function(taxable_income){
      health_insurance_cost <-  get_health_insurance_after_rebate(input$health_insurance,taxable_income,health_care_rebate)
      tax_payed             <-  get_tax_owed(taxable_income,Tax_Brackets)
      hecs_repayment        <-  get_hecs_repayment(taxable_income,hecs_payment)
      
      remaining             <- taxable_income - health_insurance_cost - tax_payed - hecs_repayment
      return(remaining)
    }
    
    taxable_income  <- seq(5000,140000,by=1000)
    remaining_money <- unlist(lapply(taxable_income,get_remaining))
    ratio           <- mapply(function(rem,inc){return (rem/inc)}, remaining_money, taxable_income)
    
    
    output$tax_deduction_ratio <- renderPlot({
      other_df <- data.frame(taxable_income,ratio)
      ggplot(data=other_df, aes(x=taxable_income, y=ratio, group=1)) +
        geom_line()+
        geom_point() #+
        #geom_text_repel(aes(label=ratio),hjust=0, vjust=0)
    })
    
    df <- data.frame(taxable_income,remaining_money)
    
    ggplot(data=df, aes(x=taxable_income, y=remaining_money, group=1)) +
      geom_line()+
      geom_point() #+
      #geom_text(aes(label=remaining_money),hjust=0, vjust=0)
  })

})
