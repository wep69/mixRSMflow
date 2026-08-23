.mix_open_device <- function(file,width=7,height=6,dpi=300) {
  if(is.null(file))return(FALSE)
  ext<-tolower(tools::file_ext(file))
  if(ext=="pdf") grDevices::pdf(file,width=width,height=height,useDingbats=FALSE)
  else if(ext=="svg") grDevices::svg(file,width=width,height=height)
  else if(ext=="png") grDevices::png(file,width=width*dpi,height=height*dpi,res=dpi)
  else if(ext%in%c("tif","tiff")) grDevices::tiff(file,width=width*dpi,height=height*dpi,res=dpi,compression="lzw")
  else .mix_stop("Unsupported graphics extension: ",ext)
  TRUE
}

.mix_surface_data <- function(fit,resolution=20L) {
  spec<-fit$spec;grid<-.mix_candidate_grid(spec,resolution,0L,1L)
  if(spec$q!=3L).mix_stop("The direct triangular 3D surface currently requires exactly three components.")
  if(length(fit$process))for(nm in fit$process)grid[[nm]]<-stats::median(fit$data[[nm]],na.rm=TRUE)
  pred<-mix_predict(fit,grid)$.prediction;xy<-.mix_barycentric_xy(grid[spec$components])
  data.frame(grid,xy,z=pred,check.names=FALSE)
}

.mix_mesh_edges <- function(surface,spec,resolution) {
  C<-as.matrix(surface[spec$components]);step<-spec$total/resolution
  D<-as.matrix(stats::dist(C));target<-sqrt(2)*step
  ij<-which(upper.tri(D)&abs(D-target)<target*0.08,arr.ind=TRUE)
  ij
}

.mix_project_3d <- function(x,y,z,azimuth=45,elevation=25) {
  az<-azimuth*pi/180;el<-elevation*pi/180
  zc<-(z-mean(range(z)))/pmax(diff(range(z)),1e-12)
  xc<-x-mean(range(x));yc<-y-mean(range(y))
  xr<-cos(az)*xc-sin(az)*yc;yr<-sin(az)*xc+cos(az)*yc
  yp<-cos(el)*yr-sin(el)*zc;zp<-sin(el)*yr+cos(el)*zc
  data.frame(px=xr,py=yp,depth=zp)
}

.mix_plot_surface_base <- function(fit,resolution=20L,views=2L,azimuth=c(45,225),elevation=25,main=NULL) {
  S<-.mix_surface_data(fit,resolution);E<-.mix_mesh_edges(S,fit$spec,resolution)
  views<-as.integer(views);azimuth<-rep(azimuth,length.out=views)
  old<-graphics::par(no.readonly=TRUE);on.exit(graphics::par(old),add=TRUE)
  if(views>1L)graphics::par(mfrow=c(views,1L),mar=c(1.5,1.5,2,1))
  for(v in seq_len(views)){
    P<-.mix_project_3d(S$.x,S$.y,S$z,azimuth[v],elevation)
    graphics::plot(P$px,P$py,type="n",axes=FALSE,xlab="",ylab="",main=main%||%paste("Mixture response surface - view",v),asp=1)
    ord<-order(rowMeans(matrix(P$depth[E],ncol=2)))
    for(k in ord){i<-E[k,1];j<-E[k,2];graphics::segments(P$px[i],P$py[i],P$px[j],P$py[j])}
    # outline simplex and label vertices when present in feasible surface
    verts<-diag(fit$spec$total,3L);colnames(verts)<-fit$spec$components
    for(i in 1:3){j<-if(i==3)1 else i+1;ii<-which.min(rowSums((as.matrix(S[fit$spec$components])-matrix(verts[i,],nrow(S),3,byrow=TRUE))^2));jj<-which.min(rowSums((as.matrix(S[fit$spec$components])-matrix(verts[j,],nrow(S),3,byrow=TRUE))^2));graphics::segments(P$px[ii],P$py[ii],P$px[jj],P$py[jj],lwd=1.5)}
    for(i in 1:3){ii<-which.min(rowSums((as.matrix(S[fit$spec$components])-matrix(verts[i,],nrow(S),3,byrow=TRUE))^2));graphics::text(P$px[ii],P$py[ii],labels=fit$spec$components[i],pos=3,cex=.85)}
  }
  invisible(S)
}

