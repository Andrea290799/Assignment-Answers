# This function print a help message if needed.
def help

        if ARGV[0] == "-h" || ARGV[0] == "-help"
            abort(
                "\n\t\tThis script generates interaction networks between the genes in the given
                file and anotates them with KEGG and GO terms. The information come from 
                TogoWS and IntAct. The interactions need to have a miscore >= 0.4 to be considered.
                As output, it creates a report in the file 'Report.txt'. 
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


#This function gets the raw information from a given url. If the format
#is json, it doesn't process the data, unlike if it is another format (tab25 this case). 
#If 3rd argument given and format is not json, it returns a interactors list. 
# @param url [string] url to search
# @param file_format [string] output file format
# @param gene_name [string] gene to seach information about. Optative.
# @return [list] information in url
# @return [list] interactors search reuslts. When 3rd argument given.
def get_info_url(url, file_format, *gene_name)

    interacts_with = Array.new #this array will contain the interactors search reuslts

    response = RestClient::Request.execute(method: :get,
                                            url: url)  

    if file_format == "json" #for togows results

        parsed_result = JSON.parse(response.body)

        return parsed_result

    else #for IntAct results

        parsed_result = response.body

        interaction_lines = parsed_result.split("\n")

        interaction_lines.each do |line|

            line = line.split("\t")

            species1 = line[9] #column 10
            species2 = line[10] #column 11
            miscore = line[14][15..18].to_f #some characters from column 15

            #We only want taxids = 3702
            species_regexp = Regexp.new(/^taxid:3702/)  
                        
            match_1 = species_regexp.match(species1)
            match_2 = species_regexp.match(species2)

            #I have chosen a miscore of 0.4 because of the information found
            #in the web site: https://platform-docs.opentargets.org/target/molecular-interactions
            
            if (match_1 and match_2) and (miscore >= 0.4)
                    
                gene_name_regexp = Regexp.new(/[A-a][T-t][0-9][G-g][0-9]{5}/)  
                        
                match = gene_name_regexp.match(line[2])

                #many times the AGI code is not in 3,4 columns but it is in 5,6

                if match.nil? 
                    match = gene_name_regexp.match(line[4])
                end 

                interactor1 = match

                match = gene_name_regexp.match(line[3])

                if match.nil?
                    match = gene_name_regexp.match(line[5])
                end 

                interactor2 = match

                File.open('Interactions.tsv', 'a') do |f|

                    f.puts "#{interactor1}\t#{interactor2}"

                end 

                if interactor1 == gene_name

                    interacts_with << interactor2

                else

                    interacts_with << interactor1

                end

            end

        end 

    end

    return interacts_with

end


# This function process the raw GO information from the genes of a given list. 
# @return [hash] return: lists of the GO terms of each of the genes present in the given list, being the keys genes from the gene list file. 
def select_GO_information(gene_list)

    go_annotations_hash = Hash.new

    gene_list.each do |gene|

        annotator_ID = gene + "_GO"
    
        go_address = "http://togows.org/entry/ebi-uniprot/#{gene}/dr.json"
        annotator = Annotator.new(:Gene_ID => annotator_ID, :address => go_address)
        go_annotations_hash[gene] = annotator.information

    end

    go_parsed_annotations_hash = Hash.new

    go_annotations_hash.each do |key, go|
    
        parsed_annotations_list = Array.new
    
        go_terms_list = go[0]["GO"]
    
        go_terms_list.each do |item|
            if item[1]  =~ /^P/ #we only want the biological process
                parsed_annotations_list << item
            end
        end
    
        go_parsed_annotations_hash[key] = parsed_annotations_list
    
    end
    
    return go_parsed_annotations_hash

end

# This function process the raw KEGG information from the genes of a given list. 
# @return [hash] return: lists of the KEGG terms of each of the genes present in the given list, being the keys genes from the gene list file. 
def select_KEGG_information(gene_list)

    kegg_annotations_hash = Hash.new

    gene_list.each do |gene|

        annotator_ID = gene + "_KEGG"

        go_address = "http://togows.org/entry/kegg-genes/ath:#{gene}/pathways.json"
        annotator = Annotator.new(:Gene_ID => annotator_ID, :address => go_address)
        kegg_annotations_hash[gene] = annotator.information

    end

    kegg_parsed_annotations_hash = Hash.new

    kegg_annotations_hash.each do |key, kegg|

        parsed_annotations_list = kegg[0]

        kegg_parsed_annotations_hash[key] = parsed_annotations_list

    end

    return kegg_parsed_annotations_hash

end



    












