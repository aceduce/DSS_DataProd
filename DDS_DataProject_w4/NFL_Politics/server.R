setwd("D:/Coursera/DS/Pack/DataProduct/DDS_DataProject_w4")

source("map.R",local=TRUE)

trend<-read.table("multiTimeline.csv", header=T, sep=",", skip=2, stringsAsFactors = FALSE)
corelat<-read.table("google_trend.csv",header=T,sep=",",skip=1, stringsAsFactors = FALSE)
survey<-read.table("surveymonkey.csv",header=T,sep=",",skip=1, stringsAsFactors = FALSE)
TeamState<-read.table("TeamByState.csv",header=T,sep=",",stringsAsFactors = FALSE)
#drop to lower case to match the maps

TeamState$State<-tolower(TeamState$State)
#Names for trend, NBA, NFL, MLB, NHL, CF
trend$date<-as.Date(trend$Week,"%Y-%m-%d")
#extract years
#year<-format(trend$date,"%Y")
names(trend)[2:6]=c("nfl","nba","mlb","nhl","cfb")
names(corelat)[9]<-"Vote"


for (i in 2:9) {
  corelat[,i]<-as.numeric(gsub("%","",corelat[,i]))/100
}

for (i in 21:25) {
  survey[,i]<-as.numeric(gsub("%","",survey[,i]))/100
}



library(shiny)
library(dplyr)
library(rCharts)
library(reshape2)
library(ggplot2)

# It has to loaded to plot ggplot maps on shinyapps.io
library(mapproj)
library(maps)

#for Interactive Visualizations


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$time <- renderText(paste("You have chose the weeks from",
                                  input$yr[1], "to",input$yr[2], sep=" "))
  output$leg <- renderText(paste("The League you have chosen is",input$sports,sep=" "))
  
  
  output$LEG_icon<-renderText({
  
  if(input$sports=="nba") {
    
    c(
      '<img src="',"NBA.png",'",width="', '"90" ',"height=", '"70">'
    )
  #  img(src='NBA.png', align = "left",width=80,height=80, margin=10)
    
  }else if(input$sports=="nfl"){
    
    c(
      '<img src="',"NFL.png",'",width="', '"90" ',"height=", '"70">'
    )
    
  # img(src='NFL.png', align = "left",width=80,height=80, margin=10)
    
  }else if(input$sports=="mlb"){
    
    c(
      '<img src="',"MLB.png",'",width="', '"90" ',"height=", '"70">'
    )
    #img(src='MLB.png', align = "left",width=90,height=70, margin=10)
  }else {
    c(
      '<img src="',"NFL.png",'",width="', '"90" ',"height=", '"70">',
      '<img src="',"NBA.png",'",width="', '"90" ',"height=", '"70">',
      '<img src="',"MLB.png",'",width="', '"70" ',"height=", '"70">'
    )
  }
})
  
  #prepare datasets
  dataTable <- reactive({
    if(input$sports=="all") {in_s<-c("nba","nfl","mlb")}
    else {in_s<-input$sports}
    
    trendByyear<-trend%>%
      filter(format(date,"%Y")>= input$yr[1] & format(date,"%Y")<input$yr[2])%>%
      select(c("date",in_s))
    })
  
  output$SearchTable <- renderDataTable({
    dataTable()
    }) #, options = list(bFilter = FALSE, iDisplayLength = 50)
  

#Show the search numbers for each sports
  
  output$SetsbyWeek <- renderChart({
    if(input$sports=="all") {in_s<-c("nba","nfl","mlb")}
    else {in_s<-input$sports}
    
    dt<-melt(dataTable(),id="date")
    
    dt$date<-format(dt$date, "%Y-%m-%d")
    
    p <- nPlot(value ~ date, data = dt,group= 'variable', type = 'multiBarChart'
                , dom = 'SetsbyWeek', width = 900)
    p$yAxis( axisLabel = "Number of Search",width=50)
    p$xAxis( axisLabel = "Weeks in Year-Month-Day")
    return(p)
  })
  #
  