.mix_ternary_gg <- function(fit,type,resolution=40L,level=0.95) {
  if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required for this plotting engine.")
  spec<-fit$spec;if(spec$q!=3L).mix_stop("Ternary plots require three components.")
  # Regular barycentric lattice: geom_contour needs a regular grid, and the
  # previous candidate-based points were scattered (random candidates), which
  # made the contour layer draw nothing.
  n<-as.integer(resolution)*2L
  xs<-seq(0,1,length.out=n);ys<-seq(0,sqrt(3)/2,length.out=n)
  g<-expand.grid(.x=xs,.y=ys,KEEP.OUT.ATTRS=FALSE)
  g$C<-2*g$.y/sqrt(3);g$B<-g$.x-g$.y/sqrt(3);g$A<-1-g$B-g$C
  g<-g[g$A>=-1e-9&g$B>=-1e-9&g$C>=-1e-9,,drop=FALSE]
  gd<-g[c("A","B","C")];names(gd)<-spec$components
  if(length(fit$process))for(nm in fit$process)gd[[nm]]<-stats::median(fit$data[[nm]],na.rm=TRUE)
  pr<-mix_predict(fit,gd,interval=if(type=="prediction_variance")"confidence" else "none",level=level)
  df<-cbind(g,.prediction=pr$.prediction)
  if(type=="prediction_variance")df$.value<-pr$.se_link^2 else df$.value<-df$.prediction
  # Mask compositions outside the declared feasible region.
  feas<-vapply(seq_len(nrow(gd)),function(i).mix_feasible(unlist(gd[i,spec$components]),spec),logical(1))
  df$.value<-ifelse(feas,df$.value,NA_real_)
  tri<-data.frame(.x=c(0,1,.5,0),.y=c(0,0,sqrt(3)/2,0))
  p<-ggplot2::ggplot(df,ggplot2::aes(x=.data$.x,y=.data$.y))+
    ggplot2::geom_path(data=tri,ggplot2::aes(x=.data$.x,y=.data$.y),inherit.aes=FALSE)+
    ggplot2::coord_equal()+ggplot2::theme_void()
  if(type%in%c("ternary_contour","prediction_variance")) p<-p+ggplot2::geom_contour(ggplot2::aes(z=.data$.value),bins=10,na.rm=TRUE)
  else if(type%in%c("ternary_filled","heatmap")) p<-p+ggplot2::stat_contour_filled(ggplot2::aes(z=.data$.value),bins=12,na.rm=TRUE)
  p+ggplot2::annotate("text",x=0,y=-.035,label=spec$components[1],hjust=0)+
    ggplot2::annotate("text",x=1,y=-.035,label=spec$components[2],hjust=1)+
    ggplot2::annotate("text",x=.5,y=sqrt(3)/2+.035,label=spec$components[3])
}

.mix_design_gg <- function(dat,spec) {
  if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.")
  if(spec$q==3L){xy<-.mix_barycentric_xy(dat[spec$components]);df<-cbind(dat,xy);tri<-data.frame(.x=c(0,1,.5,0),.y=c(0,0,sqrt(3)/2,0));ggplot2::ggplot(df,ggplot2::aes(.data$.x,.data$.y))+ggplot2::geom_path(data=tri,ggplot2::aes(.data$.x,.data$.y),inherit.aes=FALSE)+ggplot2::geom_point()+ggplot2::coord_equal()+ggplot2::theme_void()}
  else {long<-data.frame(run=rep(seq_len(nrow(dat)),each=spec$q),component=factor(rep(spec$components,nrow(dat)),levels=spec$components),value=as.vector(t(as.matrix(dat[spec$components]))));ggplot2::ggplot(long,ggplot2::aes(.data$component,.data$value,group=.data$run))+ggplot2::geom_line(alpha=.35)+ggplot2::geom_point(size=.8)+ggplot2::labs(y=spec$units,x=NULL)+ggplot2::theme_minimal()}
}

