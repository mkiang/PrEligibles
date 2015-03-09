library(shiny)

shinyUI(fluidPage(
    titlePanel("Prevalence of Eligibles in the United States"),
    fluidRow(
        column(9, 
               p("A demographic calculator. Select your criteria 
                 and it will tell you the number of people in the US who meet
                 them. Uses data from the ", 
                 a("2013 American Community Survey (ACS)", 
                   href = "http://www.census.gov/acs/www/data_documentation/2013_release/"), "accessed through", 
                 a("IPUMS.", 
                   href = "https://usa.ipums.org/usa/index.shtml")
               ),
               p("This was made in a rush and as a (half) joke for my 
                    single friends. It probably has bugs. 
                 Full code can be found on my  ", 
                 a("GitHub.", href = "https://github.com/mkiang/PrEligibles"), 
                 "I haven't debugged any of this and it's not meant to be 
                    taken seriously. 
                 It was inspired by ", 
                 a("this Business Insider post.", 
                   href = "http://www.businessinsider.com/highly-eligible-singles-2015-2"), 
                 p("The waterfall plot is made to be read left to right. It
                   starts with the entire US population and shows each section
                   disqualified until the final column, which shows the number
                   of people who meet all requirements. Code came from James
                   Keirstead (link below)."),
                 p("Note about the data: this comes from the ACS 1% sample. 
                    These data will probably slightly underestimate 
                   very rare populations."
                 )
                 )
                 )
                 ),
    fluidRow(
        column(4, wellPanel(
            selectInput('sex', 'Sex', 
                        choices = list("Males" = 1, 
                                       "Females" = 2, 
                                       "Both" = 99)),
            checkboxGroupInput('agegroups', label = 'Age:',
                               choices = list("18 - 20" = 1, "21 - 25" = 2, 
                                              "26 - 30" = 3, "31 - 35" = 4, 
                                              "36 - 40" = 5, "41 - 45" = 6, 
                                              "46 - 50" = 7, "51 - 55" = 8, 
                                              "56 - 60" = 9, "60 - 65" = 10, 
                                              "66 and up" = 11), 
                               selected = 2:4), 
            checkboxGroupInput('marstatus', label = 'Marital Status:',
                               choices = list("Married" = 1, 
                                              "Separated" = 3, 
                                              "Divorced" = 4, 
                                              "Widowed" = 5, 
                                              "Single / never married" = 6), 
                               selected = c(4, 5, 6)),
            checkboxGroupInput('racegroups', label = 'Race/Ethnicity:',
                               choices = list("White" = 1, 
                                              "African American" = 2, 
                                              "American Indian / 
                                              Alaska Native" = 3, 
                                              "Chinese" = 4, 
                                              "Japanese" = 5, 
                                              "Other Asian or 
                                              Pacific Islander" = 6, 
                                              "All others" = 7), 
                               selected = 1:7),
            selectInput('mineduc', 'Minimum Educational Attainment', 
                        choices = list("No HS diploma or GED" = 1, 
                                       "HS diploma or GED" = 2, 
                                       "Some college, no degree" = 3, 
                                       "Associate's degree" = 4,
                                       "Bachelor's degree" = 5, 
                                       "Master's degree" = 6, 
                                       "Professional degree 
                                       (beyond bachelor's)" = 7, 
                                       "Doctoral degree" = 8)), 
            checkboxGroupInput('employ', label = 'Employment Status:',
                               choices = list("Employed" = 1, 
                                              "Unemployed" = 2, 
                                              "Not in labor force" = 3), 
                               selected = 1), 
            selectInput('mincome', label = 'Minimum Annual Income:',
                        choices = list("No minimum" = 1, 
                                       "$0 - 25000" = 2, 
                                       "$25,001 - $50,000" = 3, 
                                       "$50,001 - $75,000" = 4, 
                                       "$75,001 - $100,000" = 5, 
                                       "$100,001 - $150,000" = 6, 
                                       "$150,001 - $200,000" = 7, 
                                       "$200,001 - $250,000" = 8, 
                                       "$250,001 - $350,000" = 9, 
                                       "$350,001 - $500,000" = 10, 
                                       "$500,001 - $1,000,000" = 11, 
                                       "$1,000,001 or more" = 12), 
                        selected = 3), 
            submitButton()
            )
            ),
        column(8, wellPanel(
            h3("Results"), 
            tableOutput('table'), 
            plotOutput('plot', height = "500px")
        ))), 
    fluidRow(
        column(8,
               h4("Citations:"), 
               p("Steven Ruggles, J. Trent Alexander, Katie Genadek, Ronald Goeken, 
             Matthew B. Schroeder, and Matthew Sobek. Integrated Public Use 
             Microdata Series: Version 5.0 [Machine-readable database]. 
             Minneapolis: University of Minnesota, 2010."), 
               p("Waterfall plot code is from", 
                 a("James Keirstead's blog post.", 
                   href = "http://www.jameskeirstead.ca/blog/waterfall-plots-in-r/")
                 )
        )
    )
))