library ( xtable )
frequencies <- t(table( (unlist(Years)) ))
rownames ( frequencies ) <- " Frequency "
xTable <- xtable ( frequencies )
xTableStrings <- unlist (strsplit(capture.output ( print ( xTable )), "\n"))
xTableStrings <- xTableStrings [ xTableStrings != "\\begin{table}[ht]"]
xTableStrings <- xTableStrings [ xTableStrings != "\\end{table}"]
cat ( xTableStrings , sep = "\n")