#' Unified static and interactive plotting for mixture workflows
#'
#' @param object A `mix_fit`, `mix_design`, `mix_design_evaluation`, `mix_optimum`,
#'   `mix_optimum_ci`, `mix_effect`, or `mix_multiopt` object.
#' @param type Plot type. Common choices include `design`, `surface3d`,
#'   `ternary_contour`, `ternary_filled`, `heatmap`, `residuals`, `qq`,
#'   `leverage`, `fds`, `vdg`, `component_trace`, `optimum`, `optimum_ci`,
#'   `desirability`, and `pareto`.
#' @param engine `ggplot2`, `base`, or `plotly`.
#' @param resolution Surface/grid resolution.
#' @param views Number of views for Cornell-style static 3D wireframes.
#' @param file Optional PDF/SVG/PNG/TIFF output path. Base 3D PDF/SVG output is vector.
#' @param width,height Device size in inches.
#' @param dpi Raster resolution.
#' @param ... Additional plotting arguments.
#' @return A plot object when applicable, otherwise the plotted data invisibly.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 25)
#' fit <- mix_fit("response", d, sp)
#' mix_plot(fit, type = "ternary_contour", resolution = 15)
#' @export
mix_plot <- function(object,type=NULL,engine=c("ggplot2","base","plotly"),resolution=30L,views=2L,
                     file=NULL,width=7,height=6,dpi=300,...) {
  engine<-match.arg(engine);opened<-.mix_open_device(file,width,height,dpi);if(opened)on.exit(grDevices::dev.off(),add=TRUE)
  if(inherits(object,"mix_design")){type<-type%||%"design";if(engine=="ggplot2"){p<-.mix_design_gg(object$data,object$spec);if(opened)print(p);return(p)};if(engine=="plotly"){if(!requireNamespace("plotly",quietly=TRUE)).mix_stop("Package 'plotly' is required.");if(object$spec$q==3L){dd<-object$data;cc<-object$spec$components;return(plotly::plot_ly(type="scatterternary",mode="markers",a=dd[[cc[1]]],b=dd[[cc[2]]],c=dd[[cc[3]]],text=paste0(cc[1],"=",signif(dd[[cc[1]]],5),"<br>",cc[2],"=",signif(dd[[cc[2]]],5),"<br>",cc[3],"=",signif(dd[[cc[3]]],5)),hoverinfo="text"))};.mix_stop("Interactive design plotting for q>3 is not yet available.")}}
  if(inherits(object,"mix_fit")){
    type<-type%||%if(object$spec$q==3L)"ternary_contour" else "residuals"
    if(type=="surface3d"){
      if(engine=="plotly"){if(!requireNamespace("plotly",quietly=TRUE)).mix_stop("Package 'plotly' is required.");S<-.mix_surface_data(object,resolution);return(plotly::plot_ly(type="mesh3d",x=S$.x,y=S$.y,z=S$z,intensity=S$z,hoverinfo="text",text=apply(S[object$spec$components],1,function(z)paste(paste(object$spec$components,round(z,4),sep="="),collapse="<br>"))))}
      return(.mix_plot_surface_base(object,resolution,views=views,...))
    }
    if(type%in%c("ternary_contour","ternary_filled","heatmap","prediction_variance")){
      if(engine=="plotly"){S<-.mix_surface_data(object,resolution);return(plotly::plot_ly(type="mesh3d",x=S$.x,y=S$.y,z=S$z,intensity=S$z))}
      p<-.mix_ternary_gg(object,type,resolution);if(opened)print(p);return(p)
    }
    dg<-mix_diagnose(object);df<-dg$observations
    if(engine!="ggplot2").mix_stop("Diagnostic plots use ggplot2 in this version.")
    if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.")
    if(type=="residuals")p<-ggplot2::ggplot(df,ggplot2::aes(.data$fitted,.data$residual))+ggplot2::geom_point()+ggplot2::geom_hline(yintercept=0)+ggplot2::labs(x="Fitted",y="Residual")+ggplot2::theme_minimal()
    else if(type=="qq")p<-ggplot2::ggplot(df,ggplot2::aes(sample=.data$residual))+ggplot2::stat_qq()+ggplot2::stat_qq_line()+ggplot2::theme_minimal()
    else if(type=="leverage")p<-ggplot2::ggplot(df,ggplot2::aes(.data$leverage,.data$residual,size=.data$cooks_distance))+ggplot2::geom_point()+ggplot2::theme_minimal()
    else .mix_stop("Unsupported mix_fit plot type: ",type)
    if(opened)print(p);return(p)
  }
  if(inherits(object,"mix_design_evaluation")){
    type<-type%||%"fds";if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.")
    if(type=="fds")p<-ggplot2::ggplot(object$fds,ggplot2::aes(.data$fraction,.data$prediction_variance))+ggplot2::geom_line()+ggplot2::labs(x="Fraction of design space",y="Prediction variance")+ggplot2::theme_minimal()
    else if(type=="vdg"){d<-object$vdg;d$bin<-seq_len(nrow(d));p<-ggplot2::ggplot(d,ggplot2::aes(.data$bin,.data$mean))+ggplot2::geom_line()+ggplot2::geom_point()+ggplot2::geom_line(ggplot2::aes(y=.data$q90),linetype=2)+ggplot2::labs(x="Radial bin",y="Prediction variance")+ggplot2::theme_minimal()}else .mix_stop("Unsupported design-evaluation plot type.")
    if(opened)print(p);return(p)
  }
  if(inherits(object,"mix_effect")){if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.");d<-object$path;focal<-if(!is.null(object$component))object$component else names(object$direction)[which.max(abs(object$direction))];p<-ggplot2::ggplot(d,ggplot2::aes(x=.data[[focal]],y=.data$.prediction))+ggplot2::geom_line()+ggplot2::geom_ribbon(ggplot2::aes(ymin=.data$.lower,ymax=.data$.upper),alpha=.15)+ggplot2::labs(x=focal,y="Predicted response")+ggplot2::theme_minimal();if(opened)print(p);return(p)}
  if(inherits(object,"mix_optimum_ci")){if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.");if(object$optimum$spec$q!=3L).mix_stop("Joint optimum cloud plot currently requires three components.");xy<-.mix_barycentric_xy(object$cloud);d<-cbind(object$cloud,xy);p<-ggplot2::ggplot(d,ggplot2::aes(.data$.x,.data$.y))+ggplot2::geom_point(alpha=.25)+ggplot2::coord_equal()+ggplot2::theme_void()+ggplot2::labs(title="Bootstrap/parametric cloud of optimum locations");if(opened)print(p);return(p)}
  if(inherits(object,"mix_optimum")){if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.");if(object$spec$q!=3L).mix_stop("Optimum map currently requires three components.");d<-object$near_optimal;xy<-.mix_barycentric_xy(d[object$spec$components]);d<-cbind(d,xy);opxy<-.mix_barycentric_xy(as.data.frame(t(object$composition)));p<-ggplot2::ggplot(d,ggplot2::aes(.data$.x,.data$.y))+ggplot2::geom_point(ggplot2::aes(fill=.data$.prediction),shape=21)+ggplot2::geom_point(data=cbind(opxy),ggplot2::aes(.data$.x,.data$.y),inherit.aes=FALSE,size=4,shape=4)+ggplot2::coord_equal()+ggplot2::theme_void();if(opened)print(p);return(p)}
  if(inherits(object,"mix_multiopt")){if(!requireNamespace("ggplot2",quietly=TRUE)).mix_stop("Package 'ggplot2' is required.");type<-type%||%"pareto";if(type=="pareto"){r<-names(object$fits);if(length(r)<2L).mix_stop("Pareto plot needs at least two responses.");p<-ggplot2::ggplot(object$candidate_results,ggplot2::aes(x=.data[[r[1]]],y=.data[[r[2]]]))+ggplot2::geom_point(alpha=.15)+ggplot2::geom_point(data=object$pareto,ggplot2::aes(x=.data[[r[1]]],y=.data[[r[2]]]),inherit.aes=FALSE)+ggplot2::theme_minimal()}else if(type=="desirability"){if(object$spec$q!=3L).mix_stop("Ternary desirability map needs three components.");d<-object$candidate_results;xy<-.mix_barycentric_xy(d[object$spec$components]);d<-cbind(d,xy);p<-ggplot2::ggplot(d,ggplot2::aes(.data$.x,.data$.y,fill=.data$overall_desirability))+ggplot2::geom_point(shape=21)+ggplot2::coord_equal()+ggplot2::theme_void()}else .mix_stop("Unsupported multiresponse plot type.");if(opened)print(p);return(p)}
  .mix_stop("Unsupported object class for mix_plot().")
}

#' @export
plot.mix_fit <- function(x,...) mix_plot(x,...)
#' @export
plot.mix_design <- function(x,...) mix_plot(x,...)
