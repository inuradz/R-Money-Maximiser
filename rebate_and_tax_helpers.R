

get_health_insurance_after_rebate <-  function(cost, taxable_income, health_care_rebate){
  as.numeric((1 -  health_care_rebate[min(which(taxable_income < health_care_rebate["Income"])),2]) * cost)
}

get_tax_owed  <- function(taxable_income,Tax_Brackets){
  tax_bracket <- min(which(taxable_income < Tax_Brackets["Upper_Threshold"])) #Figure out which tax bracket
  tax_payed   <- as.numeric(Tax_Brackets[tax_bracket,"Base"] + (taxable_income - Tax_Brackets[tax_bracket,"Lower_Threshold"] ) * Tax_Brackets[tax_bracket,"Rate"]) #Tax based on which tax bracket you are in
  tax_payed   <- tax_payed + taxable_income * 0.02 #Medicare Tax
  return(tax_payed)
}

get_hecs_repayment <- function(taxable_income,hecs_payment){
  as.numeric(hecs_payment[min(which(taxable_income < hecs_payment["Income"])),"Rate"] * taxable_income)
}



