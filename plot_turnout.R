# load packages
library(XML)
library(dplyr)
library(ggplot2)

# create empty data frames
# this is for storing info when a page is read, overwritten when the next page is processed
turnout_df <- data.frame(Turnout=as.character())
# this is for storing info from all pages
turnout_df_all <- data.frame(Time=as.character(),
							Voter_Turnout=as.numeric(),
							Cumulative_Turnout_Rate=as.numeric(),
							Category=as.character()
)

# create a list containing substrings of URLs from which data is extracted
URL_subset <- c("tt_gc_GC.html", "tt_gc_LC1.html", "tt_gc_LC2.html", "tt_gc_LC3.html", "tt_gc_LC4.html", "tt_gc_LC5.html")

# map substrings of URLs indicating geographical constituencies to something more 
# comprehensable for humans to be used in graphs and connected with UI
code <- c("tt_gc_GC", "tt_gc_LC1", "tt_gc_LC2", "tt_gc_LC3", "tt_gc_LC4", "tt_gc_LC5")
name <- c("Overall", "Hong Kong Island", "Kowloon West", "Kowloon East", "New Territories West", "New Territories East")
mappings <- setNames(as.list(name),code)

# function for creating data frame with turnout rate info etc. extracted from the web
# arguments to this function are: 1. html tree parsed; 2. substring of URL indicating geographical constituency
create_df <- function(html,category) {

	# identify the relevant rows containing turnout info in source page
	turnout_rows <- xpathSApply(html, "//td/parent::tr[@bgcolor='#ECECEC']", xmlValue)
	
	# put these rows into a data frame
	turnout_df <- rbind(turnout_df, data.frame(turnout_rows))
	
	# clean up trailing whitespaces in source and 
	# add new column with mapped name for geographical constituency
	turnout_df_3col <- data.frame(do.call('rbind',strsplit(gsub("\n\ *$", "", turnout_df$turnout_rows),"\n",fixed=T))) %>%
						mutate(Category = mappings$category)
	
	# assign column names
	colnames(turnout_df_3col) <- c("Time", "Voter_Turnout", "Cumulative_Turnout_Rate","Category")
	# remove "%" from turnout rate in source and convert it to numeric variable
	turnout_df_3col$Cumulative_Turnout_Rate <- as.numeric((gsub("%", "", turnout_df_3col$Cumulative_Turnout_Rate)))
	
	# append data frame created above to data frame containing info for all geographical constituencies
	turnout_df_all <<- rbind(turnout_df_all, turnout_df_3col)


}

# 1st main part of this script: read all relevant pages and call create_df function
# for extracting relevant data
for (s in URL_subset) {

	# create full URL for pages to be processed
	URL <- paste("http://www.elections.gov.hk/legco2016/eng/", s, sep="",collapse="")
	html_filename <- paste("turnout_", s, sep="",collapse="")
	# download html file for processing
	download.file(URL, destfile=html_filename, method="curl")
	
	# extract geographical constituency info from URL
	category <- gsub(".html","",s)

	# parse html file downloaded
	html <- htmlTreeParse(html_filename, useInternalNodes=T)
	# call create_df function
	create_df(html,category)

}

# 2nd main part of this script: plot graph for geographical constituencies selected in UI
# argument to this function is a numeric value mapped from user input (mapping done in ui.R)
plot_graph <- function(constituencies) {
  
	# get geographcial constituencies for which graphs will be plotted
	subsets_const <- name[as.numeric(constituencies)]
  
  	# extract rows from turnout_df_all for geographical constituencies selected into
  	# another data frame turnout_df_subset
	turnout_df_subset <- filter(turnout_df_all, Category %in% subsets_const)
  
  	# plot graph with ggplot2
	g <- ggplot(turnout_df_subset, aes(x=Time, y = Cumulative_Turnout_Rate,group=Category,colour=Category))
	g <- g + geom_line() + geom_point() +
		xlab("Time of the Day") + ylab("Cumulative Turnout Rate (%)") +
		ggtitle("2016 HK Legislative Council Election Voter Turnout Rate in Geographical Constituencies")
	return(g)
}

