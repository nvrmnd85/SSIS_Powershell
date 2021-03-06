################### DESCRIPTION ###########
## DEVELOPER: AARON JACKSON
## DATE: 18/07/2014
## DESC: This script is used to call deploy SQL releases
################## END DESCRIPTION ########

################ VARIABLES #################

$SQL_Dir = "\\Vfsydcagdev01\QRM\Releases\ETL\Iteration 2\SQL\"
$DB_Server = "NTSYDDBU324V11\M324CUAT11,50220"

################ END VARIABLES #################

################ SCRIPT ########################

#Invoke-Sqlcmd needs SQL2012 installed...

Clear-Host

sqlcmd -i $SQL_Dir"Control.sql" -S $DB_Server

sqlcmd -i $SQL_Dir"Staging.sql" -S $DB_Server

sqlcmd -i $SQL_Dir"ODS.sql" -S $DB_Server

################ END SCRIPT ####################