st<-c("NBA","MLB","NHL","NFL","NASCAR","CBB","CFB")  
  dataTable2 <- reactive({
    corel<-corelat%>%
      select("DMA","Vote",st)
    return(corel)
  })
  
  dataTable3 <- reactive({
    corel<-corelat%>%
      select("DMA","Vote",input$sports1)
    return(corel)
  })
  
  modfit<-reactive({
    #Get coeffcients
      #Addressing issue. Cannot use input$sports1 to have the variable for regression.
      modfit<-lm(dataTable3()[,2]~dataTable3()[,3])

  })
 
  output$Coef<-renderText(
 
    #paste("The regression coefficeient (Slope) is ", modfit()[[1]][2] ,sep="")
    sprintf("The regression coefficeient (Slope) is %.2f",modfit()[[1]][2])
  )
  
  output$Conclu<-renderText(
    if( abs(modfit()[[1]][2]) <0.05) {
      "Nearly insensitve to party, indepenence"
      # img(src='Dem.png', align = "left",width=100,height=100, margin=10)
    }else if( modfit()[[1]][2] <0) {
      paste("For League ",input$sports1,", fan base leans to Democrats",sep="")
    # img(src='Dem.png', align = "left",width=100,height=100, margin=10)
    } else {
      paste("For League ",input$sports1,", fan base leans to Republics",sep="")
    #  img(src='GOP.png', align = "left",width=100,height=100, margin=10)
    }
  )
  
  output$PartImg<-renderText(
    if( abs(modfit()[[1]][2]) <0.05) {
      c(
        '<img src="',"IND.png",'",width="', '"90" ',"height=", '"70">'
      )
    }else if( modfit()[[1]][2] <0) {
      c(
        '<img src="',"Dem.png",'",width="', '"90" ',"height=", '"70">'
      )
    } else {
      c(
        '<img src="',"GOP.png",'",width="', '"90" ',"height=", '"70">'
      )
    }
  )
  
  output$Sets <- renderChart({
    m<-melt(dataTable3(),id=c("DMA","Vote"))
    p1<-nPlot(value~Vote, data=m, group="variable",type="scatterChart", dom="Sets", width=800)
    p1$yAxis( axisLabel = "Percetge Search for the sport" )
    p1$xAxis( axisLabel = "Percetge of Vote to Trump" )
    p1$set( title="Search % vs Vote %" )
    p1$xAxis(tickValues = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7))
    p1$chart(forceY = c(0, 0.6))
    #test
    p1$yAxis(tickValues = c(0.1,0.2,0.3,0.4,0.5,0.6))
 
    
    return(p1)#fit linear
    #Need to add linear fit line
  #  dataset = lm(m1$value~m1$Vote)$fitted.values
    
})

  output$Setfixed <- renderPlot({
    
      m1<-melt(dataTable2(),id=c("DMA","Vote"))
      g<-ggplot(m1,aes(x=Vote,y=value, color=variable))+
        #geom_line() + 
        geom_point()+
        geom_smooth(method="lm")+
        labs(title ="Sports and Politics", x = "% Vote for Trump", 
             y = "% of Search for Sports[Fan base]")+
        facet_wrap(~variable, ncol=4)
      print(g)
    })      

 # VoteM
  
  sur<-survey%>%
    select(c("Team", "GOP.","Ind.","Dem."))%>%
    melt(id="Team")
  
  output$VoteM <- renderChart({
     
      
      p3<-nPlot(value~Team,data=sur,type = 'multiBarChart',group='variable', 
                dom = 'VoteM', width = 1200)
      
      p3$chart(color = c('red', 'grey','blue'), stacked = TRUE)
      p3$xAxis( axisLabel = "Team Name",rotateLabels = 30 )
      p3$yAxis( axisLabel = "Vote Preference" )
 
      print(p3)
      return(p3)
    
  })
  
  
  #Data table
  
  #prepare datasets
  dataTableM <- reactive({
    sur1<-survey%>%
      select(c("Team", "GOP.","Ind.","Dem."))%>%
      merge(TeamState,by.x="Team",by.y="Team")
    sur1$Dif<-(sur1$GOP.-sur1$Dem.)
    #Re-label
    sur1$Cho<-(sur1$Dif>0)
    
    #could simplify to swich function
    if(input$Party=="Dem") {sel<-"Dem."}
    else if(input$Party=="GOP") {sel<-"GOP."}
    else if(input$Party=="Indp") {sel<-"Ind."}
    else {sel<-"Dif"}
    
    sur1<-sur1%>%
      select(c("Team",sel,"Cho","State"))
  })
  
  output$MapTable <- renderDataTable({
    dataTableM()
  }) #, options = list(bFilter = FALSE, iDisplayLength = 50)

  output$VoteD <- renderChart({
    
    sur1<-survey%>%
      select(c("Team", "GOP.","Ind.","Dem."))
    sur1$Dif<-(sur1$GOP.-sur1$Dem.)
    sur1<-sur1%>%
      select(c("Team","Dif"))
    #Re-labeling ************************
    sur1$Cho<-(sur1$Dif>0)
    
    sur1$Cho<-sapply(as.character(sur1$Cho),function(x) {
      switch(x, "TRUE"="Democrat Dominate","FALSE"="GOP dominates")})
    
    p4<-nPlot(Dif~Team,data=sur1,type = 'multiBarChart', group='Cho',
              dom = 'VoteD', width = 1200)
    p4$chart(color = c('red', 'blue'), stacked = FALSE)
    p4$xAxis( axisLabel = "Team Name",rotateLabels = 30 )
    p4$yAxis( axisLabel = "Vot to GOP" )
    print(p4)
    return(p4)
    
  })
  
  output$party<-renderText({
    
    if(input$Party=="Dem") {
      
      c(
        '<img src="',"Dem.png",'",width="', '"90" ',"height=", '"70">'
      )
      
    }else if(input$Party=="GOP"){
      
      c(
        '<img src="',"GOP.png",'",width="', '"90" ',"height=", '"70">'
      )
      
    }else if(input$Party=="Indp"){
      
      c(
        '<img src="',"IND.png",'",width="', '"90" ',"height=", '"70">'
      )
      #img(src='MLB.png', align = "left",width=90,height=70, margin=10)
    }else {
      c(
        '<img src="',"Dif.PNG",'",width="', '"90" ',"height=", '"70">'
      )
    }
  })
  
  #Vote by State
  states_map <- map_data("state")
  sur2<-survey%>%
    select(c("Team","Tot..Respondents","Total","Total.1","Total.2"))%>%
    filter(Team!="Grand Total")%>%
    merge(TeamState,by.x="Team",by.y="Team")%>%
    group_by(State)%>%
    summarise(Resp=sum(Tot..Respondents),Dem=sum(Total)/sum(Tot..Respondents),
              Indp=sum(Total.1)/sum(Tot..Respondents),
              GOP=sum(Total.2)/sum(Tot..Respondents),
              DIF=(sum(Total.2)-sum(Total))/sum(Tot..Respondents))  #Get the ratio (%) 
    
  output$VoteByState <- renderPlot({
    print(plot_by_state (
      dt = sur2,
      fill=input$Party,
      states_map = states_map, 
      title = "Fan based Vote Map from NFL team for %s Party",
      par=input$Party
    ))
  }, width=1000,height=700)
  ##Need to set up a function called "plot_by_state"
  
})
