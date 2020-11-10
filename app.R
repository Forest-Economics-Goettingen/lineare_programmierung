

library(shiny)
library(shinyMatrix)
library(lpSolve)

ui <- fluidPage(
  
  titlePanel("Linear Programming / Lineare Programmierung (auch Lineare Optimierung)"),
  
  sidebarLayout(
    sidebarPanel(
      
      helpText("Direction of linear programming / Richtung der linearen Programierung"),
      
      selectInput("direction", "" , c("max","min")),
      
      helpText("Coefficients of the objective function / Koeffizienten der Zielfunktion"),
      
      matrixInput("Zielfunktion", value = matrix(c(2000,1500,NA), nrow = 1, byrow = F,
                                                 dimnames = list(c("Z = "),
                                                                 c("* x +", "* y +", "* z"))),
                  rows = list(names = T),
                  cols = list(names = T)),
      
      helpText("Coefficient matrix of the constraints / Koeffizientenmatrix der Nebenbedingungen"),
      
      matrixInput("Bedingungen", 
                  value =   matrix(c(20, 40, NA,190,
                                     40, 20, NA,190,
                                     1, 1, NA,5,
                                     NA, NA, NA,NA,
                                     NA, NA, NA,NA),
                        nrow = 5, byrow = TRUE,
                        dimnames = list(c("N1:","N2:","N3:","N4:","N5:"), c("  * x +  ", "  * y +  ", "* z <=/>= ","val"))),
                        rows = list(names = T),
                        cols = list(names = T)),
      
      helpText("Inequality sign of the constraints (>= or <=) / Ungleichungszeichen der Nebenbedingungen"),
      
      matrixInput("sign", value = matrix(c("<=","<=", "<=",NA,NA), nrow = 1, byrow = T)),
      
      h3("Additional parameters for graphical solution / Weitere Parameter fuer graphische Loesung"),
      
      helpText("Intercept of the objective function - make parallel translations of the line to find the optimized x and y values. In the default example there is already the solution displayed with Intercept = 6.5 / Interzept (y-Achsenabschnitt) der Zielfunktion - mache durch eine Veraenderung des Interzepts Parallelverschiebungen der Zielfunktionsgerade, um die besten x und y Werte zu finden. In dem Beispiel ist bereits mit Intercept = 6.5 der richtige Wert gefunden."),
      
      numericInput("intercept","Intercept / Interzept", value = 6.5),
      
      helpText("Range of interest for the plotting. In the default case its 0-5 because from the context the values can only vary between 0 and 5 ha / Spannweite fuer den Plot, im Zusammenhang mit dem Beispiel ist nur zwischen 0 und 5 ha relevant. Die Spannweite aendert sich mit dem jeweiligen Anwendungskontext."),
      
      matrixInput("x", value = matrix(c(0,5), nrow = 1, byrow = T))
      
    ),
    mainPanel(
      
      tabsetPanel( type = "tab",
                   
                   tabPanel("Context default example",
                            h3("English"),
                            p(strong("The farmer Petra Baeurin has in addition to her agricultural land a small forested area. As a result of a storm there is a windfall of 5 ha and she wants to manage this land most efficiently.")),
                            
                            p(strong("She has two alternatives which seem to be quite promising for the destructed forest area: (1) plantation of Christmas trees and (2) develop a nursery to grow beech tree seedlings.")),
                            
                            p(strong("The profit (or contribution margin) of planting Christmas trees is approx. 2000 Euro / ha per year and the profit gained from the nursery is expected to be around 1500 Euro / ha per year. The focus of Petra Baeuerin is her farmland. Thus, she has only 190 work hours to spare for the forest area, both in the first and second half of the year.")),
                            
                            p(strong("In the first half of the year, the Christmas trees demand 20 hours / ha and the nursery 40 hours / ha; In the second half of the year the Christmas trees need 40 hours / ha time investment and the nursery only 20 hours / ha.")),
                            
                            p(strong("What is the optimal use for the 5 ha of forest land?")),
                            
                            h3("German"),
                            p(strong("Die Haupterwerbslandwirtin Petra Baeuerin bewirtschaftet neben ihrem landwirtschaftlichen Betrieb auch einen kleinen Bauernwald. In diesem Wald ist durch einen Sturm eine 5 ha grosse Windwurfflaeche entstanden, die Petra Baeuerin moeglichst erfolgreich bewirtschaften moechte.")),
                            
p(strong("Im Rahmen ihres betrieblichen Gesamtkonzeptes erscheinen zwei Alternativen sinnvoll: (1) Bewirtschaftung als Weihnachtsbaumkultur und (2) als Pflanzkamp zur Anzucht von Buchensaemlingen.")),

p(strong("Die Weihnachtsbaumkultur laesst grundsaetzlich einen jaehrlichen Deckungsbeitrag von 2.000,00 Euro  / ha erwarten, das Pflanzkamp von 1.500,00 Euro / ha. Aufgrund ihres landwirtschaftlichen Haupterwerbes kann Petra Baeuerin im ersten und zweiten Halbjahr jeweils nur 190 Stunden fuer die Bewirtschaftung der betreffenden forstlichen Flaeche eruebrigen.")),
 
p(strong("In der ersten Jahreshaelfte waeren fuer die Alternative Weihnachtsbaumkultur 20 Stunden / ha und fuer die Alternative Pflanzkamp 40 Stunden / ha erforderlich; in der zweiten Jahreshaelfte fuer die Alternative Weihnachtsbaumkultur 40 Stunden / ha und fuer die Alternative Pflanzkamp 20 Stunden / ha.")),

p(strong("Wie sieht die optimale Produktion fuer die Flaeche aus?"))
),

                  tabPanel("Numeric solution",
                           h3("Numerical solution of the optimization process with the lpSolve (lp-> linear programming) package in R"),
                           
                           h3("Rechnerische Loesung des Optimierungsprozesses basierend auf dem R-Paket lpSolve"),
                           
                           h4("The objective value (Z) of the optimization process / Der Zielwert Z des Optimierungsprozesses"),
                           textOutput("Z_value"),
                           
                           h4("The objective function with the calculated values for x,y and z. The outcome is the Z-value above. / Die Zielfunktion mit ihren fuer x, y und z berechneten Werten. Das Ergebnis ist der obige Z-Wert."),
                           
                           textOutput("x_y_z"),
                           
                           h5("Compare 4.5*x and 0.5*y with the graphical solution. There we have as a point of intersection P (4.5,0.5). We have the same solution in both cases. / Vergleiche die Gleichung mal mit der graphischen Loesung. In beiden Faellen ist 4,5 fuer x und 0.5 fuer y die Loesung.")),
                           

                  tabPanel("Graphical solution (only 2D cases)",
                           plotOutput("graph")
                           )
        
      )
      
      
      
      
    )
  )
  
)

