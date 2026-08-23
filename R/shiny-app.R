#' Launch the interactive mixRSMflow teaching and analysis application
#'
#' The Shiny interface mirrors the package workflow and displays reproducible R
#' commands for the main operations. It is intentionally an optional interface;
#' all scientific functionality remains available through the R API.
#'
#' @param launch.browser Passed to `shiny::runApp`.
#' @param demo If `TRUE`, preload a simulated three-component dataset.
#' @return No return value; launches a Shiny application.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   run_mixrsm_app()
#' }
#' @export
run_mixrsm_app <- function(launch.browser = TRUE, demo = TRUE) {
  if(!requireNamespace("shiny",quietly=TRUE)).mix_stop("Package 'shiny' is required for run_mixrsm_app().")
  ui<-shiny::navbarPage(
    title="mixRSMflow",
    shiny::tabPanel("Data",
      shiny::sidebarLayout(shiny::sidebarPanel(
        shiny::fileInput("file","CSV data"),
        shiny::textInput("components","Components (comma-separated)","A,B,C"),
        shiny::numericInput("total","Mixture total",1,min=0.0001),
        shiny::actionButton("load_demo","Load simulated demo")
      ),shiny::mainPanel(shiny::tableOutput("data_head"),shiny::verbatimTextOutput("data_code")))),
    shiny::tabPanel("Region & Constraints",
      shiny::sidebarLayout(shiny::sidebarPanel(
        shiny::textInput("lower","Lower bounds", "0,0,0"),shiny::textInput("upper","Upper bounds","1,1,1"),
        shiny::selectInput("region_type","Region",c("polytope","sphere","ellipsoid","cuboid"),selected="polytope")
      ),shiny::mainPanel(shiny::verbatimTextOutput("spec_print"),shiny::verbatimTextOutput("spec_code")))),
    shiny::tabPanel("Generate Design",
      shiny::sidebarLayout(shiny::sidebarPanel(
        shiny::selectInput("design_type","Design",c("simplex_lattice","simplex_centroid","axial","augmented_centroid","extreme_vertices","rotatable")),
        shiny::numericInput("degree","Lattice degree",3,min=1),shiny::actionButton("make_design","Generate")
      ),shiny::mainPanel(shiny::tableOutput("design_table"),shiny::verbatimTextOutput("design_code")))),
    shiny::tabPanel("Evaluate Design",shiny::mainPanel(shiny::verbatimTextOutput("design_eval"))),
    shiny::tabPanel("Fit Model",
      shiny::sidebarLayout(shiny::sidebarPanel(shiny::uiOutput("response_ui"),
        shiny::selectInput("model","Mixture model",c("scheffe_linear","scheffe_quadratic","scheffe_special_cubic","scheffe_cubic","scheffe_special_quartic","slack_quadratic","logcontrast","becker_h2")),
        shiny::actionButton("fit_model","Fit")),shiny::mainPanel(shiny::verbatimTextOutput("fit_summary"),shiny::verbatimTextOutput("fit_code")))),
    shiny::tabPanel("ANOVA & Diagnostics",shiny::mainPanel(shiny::verbatimTextOutput("anova_out"),shiny::plotOutput("diag_plot"))),
    shiny::tabPanel("Component Interpretation",
      shiny::sidebarLayout(shiny::sidebarPanel(shiny::uiOutput("component_ui"),shiny::selectInput("effect_type","Effect",c("cox","piepel","component_trace"))),shiny::mainPanel(shiny::plotOutput("effect_plot"),shiny::verbatimTextOutput("screen_out")))),
    shiny::tabPanel("Prediction",shiny::mainPanel(shiny::tableOutput("prediction_table"))),
    shiny::tabPanel("Optimal Design",shiny::mainPanel(shiny::verbatimTextOutput("optimal_design_out"))),
    shiny::tabPanel("Optimization",shiny::mainPanel(shiny::verbatimTextOutput("optimum_out"),shiny::plotOutput("optimum_plot"))),
    shiny::tabPanel("Multiple Responses",shiny::mainPanel(shiny::helpText("Use mix_multi_fit() and mix_multiopt() from the API; this tab reports available numeric responses."),shiny::verbatimTextOutput("multi_candidates"))),
    shiny::tabPanel("Static Graphics",shiny::mainPanel(shiny::plotOutput("ternary_plot",height="620px"))),
    shiny::tabPanel("Interactive Graphics",shiny::mainPanel(shiny::uiOutput("interactive_hint"))),
    shiny::tabPanel("Report",shiny::mainPanel(shiny::verbatimTextOutput("report_preview"),shiny::downloadButton("download_report","Download Markdown report"))),
    shiny::tabPanel("Theory & Help",shiny::mainPanel(shiny::h3("Workflow"),shiny::p("Define region -> generate/evaluate design -> fit -> diagnose -> interpret -> predict -> optimize -> quantify uncertainty -> report."),shiny::tableOutput("capabilities_table"))),
    shiny::tabPanel("Audit",shiny::mainPanel(shiny::tableOutput("audit_table")))
  )
  server<-function(input,output,session){
    rv<-shiny::reactiveValues(data=if(demo)mix_demo_data("mixture") else NULL,design=NULL,fit=NULL,spec=NULL,optimum=NULL)
    parse_num<-function(x)as.numeric(trimws(strsplit(x,",",fixed=TRUE)[[1]]))
    comps<-shiny::reactive(trimws(strsplit(input$components,",",fixed=TRUE)[[1]]))
    shiny::observeEvent(input$file,{rv$data<-utils::read.csv(input$file$datapath,check.names=FALSE)})
    shiny::observeEvent(input$load_demo,{rv$data<-mix_demo_data("mixture")})
    spec_reactive<-shiny::reactive({
      cc<-comps();lo<-parse_num(input$lower);up<-parse_num(input$upper)
      if(length(lo)==1L)lo<-rep(lo,length(cc));if(length(up)==1L)up<-rep(up,length(cc))
      if(length(lo)!=length(cc)||length(up)!=length(cc))return(NULL)
      try(mix_spec(cc,total=input$total,lower=lo,upper=up),silent=TRUE)
    })
    shiny::observe({sp<-spec_reactive();if(!inherits(sp,"try-error")&&!is.null(sp))rv$spec<-sp})
    shiny::observeEvent(input$make_design,{shiny::req(rv$spec);rv$design<-mix_design(rv$spec,type=input$design_type,degree=input$degree)})
    output$response_ui<-shiny::renderUI({shiny::req(rv$data);nums<-names(rv$data)[vapply(rv$data,is.numeric,logical(1))];choices<-setdiff(nums,comps());shiny::selectInput("response","Response",choices,selected=if("response"%in%choices)"response" else choices[1])})
    output$component_ui<-shiny::renderUI({shiny::selectInput("component","Component",comps())})
    shiny::observeEvent(input$fit_model,{shiny::req(rv$data,rv$spec,input$response);rv$fit<-mix_fit(input$response,rv$data,spec=rv$spec,model=input$model)})
    output$data_head<-shiny::renderTable({shiny::req(rv$data);utils::head(rv$data,12)})
    output$data_code<-shiny::renderText({"dat <- read.csv('your_data.csv', check.names = FALSE)"})
    output$spec_print<-shiny::renderPrint({shiny::req(rv$spec);print(rv$spec)})
    output$spec_code<-shiny::renderText({paste0("spec <- mix_spec(c(",paste(sprintf("'%s'",comps()),collapse=", "),"), total = ",input$total,", lower = c(",paste(parse_num(input$lower),collapse=", "),"), upper = c(",paste(parse_num(input$upper),collapse=", "),"))")})
    output$design_table<-shiny::renderTable({shiny::req(rv$design);rv$design$data})
    output$design_code<-shiny::renderText({paste0("design <- mix_design(spec, type = '",input$design_type,"', degree = ",input$degree,")")})
    output$design_eval<-shiny::renderPrint({shiny::req(rv$design);print(mix_design_eval(rv$design,model="scheffe_quadratic",resolution=10L))})
    output$fit_summary<-shiny::renderPrint({shiny::req(rv$fit);print(summary(rv$fit))})
    output$fit_code<-shiny::renderText({paste0("fit <- mix_fit('",input$response,"', dat, spec, model = '",input$model,"')")})
    output$anova_out<-shiny::renderPrint({shiny::req(rv$fit);print(mix_anova(rv$fit));print(mix_collinearity(rv$fit))})
    output$diag_plot<-shiny::renderPlot({shiny::req(rv$fit);print(mix_plot(rv$fit,"residuals"))})
    output$effect_plot<-shiny::renderPlot({shiny::req(rv$fit,input$component);ef<-mix_effects(rv$fit,type=input$effect_type,component=input$component);print(mix_plot(ef))})
    output$screen_out<-shiny::renderPrint({shiny::req(rv$fit);print(mix_screen(rv$fit,"cox"))})
    output$prediction_table<-shiny::renderTable({shiny::req(rv$fit);utils::head(mix_predict(rv$fit,interval="confidence"),20)})
    output$optimal_design_out<-shiny::renderPrint({shiny::req(rv$spec);od<-mix_optimal_design(rv$spec,model="scheffe_quadratic",runs=max(8L,length(comps())*3L),criterion="I",algorithm="hybrid",resolution=8L,random_candidates=200L,generations=20L);print(od);print(mix_design_eval(od,model="scheffe_quadratic",resolution=10L))})
    output$optimum_out<-shiny::renderPrint({shiny::req(rv$fit);rv$optimum<-mix_optimize(rv$fit,method="grid",grid_resolution=18L,random_candidates=500L);print(rv$optimum)})
    output$optimum_plot<-shiny::renderPlot({shiny::req(rv$fit);op<-mix_optimize(rv$fit,method="grid",grid_resolution=18L,random_candidates=500L);if(rv$fit$spec$q==3L)print(mix_plot(op))})
    output$multi_candidates<-shiny::renderPrint({shiny::req(rv$data);print(setdiff(names(rv$data)[vapply(rv$data,is.numeric,logical(1))],comps()))})
    output$ternary_plot<-shiny::renderPlot({shiny::req(rv$fit);if(rv$fit$spec$q==3L)print(mix_plot(rv$fit,"ternary_contour",resolution=30L))})
    output$interactive_hint<-shiny::renderUI({if(requireNamespace("plotly",quietly=TRUE))shiny::HTML("Plotly is installed. Use <code>mix_plot(fit, type='surface3d', engine='plotly')</code> for an interactive surface.") else shiny::HTML("Install the optional <code>plotly</code> package to enable interactive surfaces.")})
    output$report_preview<-shiny::renderPrint({shiny::req(rv$fit);cat(substr(mix_report(rv$fit)$source,1,5000))})
    output$download_report<-shiny::downloadHandler(filename=function()"mixRSMflow-report.md",content=function(file){shiny::req(rv$fit);mix_report(rv$fit,file=file,format="markdown")})
    output$capabilities_table<-shiny::renderTable({utils::head(mix_capabilities(),40)})
    output$audit_table<-shiny::renderTable({shiny::req(rv$fit);mix_audit_trail(rv$fit)})
  }
  shiny::runApp(shiny::shinyApp(ui,server),launch.browser=launch.browser)
}
