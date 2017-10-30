#' Prepare map of Vote
#' 
#' @param dt data.table
#' @param states_map data.frame returned from map_data("state")

#' @param fill character name of the variable
#' @param title character
#' @param low character hex
#' @param high character hex
#' @return ggplot
#' 
plot_by_state <- function (dt, states_map, fill, title, par,
                           low = c("#fccfcf","#babaff","#efefef","#fff5eb"), 
                           high = c("#ff0202","#0000ff","#a5a5a5","#d94801")) {
  title <- sprintf(title,par)
  p <- ggplot(dt, aes(map_id = State))
  p <- p + geom_map(aes_string(fill = fill), map = states_map)
  p <- p + expand_limits(x = states_map$long, y = states_map$lat)
  p <- p + coord_map() + theme_bw()
  p <- p + labs(x = "Long", y = "Lat", title = title)
  #p+ theme(plot.title = element_text(size=32,hjust = 0.5))
  #depends on which party it is.
  #red range:#fccfcf,#ff0202
  #blue range:#babaff,#0202ff
  #netual grey range:#efefef,#a5a5a5
  #dif range:#fff5eb,#d94801
  if(par=="GOP"){
    p + scale_fill_gradient(low = low[1], high = high[1])
  } else if(par=="Dem"){
    p + scale_fill_gradient(low = low[2], high = high[2])
  } else if(par=="Indp"){
    p + scale_fill_gradient(low = low[3], high = high[3])
  } else {
    p + scale_fill_gradient(low = low[4], high = high[4])
  }
  
  
}