server <- function(input, output){
  
  output$Z_value <- renderText({
    #Bedingungen
    data <- matrix(as.numeric(input$Bedingungen),
                   nrow = 5, byrow = F)
     
     data <- matrix(data[!is.na(data)], nrow = sum(!is.na(data)[,1]))


     f.con <- data[,1:c(length(data[1,])-1)]


     #Set coefficients of the objective function / Zielfunktion
      f.obj <- as.numeric(input$Zielfunktion)
      str(f.obj)
      f.obj <- f.obj[!is.na(f.obj)]


     #Set unequality signs
     f.dir <- input$sign


     for(i in 1:length(f.dir)){
       if (f.dir[i] == "&lt;="){
         f.dir[i] <- "<="
       } else if (f.dir[i] == "&gt;=") {
         f.dir[i] <- ">="
       } else
         f.dir[i] <- "not_needed"
     }

     f.dir <- f.dir[f.dir == "<=" | f.dir == ">="]


    # Set right hand side coefficients
    f.rhs <- data[,length(data[1,])]

     # Final value (z)
     erg <- lp(input$direction , f.obj, f.con, f.dir, f.rhs)
     paste("Z =", erg$objval)
     

  })
    
  output$x_y_z <- renderText({
    
    data <- matrix(as.numeric(input$Bedingungen),
                   nrow = 5, byrow = F)
    
    data <- matrix(data[!is.na(data)], nrow = sum(!is.na(data)[,1]))
    
    
    f.con <- data[,1:c(length(data[1,])-1)]
    
    
    #Set coefficients of the objective function / Zielfunktion
    f.obj <- as.numeric(input$Zielfunktion)
    str(f.obj)
    f.obj <- f.obj[!is.na(f.obj)]
    
    
    #Set unequality signs
    f.dir <- input$sign
    
    
    for(i in 1:length(f.dir)){
      if (f.dir[i] == "&lt;="){
        f.dir[i] <- "<="
      } else if (f.dir[i] == "&gt;=") {
        f.dir[i] <- ">="
      } else
        f.dir[i] <- "not_needed"
    }
    
    f.dir <- f.dir[f.dir == "<=" | f.dir == ">="]
    
    
    # Set right hand side coefficients
    f.rhs <- data[,length(data[1,])]
    
    # Final value (z)
    erg <- lp(input$direction , f.obj, f.con, f.dir, f.rhs)
    paste("Z =",f.obj[1],"*", erg$solution[1],"+", f.obj[2],"*", erg$solution[2] ,"+",f.obj[3], "*" , erg$solution[3])
    
  })
  
  output$graph <- renderPlot({
    data <- matrix(as.numeric(input$Bedingungen),
                   nrow = 5, byrow = F)
    data <- matrix(data[!is.na(data)], nrow = sum(!is.na(data)[,1]))
    
    #Set coefficients of the objective function / Zielfunktion
    f.obj <- as.numeric(input$Zielfunktion)
    str(f.obj)
    f.obj <- f.obj[!is.na(f.obj)]
    
    #additional variable parameters
    Z <- input$intercept
    x <- as.numeric(input$x)
    
    if (length(data[1,]) > 3 | length(f.obj) > 2){
      plot(1~1, ylim = c(2,3), xaxt = "n", yaxt = "n", ylab = "", xlab = "")
      text(1,2.5, "Plot only available for the 2 dimensional case", font = 2, cex = 2)
    } else {
      
      plot_data <- matrix(nrow = length(x), ncol = length(data[,1]))
      
      
      for(i in 1:length(data[,1])){
        for(j in 1:length(x)){
          plot_data[j,i] <-  data[i,length(data[1,])]/ data[i,length(data[1,])-1] - (data[i,1]*x[j]) / data[i,length(data[1,])-1]
        }
      }
      
      plot(plot_data[,1]~x, type = "l",
           xlim = range(x), ylim = range(plot_data),
           las = 1, lwd = 2, col = 1,
           ylab = "y", xlab = "x", cex.axis = 1.5, cex.lab =1.5)
      
      for(i in 2:length(plot_data[1,])){
        points(plot_data[,i]~x, type = "l",
               col = i+1, lwd = 2)
      }
      
      legend("topright",c("Z","N1","N2","N3","N4","N5"), col = c(2,1,3:6),
             lty = c(3,rep(1,5)), lwd = 3,
             text.col = c(2,1,3:6), text.font = 2)  
      
      value = matrix(c(2,1.5,NA), nrow = 1, byrow = F,
                     dimnames = list(c("Z = ")))
      
      value <- value[!is.na(value)]
      
      y_Z <- (-value[1] * x) / value[2]
      
      
      
      points(y_Z+Z ~ x, type = "l",
             lty = 3, las = 1, lwd = 3, col = 2,
             ylab = "y", xlab = "x", cex.axis = 1.5, cex.lab =1.5)
    }
    
    
  })
  
  
}

shinyApp(ui = ui, server = server)