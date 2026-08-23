.mix_md_table <- function(x, digits=5L) {
  x<-as.data.frame(x,check.names=FALSE); if(!nrow(x))return("_No rows._")
  xx<-lapply(x,function(z)if(is.numeric(z))format(round(z,digits),trim=TRUE,scientific=FALSE)else as.character(z))
  xx<-as.data.frame(xx,stringsAsFactors=FALSE,check.names=FALSE)
  esc<-function(z)gsub("\\|","\\\\|",z)
  hdr<-paste0("| ",paste(esc(names(xx)),collapse=" | ")," |")
  sep<-paste0("| ",paste(rep("---",ncol(xx)),collapse=" | ")," |")
  rows<-apply(xx,1,function(r)paste0("| ",paste(esc(r),collapse=" | ")," |"))
  paste(c(hdr,sep,rows),collapse="\n")
}

.mix_html_escape <- function(x) {
  x<-gsub("&","&amp;",x,fixed=TRUE);x<-gsub("<","&lt;",x,fixed=TRUE);x<-gsub(">","&gt;",x,fixed=TRUE);x
}

#' Create a reproducible scientific mixture-analysis report
#'
#' @param object A `mix_fit`, `mix_multi_fit`, or list containing `fit`, `design`, `optimum`, and related artifacts.
#' @param file Output path. If omitted, report text is returned.
#' @param format `markdown`, `html`, `docx`, or `pdf`.
#' @param title Report title.
#' @param include_session Include session information.
#' @return Invisibly, a `mix_report` object containing the report source and output path.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 26)
#' fit <- mix_fit("response", d, sp)
#' r <- mix_report(fit, format = "markdown")
#' r
#' @export
mix_report <- function(object,file=NULL,format=c("markdown","html","docx","pdf"),
                       title="mixRSMflow Scientific Analysis Report",include_session=TRUE) {
  format<-match.arg(format)
  fit<-if(inherits(object,"mix_fit"))object else object$fit %||% NULL
  multi<-if(inherits(object,"mix_multi_fit"))object else object$multi_fit %||% NULL
  design<-if(!is.null(fit))fit$design else object$design %||% NULL
  optimum<-object$optimum %||% NULL
  if(is.null(fit)&&is.null(multi)).mix_stop("mix_report requires a fitted mixture model or a list containing fit/multi_fit.")
  lines<-c(paste0("# ",title),"",paste0("Generated: ",format(Sys.time(),tz="UTC",usetz=TRUE)),"",
           "## Scientific scope","",
           "This report was generated from the fitted objects supplied to `mixRSMflow`. It records model specification, diagnostics, uncertainty, and reproducibility metadata; it does not replace scientific judgement.","")
  if(!is.null(fit)){
    lines<-c(lines,"## Mixture specification","",
             paste0("Components: ",paste(fit$spec$components,collapse=", ")),paste0("Mixture total: ",fit$spec$total),paste0("Region: ",fit$spec$region$type),"",
             .mix_md_table(data.frame(component=fit$spec$components,lower=fit$spec$lower,upper=fit$spec$upper,row.names=NULL)),"",
             "## Model","",paste0("Response: `",fit$response,"`"),paste0("Model basis: `",fit$model,"`"),paste0("Engine: `",fit$engine,"`"),paste0("Observations: ",length(fit$y)),paste0("Estimated terms: ",length(fit$coefficients)),"",
             "### Coefficients","",.mix_md_table(summary(fit)$coefficients),"")
    an<-try(mix_anova(fit),silent=TRUE);if(!inherits(an,"try-error"))lines<-c(lines,"### ANOVA / lack-of-fit","",.mix_md_table(an),"")
    dg<-try(mix_diagnose(fit),silent=TRUE);if(!inherits(dg,"try-error"))lines<-c(lines,"## Diagnostics","",paste0("Condition number: ",format(dg$condition_number,digits=6)),paste0("Maximum leverage: ",format(max(dg$observations$leverage),digits=6)),paste0("Maximum Cook distance: ",format(max(dg$observations$cooks_distance,na.rm=TRUE),digits=6)),"")
    if(is.null(optimum))optimum<-try(mix_optimize(fit,method="grid",grid_resolution=20L,random_candidates=1000L,seed=1001L),silent=TRUE)
    if(!inherits(optimum,"try-error")&&!is.null(optimum)){
      op<-data.frame(component=names(optimum$composition),proportion=as.numeric(optimum$composition))
      lines<-c(lines,"## Bounded optimum","",paste0("Goal: ",optimum$goal),.mix_md_table(op),"",paste0("Predicted response: ",format(optimum$prediction,digits=7)),paste0("Model-based interval: [",format(optimum$lower,digits=7),", ",format(optimum$upper,digits=7),"]"),"")
    }
  }
  if(!is.null(multi)){
    lines<-c(lines,"## Multiple responses","",paste0("Responses: ",paste(multi$responses,collapse=", ")),"")
    for(nm in multi$responses){lines<-c(lines,paste0("### ",nm),"",.mix_md_table(summary(multi$fits[[nm]])$coefficients),"")}
  }
  if(!is.null(design)&&inherits(design,"mix_design")){
    ev<-try(mix_design_eval(design,model=if(!is.null(fit))fit$model else "scheffe_quadratic",resolution=12L),silent=TRUE)
    lines<-c(lines,"## Experimental design","",paste0("Type: `",design$type,"`"),paste0("Runs: ",nrow(design$data)),"")
    if(!inherits(ev,"try-error"))lines<-c(lines,"### Design-quality measures","",.mix_md_table(as.data.frame(t(ev$measures))),"")
  }
  lines<-c(lines,"## Limitations and audit","",
           "Inference is valid only to the extent that the selected response model, experimental structure, and distributional assumptions are scientifically appropriate. Highly constrained regions can yield strong parameter correlation even when prediction remains useful.","")
  if(!is.null(fit))lines<-c(lines,"### Audit trail","",.mix_md_table(mix_audit_trail(fit)),"")
  if(isTRUE(include_session))lines<-c(lines,"## Reproducibility","","```",capture.output(utils::sessionInfo()),"```","")
  md<-paste(lines,collapse="\n")
  if(is.null(file)){
    out<-list(format="markdown",source=md,file=NULL);class(out)<-"mix_report";return(out)
  }
  file<-normalizePath(file,mustWork=FALSE)
  if(format=="markdown")writeLines(md,file,useBytes=TRUE)
  else if(format=="html"){
    body<-paste0("<pre style='white-space:pre-wrap;font-family:system-ui,sans-serif'>",.mix_html_escape(md),"</pre>")
    html<-paste0("<!doctype html><html><head><meta charset='utf-8'><title>",.mix_html_escape(title),"</title></head><body>",body,"</body></html>")
    writeLines(html,file,useBytes=TRUE)
  } else {
    if(!requireNamespace("rmarkdown",quietly=TRUE)).mix_stop("Package 'rmarkdown' is required for DOCX/PDF report rendering.")
    tmp<-tempfile(fileext=".Rmd");yaml<-c("---",paste0("title: \"",gsub('"','\\\\"',title),"\""),paste0("output: ",if(format=="docx")"word_document" else "pdf_document"),"---","")
    writeLines(c(yaml,md),tmp,useBytes=TRUE)
    rmarkdown::render(tmp,output_file=basename(file),output_dir=dirname(file),quiet=TRUE,envir=new.env(parent=baseenv()))
  }
  out<-list(format=format,source=md,file=file);class(out)<-"mix_report";invisible(out)
}

#' @export
print.mix_report <- function(x,...) {cat("<mix_report>",x$format,"\n");if(!is.null(x$file))cat("File:",x$file,"\n")else cat(substr(x$source,1,1200),if(nchar(x$source)>1200)"\n...\n" else "\n");invisible(x)}
