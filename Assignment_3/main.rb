require 'rest-client'  
require 'bio'
require 'enumerator'
require './Functions.rb'
require './Gene_Object.rb'

help

check_format(ARGV[0], /^[A-a][T-t][0-9][G-g][0-9]{5}/)

Gene.load_from_file(ARGV[0])

# We set the headers of the 3 resulting files
File.open("No_CTTCTT_report.txt", "w") do |file|
    file.puts "No CTTCTT in these genes:"
end

File.open("gene_coordinates.gff3", "w") do |file|
    file.puts "##gff-version 3\n"
end

File.open("chromosome_coordinates.gff3", "w") do |file|
    file.puts "##gff-version 3\n"
end

# This string will contain all sequences with CTTCTT
all_sequences = ""

Gene.all_instances.values.each do |gene|

    # we get the EMBL information
    address = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene.Gene_ID}" 
    response = RestClient.get(address)                                            
    record = response.body
    entry = Bio::EMBL.new(record)

    # we get the CTTCTT positions in both strands
    positions = get_positions_motifs(entry, gene.Gene_ID) 

    positions_forward = positions[0]
    positions_reverse = positions[1]

    # we add the new attributes to the gene instance
    gene.positions_forward = positions_forward
    gene.positions_reverse = positions_reverse

    if not (positions_forward.flatten.empty? and positions_reverse.flatten.empty?)

        # we get the sequences that have CTTCTT motif
        all_sequences = all_sequences + "#{entry.to_biosequence.output_fasta(definition=gene.Gene_ID)}"
        gene.sequence = entry.seq

    else

        # we get the sequences that don't have CTTCTT motif
        File.open("No_CTTCTT_report.txt", "a") do |file|
            file.puts gene.Gene_ID
        end

        next

    end

    biosequence = entry.to_biosequence

    #we add CTTCTT features
    add_features(positions_forward, "+", biosequence)
    add_features(positions_reverse, "-", biosequence)

    #we add features to the gff3
    write_to_GFF3(entry, biosequence, gene.Gene_ID)

end

#we add the sequences to the gff3 with gene coordinates
File.open("gene_coordinates.gff3", "a") do |file|
    file.puts "##FASTA"
    file.puts all_sequences
end










