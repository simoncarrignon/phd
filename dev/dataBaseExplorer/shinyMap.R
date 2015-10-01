 library(scales)
install.packages("shinydashboard")
require("shinydashboard")
 library(mapdata)
 library(leaflet)
 install.packages("leaflet")

body <- dashboardBody(
		      # infoBoxes
		      fluidRow(
			       infoBox(
				       "Orders", uiOutput("orderNum2"), "Subtitle", icon = icon("credit-card")
				       ),
			       infoBox(
				       "Approval Rating", "60%", icon = icon("line-chart"), color = "green",
				       fill = TRUE
				       ),
			       infoBox(
				       "Progress", uiOutput("progress2"), icon = icon("users"), color = "purple"
				       )
			       ),
		      # valueBoxes
		      fluidRow(
			       valueBox(
					uiOutput("orderNum"), "New Orders", icon = icon("credit-card"),
					href = "http://google.com"
					),
			       valueBox(
					tagList("60", tags$sup(style="font-size: 20px", "%")),
					"Approval Rating", icon = icon("line-chart"), color = "green"
					),
			       valueBox(
					htmlOutput("progress"), "Progress", icon = icon("users"), color = "purple"
					)
			       ),
		      # Boxes
		      fluidRow(
			       box(status = "primary",
				   sliderInput("orders", "Orders", min = 1, max = 2000, value = 650),
				   selectInput("progress", "Progress",
					       choices = c("0%" = 0, "20%" = 20, "40%" = 40, "60%" = 60, "80%" = 80,  "100%" = 100)
					       )
				   ),
			       box(title = "Histogram box title",
				   status = "warning", solidHeader = TRUE, collapsible = TRUE,
				   plotOutput("plot", height = 250)
				   )
			       ),
		      # Boxes with solid color, using`   background    `

		      fluidRow(
			       # Box with textOutput
			       box(
				   title = "Status summary",
				   background = "green",
				   width = 4,
				   textOutput("status")
				   ),
			       # Box with HTML output, when finer control over appearance is needed
			       box(
				   title = "Status summary 2",
				   width = 4,
				   background = "red",
				   uiOutput("status2")
				   ),
			       box(
				   width = 4,
				   background = "light-blue",
				   p("This is content. The background color is set to light-blue")
				   )
			       )
		      )
server <- function(input, output) {
    output$orderNum <- renderText({
	prettyNum(input$orders, big.mark=",")
    })
    output$orderNum2 <- renderText({
	prettyNum(input$orders, big.mark=",")
    })
    output$progress <- renderUI({
	tagList(input$progress, tags$sup(style="font-size: 20px", "%"))
    })
    output$progress2 <- renderUI({
	paste0(input$progress, "%")
    })
    output$status <- renderText({
	paste0("There are ", input$orders,
	       " orders, and so the current progress is ", input$progress, "%.")
    })
    output$status2 <- renderUI({
	iconName <- switch(input$progress,
			   "100" = "ok",
			   "0" = "remove",
			   "road"
			   )
	p("Current status is: ", icon(iconName, lib = "glyphicon"))
    })
    output$plot <- renderPlot({
	hist(rnorm(input$orders))
    })
}
shinyApp(
	 ui = dashboardPage(
			    dashboardHeader(),
			    dashboardSidebar(),
			    body
			    ),
	 server = server
	 )

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
		      dashboardHeader(),
		        dashboardSidebar(),
			  dashboardBody()
		      )


ui <- fluidPage(
		titlePanel("Map ofAmphora and all"),

		sidebarLayout(
			      sidebarPanel(
					   sliderInput("lim", "Limit:",
						       min=0, max=1000, value=500),
					   ),

			      mainPanel(leafletOutput("map"))
			      )
		)

app <- shinyApp(
		ui,

		server <- function(input, output) {
		    #library(map)
		    #newmap <- getMap(resolution = "low")
		    # #Meilleur map:
		    # map("worldHires",".",  col="gray90", fill=TRUE,xlim=c(-16,50),ylim=c(30,60))
		    lim=1:500
		    alladb=unique(read.csv("allAmphoraDBstr.csv"))[lim,]
		    coordinateB=read.csv("allFortFl.csv")[lim,]
		    creteCoor=read.csv("placesWithCoordinates.csv")[lim,]


		    #	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    #	points(coordinateB[,2],coordinateB[,3],pch=20,cex=4,col=alpha("orange", 0.3))
		    #	points(alladb[,3],alladb[,4],pch=20,cex=2,col=alpha("green",.1))
		    #	points(creteCoor[,2],creteCoor[,3],pch=20,cex=2,col=alpha("red", 0.1))
		    #	legend("topright",legend=c("legionary fort","amphora in CEIPAC","place in greek network"),col=c(alpha("orange", 0.3),alpha("green",.3),alpha("red", 0.3)),bty="o",bg="white",pch=20,pt.cex=c(4,2,2))

		    your.map <- leaflet() %>% fitBounds(-15,30,50,60)  %>% addTiles()  %>%  setMaxBounds(-16,30,50,60)
	    your.map  <-  your.map   %>% addCircles(c(coordinateB[,2],alladb[,3],creteCoor[,2]),c(coordinateB[,3],alladb[,4],creteCoor[,3]),color=c(rep("orange",nrow(coordinateB)),rep("green",nrow(alladb)),rep("red",nrow(creteCoor))),popup=c(as.character(coordinateB[,1]),paste(alladb[,1],"find in",alladb[,2]),as.character(creteCoor[,1])))
		    #your.map  <-   your.map %>% addCircles(alladb[,3],alladb[,4],col="green",popup=paste(alladb[,1],"find in",alladb[,2])) %>% addCircles(creteCoor[,2],creteCoor[,3],color="red",popup=creteCoor[,1]) 
		    #your.map  <-  your.map  %>% addPopups(coordinateB[,2],coordinateB[,3],coordinateB[,1]) %>% addPopups(alladb[,3],alladb[,4],paste(alladb[,1],alladb[,2])) %>% addPopups(creteCoor[,2],creteCoor[,3],creteCoor[,1]) 

	    your.map
		    output$map = renderLeaflet(your.map) 
		}
		)

print(app)

shinyApp(ui, server)

install.packages("htmlwidgets")
saveWidget(widget=your.map,file="map.html",selfcontained=F)




nmax=60
		    your.map <- leaflet() %>% fitBounds(-15,30,50,60)  %>% addTiles()  %>%  setMaxBounds(-16,30,50,60)
	    your.map  <-  your.map   %>% addCircles(runif(nmax,-15,50),runif(nmax,30,60),color=rep("orange",nmax),popup=paste("test",rnorm(nmax)*10)) 

	    your.map
