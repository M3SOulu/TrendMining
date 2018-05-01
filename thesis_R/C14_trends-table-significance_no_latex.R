outputmat <- rbind (
sapply ( significance_neg , length ),
sapply ( significance_pos , length ),
sapply ( significance_total , length ))
rownames ( outputmat ) <- c(" Negative trend ", " Positive trend ", " Total ")
colnames ( outputmat ) <- paste ("p-level =", format (p_level , drop0trailing = TRUE , scientific = FALSE ), sep ="")
print(outputmat)


#xTable <- xtable ( outputmat )
#xTableStrings <- unlist ( strsplit ( capture.output ( print ( xTable )), "\n"))
# xTableStrings <- xTableStrings [xTableStrings != "\\begin{table}[ ht]"]
# xTableStrings <- xTableStrings [xTableStrings != "\\end{table}"]
# xTableStrings <- append (xTableStrings , "\\hline ", after = 9)
#cat (xTableStrings , sep = "\n")