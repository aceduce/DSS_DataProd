#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(rCharts)
library(reshape2)
library(ggplot2)
library(markdown)

# It has to loaded to plot ggplot maps on shinyapps.io
library(mapproj)
library(maps)

# Define UI 
shinyUI(
  navbarPage("NFL and Politics",
  #using Multi-page user-interface 
# Tab#1
  tabPanel("Search Trend",
           sidebarPanel(
             
             h4("Introduction on Explorer"),
             h5("Essentially, this tool is trying to look at the political preference,
                from the major league fan (such as NFL). The political preference is reflected in who they vote in presidential election in 2016,
                that's to Say either Trump (R) or Hilary (D)"),
             
             selectInput("sports",h4("League to choose"), 
                         choices = list("NBA"="nba","MLB"="mlb","NFL"="nfl","Big 3"="all"),
                         selected = "nfl"),
             sliderInput("yr",
                         "Year:",
                         min=2012,
                         max=2017,
                         value=c(2013,2016)),
    
             img(src='GOP.png', align = "left",width=100,height=100, margin=10), 
             img(src='Dem.png', align = "left",width=100,height=100, margin=10), 
             
             p("Step1: Start by looking at the search trend line. 
               The times people search for each major leagues."),
             p("Step2: 
               Find the correlations between the fans base and the political preference."),
             p("Step3:
               Examine the fan base in each US State and predomiantly, the candidate voted by,
               the portion of the voters"),
             h4("The Timeline"),
             textOutput("time"),
             h4("The League"),
             textOutput("leg"),
             htmlOutput("LEG_icon", width=800,height = 350),
         #    imageOutput("LEG_icon", width=800,height = 350)
             h3("Key Takeaways"),
             p("NFL fan is the most party-neutal sport fan base and also the most trending sports ovearall,
                MLB and NBA tends to be more leaning towards democrat party"),
             br(),
             p("Major fan-based Vote from team located in states are detailed at Tab Geographic")
             
  
             
           ),#End sidebarPanel
           
           img(src='NBA.png', align = "left",width=80,height=80, margin=10), 
           img(src='MLB.png', align = "left",width=90,height=70, margin=10),
           img(src='NFL.png', align = "left",width=80,height=80, margin=10),
            
      mainPanel(
        
        tabsetPanel(
 
          #Visual
          tabPanel(p(icon("line-chart"),"Visulizations"), 
                   h3("Search Trend for the Key Sports Leagues", align="center"),
                   showOutput("SetsbyWeek", "nvd3"),
                   h6("Note: Current data set collected from 2012-10-28 to 2016-12-25")
              ),
          #Data
          tabPanel(p(icon("table"),"Search table"),
                   
                   dataTableOutput(outputId="SearchTable")
          )
      )
       
        
      )#End mainPanel
  ),
  

# Tab#2
  tabPanel("Analytics",
           #do analytics here. 
           
           sidebarPanel(
             
             p("Examine the percentage of search vs percentage of vote for GOP (Trump),
               One can see as the largely three types of behaviors:"),
             br(),
             h5("1. NBA, MLB,NHL: As search goes up (More Fans), less votes to GOP."),
             h5("2. NFL: Nearly flat line, neutral to parties"),
             h5("3. NSCAR, CBB and CFB: Reverse trend to 1. Favor GOP as fan base increases(
                reflected by Search %)"),
             p("A simple linear regression is used for the choice of League you choose:"),
             
             selectInput("sports1",h4("League to choose"), 
                         choices = list("NBA"="NBA","MLB"="MLB","NHL"="NHL",
                                        "NASCAR"="NASCAR","CBB"="CBB", "NFL"="NFL",
                                        "CFB"="CFB"),
                         selected = "NBA"),
             h4("Key feature"),
             textOutput("Coef"),
             textOutput("Conclu"),
             htmlOutput("PartImg")
             
             
           ),
           
           
           
    mainPanel(
      h3("Fan base in Sports vs Politcal Views", align="center"),
      plotOutput("Setfixed", width=800,height = 350),
      #Fix
      h4("The correlation between the Sport of chosen and the Vote 2016",align="center"),
      
      showOutput("Sets", "nvd3")
      
      #plotOutput("plot1"),
      
      
      
      )
        ),#End TabPanel#2

# Tab#3
tabPanel("Deep Dive into NFL",
         #do analytics here. 
         mainPanel(
           img(src='NFL.png', align = "left",width=80,height=80, margin=10),
           h3("Fan based Votes Preference",align="center"),
           fluidRow(
             tags$div(
               style="margin-bottom:100px;",
               showOutput("VoteM", "nvd3")
             )
           ),
           h3("Fan based Votes Net",align="center"),
           showOutput("VoteD", "nvd3")
         )
),#End TabPanel#3

#color list:

#colist<- 

tabPanel("Geographic NFL Votes",
         
         sidebarPanel(
           selectInput("Party",h4("The Political Party"), 
                       choices = list("Democrat"="Dem","Republic"="GOP",
                                      "Independence"="Indp","Net GOP (difference)"="DIF"),
                       selected = 1),
           htmlOutput("party", width=800,height = 350),
           br(),
           h4("NFL Teams", align="left"),
           img(src='NFLteams.png', align = "left",width=450,height=320, margin=10)
         ),
         
    mainPanel(
      
    
      
      tabsetPanel(
        #Map
        tabPanel(p(icon("map-marker"),"Geographics"),
                 #do analytics here. 
         
                 mainPanel(
                   h3("Fan based Vote Map from NFL team",align="center"),
                   plotOutput("VoteByState")
                   
                   
                 )
        ),#End TabPanel map-marker
        #Data
        tabPanel(p(icon("table"),"Data"),
               dataTableOutput(outputId="MapTable")
        )
      )
    )
),

    # Tab#5
    tabPanel("About",
             #do analytics here. 
             mainPanel(
               includeMarkdown("about.md")
               
             )
    )#End TabPanel#5
  
    )#End Navpage
)

  
  