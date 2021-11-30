# This function prints a help message if needed.
def help

    if ARGV[0] == "-h" || ARGV[0] == "-help"
        abort(
            "\n\t\tThis script gets the .embl file from all the genes present in the given list
            and searches from CTTCTT motif in their exons sequence, both the strands + and -. 
            It generates 3 files, gene_coordinates.gff3, chr_coordinates.gff3 and No_CTTCTT_report.txt.
            The first one contains the coordinates of CTTCTT motif using as reference the gene
            coordinates and the second one contains the same but using the chromosome coordinates.
            The third one is a report of all the genes that do not have CTTCTT motif.  
            --------------------------------------------------------------------
                USAGE
                ruby ./main genes_list_file
            --------------------------------------------------------------------\n")
    end
end


# This function checks whether the given file has the correct format.
# @param file [string] input file
# @param identifier [string] regular expression to search in the file. It must be between '/'.
def check_format(file, identifier)
    
    if File.file?(file) == true
    
        lines_gene = File.readlines(file)
                
        match = Regexp.new(identifier) 
                
        if not match.match(lines_gene[0])

            abort("\e[1;31mSorry, the #{file} file has not the correct format.\e[m")

        end
           
    else 

        abort("\e[1;31mSorry, the #{file} file does not exist.\e[m")

    end
end


# This function generates a list of gene coordinates given a list with the initial 
# positions of a motif, in exon coordinates. 
# @param incomplete_position_list [list] list with the initial position of a motif
# @param exon_pos [MatchData] regex match object that contains the start and end 
# positions of the exon where we are searching the motif (to convert to gene coordinates).
# @return [list] list of gene coordinates of the motif
def generate_complete_position_list(incomplete_position_list, exon_pos)

    complete_position_list = Array.new

    unless incomplete_position_list.empty?
        
        #for each initial position
        incomplete_position_list.each do |ini| 

            motif = Array.new
            #convert to gene coordinates
            motif << ini + exon_pos[1].to_i 
            motif << ini + exon_pos[1].to_i+5

            complete_position_list << motif

        end

        return complete_position_list

    end
end


# This function gets the starting and ending positions of the exons in the +
# and - strands of the sequence. Then searches for a motif in the exon
# sequence and gets the gene coordinates.
# @param entry [Bio::EMBL] embl information
# @param gene_id [string] gene name
# @return [list] list of gene coordinates of the motif in the + and - strands. 
def get_positions_motifs(entry, gene_id)

    forward_positions = Array.new
    reverse_positions = Array.new

    entry.features.each do |feature|

        # we have to make sure we are getting the exons of the gene we are looking at.
        # for example, this gene has exons from 2 different genes
        # https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=AT5g15850
        if feature.feature == "exon" and feature.assoc()["note"][8..16] == gene_id.upcase

            # if the coordinates are like: 1..5
            re_pos_exonA = Regexp.new(/^(\d+)\.\.(\d+)/)
            # if the coordinates are like: complemet(1..5)
            re_pos_exonB = Regexp.new(/\((\d+)\.\.(\d+)/)

            positions = feature.position
            
            # we first try searching for the less "permissive" regex
            match_pos_exon = positions.match(re_pos_exonB) 

            # if there is no match...we try the other expression
            if not match_pos_exon
                match_pos_exon = positions.match(re_pos_exonA)
            end
            
            unless match_pos_exon.nil? 

                # in the + strand...
                # ?=(motif) is used to find overlapping motifs
                re_motif_forward = Regexp.new(/(?=(cttctt))/) 
                sequence = entry.seq.subseq[match_pos_exon[1].to_i-1..match_pos_exon[2].to_i-1]
                sites = sequence.enum_for(:scan, re_motif_forward).map { Regexp.last_match.begin(0) }

                # we get the gene coordinates of the motif 
                a = generate_complete_position_list(sites, match_pos_exon)

                # in the - strand...
                re_motif_reverse = Regexp.new(/(?=(aagaag))/)
                sites = sequence.enum_for(:scan, re_motif_reverse).map { Regexp.last_match.begin(0) }

                # we get the gene coordinates of the motif 
                b = generate_complete_position_list(sites, match_pos_exon)

            end
            
        end

        forward_positions << a
        reverse_positions << b

    end

    # uniq -> for getting rid of duplicate coordinates (corresponding different transcripts)
    return [forward_positions.uniq.compact, reverse_positions.uniq.compact]

end

# This function adds some features to the Bio::Sequence sequence
# @param positions_list [list] coordinates of the motif in the + or - strand.
# @param strand [string] strand
# @param entry [Bio::Sequence] sequence
def add_features(positions_list, strand, entry)

    repeats = Array.new #for repeated positions

    positions_list.each do |exon|

        unless exon.empty?

            exon.each do |motif|

                #to avoid repeated positions
                if not repeats.include?(motif[0])

                    f1 = Bio::Feature.new('motif',"#{motif[0]}..#{motif[1]}")
                    f1.append(Bio::Feature::Qualifier.new('repeat_motif', 'CTTCTT'))
                    f1.append(Bio::Feature::Qualifier.new('strand', strand))
                    entry.features << f1

                end

                repeats << motif[0]

            end

        end
    
    end

end


# This function writes the features in the gff3 files
# @param first_entry [Bio::EMBL] embl information
# @param entry [Bio::Sequence] sequence
# @param gene_name [string] gene name
def write_to_GFF3(first_entry, entry, gene_name)

    gff = ""
    gff2 = ""

    entry.features.each do |feature|

        if feature.feature == "motif"

            matches = Array.new

            strand = feature.assoc['strand']

            #we get the gene positions of the motif
            re = Regexp.new(/^(\d+)\.\.(\d+)/)
            positions = feature.position
            match = positions.match(re)

            #gene cordinates
            gff = gff + "#{gene_name}\t.\t.\t#{match[1].to_i}\t#{match[2].to_i}\t.\t#{strand}\t.\tnote=#{gene_name}\n"

            #we get the chromosome positions of the motif
            re = Regexp.new(/\:(\d)\:(\d+)\:(\d+)/)
            match2 = first_entry.accession.match(re)

            #chromosome coordinates
            gff2 = gff2 + "chr#{match2[1]}\t.\t.\t#{match[1].to_i+match2[2].to_i-1}\t#{match[2].to_i+match2[2].to_i-1}\t.\t#{strand}\t.\tnote=#{gene_name}\n"
        
        end

    end

    if gff == ""

        return nil

    else

        File.open("gene_coordinates.gff3", "a") do |file|
            file.puts gff unless gff.nil?
        end
    
        File.open("chromosome_coordinates.gff3", "a") do |file|
            file.puts gff2 unless gff2.nil?
        end
        
    end

end

