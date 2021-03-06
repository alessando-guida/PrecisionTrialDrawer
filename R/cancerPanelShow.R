setMethod('show', 'CancerPanel', function(object) {
    nItems <- length(cpArguments(object)$genedata$gene_symbol)
    message(paste('\nCancerPanel object with', nItems, 'genes:'))
    items <- cpArguments(object)$genedata$gene_symbol
    itemsText <- paste(head(items), collapse=', ')
    message(paste(itemsText, ifelse(nItems>6, ', ...\n', '\n'), sep=''))

    nItems <- length(cpArguments(object)$drugs %>% .[.!=""])
    message(paste('and', nItems, 'drugs:'))
    if(nItems!=0){
        items <- cpArguments(object)$drugs %>% .[.!=""]
        itemsText <- paste(head(items), collapse=', ')
        message(paste(itemsText, ifelse(nItems>6, ', ...\n', '\n'), sep=''))
    }

    message(paste("The panel contains alterations of the following types:" 
            , paste(unique(cpArguments(object)$panel$alteration) 
                    , collapse=", ")))

    if(!identical(cpData(object) , list())){
        message("\n")
        for(i in c("mutations" , "copynumber" , "fusions" , "expression")){
            if(!is.null(cpData(object)[[i]]$data)){
                message(paste("The object contains" ,
                        i ,
                        "data for the tumor types:" ,
                        paste(sort(unique(cpData(object)[[i]]$data$tumor_type))
                            , collapse=", ")))
            } else {
                message(paste("No" , i , "data"))
            }
        }
        alterationType <- c("copynumber" 
            , "expression" , "mutations" , "fusions")
        allcombs <- lapply( seq.int(1 , length(alterationType) , 1) 
            , function(x) {
          combn(alterationType , x , simplify=FALSE)
        }) %>% unlist(recursive = FALSE)
        mytums <- cpArguments(object)$tumor_type
        sampSummary <-   lapply( allcombs , function(comb) {
        allsamps <- lapply( cpData(object)[comb] , '[[' , 'Samples')
          vapply( mytums , function(tum) {
            length(Reduce("intersect" , lapply(allsamps , '[[' , tum)))
          } , numeric(1))
        }) %>% do.call("rbind" , .)
        sampSummary <- cbind( Combinations = vapply( allcombs 
            , function(x) paste(x , collapse=",") , character(1))
                            , sampSummary)
        message("\nAvailable samples for each combination of alteration types:")
        message(paste0(capture.output(sampSummary), collapse = "\n"))
    } else {
      message("The object contains no data")
    }
})