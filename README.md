# PTBCprevalence
R and Stan code for estimation of PTBC prevalence of correlated subgroups in dairy herds

Estimation of Within-Herd PTBC Infection in Dairy Cattle Herds
Input: Csv datafile in long format, cow level data matching template.csv
Output: Prevalence_countryname_datafilename_date.doc, Estimate_countryname_datafilename_date.xlsx, Graph_countryname_datafilename_date.pdf

    Save the project files in a folder

    Install RStudio if necessary

    Create the input CSV file containing the cow data based on the template.csv file, or use the test.csv file

    Launch RStudio

    Install the following packages if necessary: RStan, Rmarkdown, knitr, ggplot2, cowplot, ggridges, openxlsx, stringr, brigdesampling

    Open the parameters.r file

    	Set the working directory. Use \ or / as path separators depending on the operating system
	Set the number of MCMC iterations (20.000 is the recommended value)
    	Provide the name of the input csv file (datafile) containing cow-level data accroding to the structure of template.csv. This file should be located in the working library
    	Provide the name of the country chosing from the list with prespecified priors (available: Hungary, Denmark, Chile, N_Italy, Lombardy, Veneto) or give a custom name.
    		If working with custom country, change the parameters of the priors to much your country, do not change c.
	run the file

    After a few minutes, a PDF file with the results will open, and an .xlsx and another .pdf file containing the estimation and the graph will appear in your working directory.
