This script generates interaction networks between the genes in the given 
file and anotates them with KEGG and GO terms. The information come from 
TogoWS and IntAct. The interactions need to have a miscore >= 0.4 to be considered.
As output, it creates a report in the file 'Report.txt'. 

USAGE
-------------------------------------------------------------------------------------
ruby ./main genes_list_file
-------------------------------------------------------------------------------------
