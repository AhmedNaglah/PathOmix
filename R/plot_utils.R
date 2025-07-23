library(reshape2)

plot_variance_explained2=function (object, x = "view", y = "factor", split_by = NA, 
    plot_total = FALSE, factors = "all", min_r2 = 0, max_r2 = NULL, 
    legend = TRUE, use_cache = TRUE, ...) 
{
    if (length(unique(c(x, y, split_by))) != 3) {
        stop(paste0("Please ensure x, y, and split_by arguments are different.\n", 
            "  Possible values are `view`, `group`, and `factor`."))
    }
    if (is.na(split_by)) 
        split_by <- setdiff(c("view", "factor", "group"), c(x, y, split_by))
        #split_by <- setdiff(c("view", "factor", "group"), c(x, y, split_by))
    if ((use_cache) & .hasSlot(object, "cache") && ("variance_explained" %in% 
        names(object@cache))) {
        r2_list <- object@cache$variance_explained
    }
    else {
        r2_list <- calculate_variance_explained(object, factors = factors, 
            ...)
    }
    r2_mk <- r2_list$r2_per_factor
    r2_mk_df <- reshape2::melt(lapply((r2_mk), function(x) melt(as.matrix(x), 
        varnames = c("factor", "view"))), id.vars = c("factor", 
        "view", "value"))
    colnames(r2_mk_df)[ncol(r2_mk_df)] <- "group"
    if ((length(factors) == 1) && (factors[1] == "all")) {
        factors <- factors_names(object)
    }
    else {
        if (is.numeric(factors)) {
            factors <- factors_names(object)[factors]
        }
        else {
            stopifnot(all(factors %in% factors_names(object)))
        }
        r2_mk_df <- r2_mk_df[r2_mk_df$factor %in% factors, ]
    }
    r2_mk_df$factor <- factor(r2_mk_df$factor, levels = factors)
    r2_mk_df$group <- factor(r2_mk_df$group, levels = groups_names(object))
    r2_mk_df$view <- factor(r2_mk_df$view, levels = views_names(object))
    groups <- names(r2_list$r2_total)
    views <- colnames(r2_list$r2_per_factor[[1]])
    if (!is.null(min_r2)) 
        r2_mk_df$value[r2_mk_df$value < min_r2] <- 0.001
    min_r2 = 0
    if (!is.null(max_r2)) {
        r2_mk_df$value[r2_mk_df$value > max_r2] <- max_r2
    }
    else {
        max_r2 = max(r2_mk_df$value)
    }
                                    #  return(r2_mk_df)
    p1 <- ggplot(r2_mk_df, aes_string(x = x, y = y)) + geom_tile(aes_string(fill = "value"), 
        color = "black") + facet_wrap(as.formula(sprintf("~%s", 
        split_by)), nrow = 1) + labs(x = "", y = "", 
        title = "") + scale_fill_gradientn(colors = c("gray97", 
        "darkblue"), guide = "colorbar", limits = c(min_r2, 
        max_r2)) + guides(fill = guide_colorbar("Var. (%)")) + 
        theme(axis.text.x = element_text(angle=90,size = rel(2), color = "black"), 
            axis.text.y = element_text(size = rel(2), color = "black"), 
            axis.line = element_blank(), axis.ticks = element_blank(), 
            panel.background = element_blank(), strip.background = element_blank(), 
            strip.text = element_text(size = rel(2)))
    if (isFALSE(legend)) 
        p1 <- p1 + theme(legend.position = "none")
    if (length(unique(r2_mk_df[, split_by])) == 1) 
        p1 <- p1 + theme(strip.text = element_blank())
    if (isTRUE(plot_total)) {
        r2_m_df <- reshape2::melt(lapply(r2_list$r2_total, function(x) lapply(x, 
            function(z) z)), varnames = c("view", "group"), 
            value.name = "R2")
        colnames(r2_m_df)[(ncol(r2_m_df) - 1):ncol(r2_m_df)] <- c("view", 
            "group")
        r2_m_df$group <- factor(r2_m_df$group, levels = MOFA2::groups_names(object))
        r2_m_df$view <- factor(r2_m_df$view, levels = views_names(object))
        min_lim_bplt <- min(0, r2_m_df$R2)
        max_lim_bplt <- max(r2_m_df$R2)+5
        p2 <- ggplot(r2_m_df, aes_string(x = x, y = "R2",label=(round(r2_m_df$R2,1)),fill=r2_m_df$group)) + 
            geom_bar(stat = "identity" ,position="dodge",
               , width = 0.9) + 
            #facet_wrap(as.formula(sprintf("~%s",split_by)), nrow = 1) + 
                xlab("") + ylab("Variance explained (%)") + 
            geom_text( aes_string(x = x, y = "R2",label=(round(r2_m_df$R2,1)),fill=r2_m_df$group),
                      size=5,position = position_dodge(width=0.9) )+
            scale_y_continuous(limits = c(min_lim_bplt, max_lim_bplt), 
                expand = c(0.005, 0.005)) + theme(axis.ticks.x = element_blank(), 
            axis.text.x = element_text(angle=90,size = rel(2), color = "black"), 
            axis.text.y = element_text(size = rel(2), color = "black"), 
            axis.title.y = element_text(size = rel(2), color = "black"), 
            axis.line = element_line(size = rel(2), color = "black"), 
            panel.background = element_blank(), strip.background = element_blank(), 
            strip.text = element_text(size = rel(2)))
        if (length(unique(r2_m_df[, split_by])) == 1) 
            p2 <- p2 + theme(strip.text = element_blank())
        plot_list <- list(p1, p2)
    }
    else {
        plot_list <- p1
    }
    return(plot_list)
}