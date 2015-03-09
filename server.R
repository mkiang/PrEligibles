library(shiny)
library(dplyr)
load("./data/subdata.RData")
source("./waterfall.r")

totalpop <- 316128839
under18 <- 73501617
    ##  numbers derived from larger ACS 2013 dataset (1%)
    ##  see analysis.r

shinyServer(function(input, output) {  
    
    current_perwt <- reactive({
        current_data <- subdata
        
        if (length(as.numeric(input$agegroups)) != 11) {
            current_data <- filter(current_data, 
                                   agecat %in% as.numeric(input$agegroups))
        }
        age <- sum(current_data$perwt) + under18
        
        if (as.numeric(input$sex) != 99) {
            current_data <- filter(current_data, sex == as.numeric(input$sex))
        }
        sex <- sum(current_data$perwt)
        
        if (length(as.numeric(input$marstatus)) != 5) {
            current_data <- filter(current_data, 
                                   marstcat %in% as.numeric(input$marstatus))
        }
        marital <- sum(current_data$perwt)
        
        if (as.numeric(input$mineduc) != 1) {
            current_data <- filter(current_data, 
                                   educat >= as.numeric(input$mineduc))
        }
        education <- sum(current_data$perwt)
        
        if (length(as.numeric(input$employ)) != 3) {
            current_data <- filter(current_data, 
                                   empstat %in% as.numeric(input$employ))
        }
        employment <- sum(current_data$perwt)
        
        if (as.numeric(input$mincome) != 1) {
            current_data <- filter(current_data, 
                                   incomecat >= as.numeric(input$mincome))
        }
        income <- sum(current_data$perwt)
        
        if (length(as.numeric(input$racegroups)) != 7) {
            current_data <- filter(current_data, 
                                   racecat %in% as.numeric(input$racegroups))
        }
        race <- sum(current_data$perwt)
    
        list(totalpop = totalpop, under18 = under18, 
             sex = sex, age = age, percent = sum(current_data$perwt) / totalpop,
             income = income, employment = employment, 
             education = education, race = race, 
             marital = marital)
    })
    
    output$table <- renderTable({
        percent <- current_perwt()$percent
        data.frame(
            Value = c(percent * 100,  
                      percent * 100000, 
                      round(percent * totalpop)), 
            Unit = c("Percent (%)", 
                     "Prevalence (per 100,000 people)", 
                     "People in the total US population"))
    })
    
    output$plot <- renderPlot({
        holder <- current_perwt()
        
        category <- c("1 Total", "2 Age", "3 Sex", "4 Marital", "5 Edu", 
                      "6 Employ", "7 Min Inc", "8 Race", "9 Eligible")
        
        x <- data.frame(category = as.ordered(category))
        x$value[1] <- holder$totalpop
        x$value[2] <- holder$age - holder$totalpop
        x$value[3] <- holder$sex - holder$age
        x$value[4] <- holder$marital - holder$sex
        x$value[5] <- holder$education - holder$marital
        x$value[6] <- holder$employment - holder$education
        x$value[7] <- holder$income - holder$employment
        x$value[8] <- holder$race - holder$income
        x$value[9] <- holder$race
        
        x$sector <- c("A", rep("B", 7), "C")
        levels(x$category) <- c("Whole US", 
                                "Didn't Meet Age Req", 
                                "Didn't Meet Sex Req", 
                                "Didn't Meet Marital Req", 
                                "Didn't Meet Education Req", 
                                "Didn't Meet Employment Req", 
                                "Didn't Meet Income Req", 
                                "Didn't Meet Race Req",
                                "Met All Reqs")
        
        p1 <- waterfall(x, offset = .2)
        p1 + theme_minimal() + labs(y = "People (in 100 millions)", x = "") + 
            theme(legend.position = "none", 
                  axis.text.x = element_text(angle = 45, hjust = 1)) + 
            scale_y_continuous(breaks = c(0, 1e8, 2e8, 3e8), 
                               labels = c("0", "1", "2", "3")) 
    }) 
})