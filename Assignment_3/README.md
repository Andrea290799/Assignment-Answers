This script gets the .embl file from all the genes present in the given list
and searches from CTTCTT motif in their exons sequence, both the strands + and -. 
It generates 3 files, gene_coordinates.gff3, chr_coordinates.gff3 and No_CTTCTT_report.txt.
The first one contains the coordinates of CTTCTT motif using as reference the gene
coordinates and the second one contains the same but using the chromosome coordinates.
The third one is a report of all the genes that do not have CTTCTT motif.  

--------------------------------------------------------------------
  USAGE
  ruby ./main genes_list_file
--------------------------------------------------------------------
