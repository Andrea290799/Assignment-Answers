This script gets the two files given by arguments and makes
a reciprocal blast search between them, taking into account the evalue
and coverage indicated.  
--------------------------------------------------------------------
USAGE
ruby ./main file1 file2 coverage evalue
--------------------------------------------------------------------

Evalue and coverage default values were chosen because of the information
found in this article: https://doi.org/10.1093/bioinformatics/btm585

NEXT STEPS:
Orthologs are defined as genes in different species that have evolved
through speciation events only. After finding the BRHs, a third species
should be included in the analysis in order to perform COG analysis,
where a set of 3 genes can form a single COG and 2 COGs join together
if they share any BRHs. The next step to confirm the existence of
possible orthologous genes would be to perform a multiple sequence
alignment (MSA) and the generation of a phylogenetic tree in order to
actually see the relationships of this type between the sequences found.
The basic idea is to build a phylogenetic tree with the different genes,
being able to estimate when a function has diverged and can identify a
branch that could be regarded as a functionally consistent ortholog group.

