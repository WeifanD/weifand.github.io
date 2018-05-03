
#' This R script will process all R mardown files (those with in_ext file extention,
#' .rmd by default) in the current working directory. Files with a status of
#' 'processed' will be converted to markdown (with out_ext file extention, '.markdown'
#' by default). It will change the published parameter to 'true' and change the
#' status parameter to 'publish'.
#' 
#' @param path_site path to the local root storing the site files
#' @param dir_rmd directory containing R Markdown files (inputs)
#' @param dir_md directory containing markdown files (outputs)
#' @param url_images where to store/get images created from plots directory +"/" (relative to path_site)
#' @param out_ext the file extention to use for processed files.
#' @param in_ext the file extention of input files to process.
#' @param recursive should rmd files in subdirectories be processed.
#' @return nothing.
#' @author Jason Bryer <jason@bryer.org> edited by Andy South
rmd2md <- function( path_site = getwd(),
                    dir_rmd = "_rmd",
                    dir_md = "_posts",                              
                    #dir_images = "figures",
                    url_images = "figures/",
                    out_ext='.md', 
                    in_ext='.Rmd', 
                    recursive=FALSE) {
  
  require(knitr, quietly=TRUE, warn.conflicts=FALSE)
  
  #andy change to avoid path problems when running without sh on windows 
  files <- list.files(path=file.path(path_site,dir_rmd), pattern=in_ext, ignore.case=TRUE, recursive=recursive)
  i = 0
  for(f in files) {
    #message(paste("Processing ", f, sep=''))
    content <- readLines(file.path(path_site,dir_rmd,f), encoding = "UTF-8")
    publishedLine <- which(substr(content, 1, 10) == 'published:')
    published <- unlist(strsplit(content[publishedLine], ':'))[2]
    published <- sub('[[:space:]]+', '', published)
    if(published == "false") {
       #This is a bit of a hack but if a line has zero length (i.e. a
       #black line), it will be removed in the resulting markdown file.
       #This will ensure that all line returns are retained.
      content[nchar(content) == 0] <- ' '
      message(paste('Processing ', f, sep=''))        
      content[publishedLine] <- 'published: true'
          
      #andy change to path
      outFile <- file.path(path_site, dir_md, paste0(substr(f, 1, (nchar(f)-(nchar(in_ext)))), out_ext))
          
      #render_markdown(strict=TRUE)
      #render_markdown(strict=FALSE) #code didn't render properly on blog
          
      #andy change to render for jekyll
      render_jekyll(highlight = "pygments")
      #render_jekyll(highlight = "prettify") #for javascript
          
      opts_knit$set(out.format='markdown') 
          
      # andy BEWARE don't set base.dir!! it caused me problems
     # "base.dir is never used when composing the URL of the figures; it is 
       # only used to save the figures to a different directory. 
      # The URL of an image is always base.url + fig.path"
      # https://groups.google.com/forum/#!topic/knitr/18aXpOmsumQ
          
      opts_knit$set(base.url = "/")
      opts_chunk$set(fig.path = url_images)                     
          
      #andy I could try to make figures bigger
      #but that might make not work so well on mobile
     opts_chunk$set(fig.width  = 8.5,
                   fig.height = 5.25)
          
      try(knit(text=content, output=outFile), silent=FALSE)
     
      i = i + 1    
      } else {
         warning(paste("Not processing ", f, " Please set published to 'false' to convert.", sep=' '))
    }
  }
  message(paste0("The number of total processed files is:", i, sep = " "))
}
rmd2md()
#Contact GitHub API Training Shop Blog About
#© 2017 GitHub, Inc. Terms Privacy Security Status Help

