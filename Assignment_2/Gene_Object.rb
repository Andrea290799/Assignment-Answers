class Gene

    attr_accessor :Gene_ID  

    @@record_list_gene = Hash.new
    @@direct_interactors_dictionary = Hash.new
    @@indirect_interactors_dictionary = Hash.new
    
    def initialize (params = {})

        @Gene_ID = params.fetch(:Gene_ID, nil)

        # We check the Gene_ID format is correct
        match_ID = Regexp.new(/[A-a][T-t]\d[G-g]\d{5}$/) 
        
        if match_ID.match(@Gene_ID)

          @Gene_ID = @Gene_ID

        else

          puts("\e[1;31mSorry, the Gen_ID #{@Gene_ID} format is incorrect. Try indotucing ATXGXXXXX, where X are numbers.\e[m")
          puts("\e[1;31mPlease, introduce another Gen_ID.\e[m")

          @Gene_ID = $stdin.gets

          if not match_ID.match(@Gene_ID)

            abort("\e[1;31mSorry, this format is not correct.\e[m")
          
          end

        end

        @@record_list_gene[@Gene_ID] = self

    end

    def Gene.load_from_file(file)
=begin
        This class method loads the information from a file.
        param file: the file to read.
=end
        
        # We read only the lines, not the header
        lines = File.readlines(file)
              
        lines.each do |line| 

            line = line.strip

            # We create new instances
            Gene.new(
            :Gene_ID => line
            )
                      
        end

    end

    def Gene.all_instances
=begin
        This class method returns all instances of the class.
        return @@record_list_gene: list that contains all the instances.
=end
        return @@record_list_gene
        
    end

    def Gene.get_url_information
=begin
        This class method gets the interactions information from IntAct 
        of the genes in the list and of their interactors. It saves the interactions
        in a file.
=end

        File.open('Interactions.tsv', 'w') do |f|

            f.puts "Interactor_1\tInteractor_2"

        end

        @@record_list_gene.values.each do |gene|

            interaction_address = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene.Gene_ID}?format=tab25"

            #In this case we add the 3rd argument of the function because
            #we want to get the interactors of the interactors. This is because with some
            #genes, result for B->A appears, but nor for A->B. 
            interactions = get_info_url(interaction_address, "tab25", gene.Gene_ID)
            
            interactions.each do |interactor|

                interaction_address = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{interactor}?format=tab25"

                get_info_url(interaction_address, "tab25")

            end

        end

    end


    def Gene.generate_direct_interactions_dictionary
=begin
        This class method reads the created file and generates a dictionary
        whose keys are the genes in the list and the values their interactors genes
        return: direct interactions dictionary
=end

        lines_interactions = File.readlines('Interactions.tsv').drop(1)
        
        @@record_list_gene.values.each do |gene| 

            interactions_list = []

            gene.Gene_ID.upcase!

            lines_interactions.each do |line_interaction| 

                line_interaction = line_interaction.split("\t")
    
                int1 = line_interaction[0].strip.upcase!
                int2 = line_interaction[1].strip.upcase!

                if gene.Gene_ID == int1

                    interactions_list << int2 

                elsif  gene.Gene_ID == int2

                    interactions_list << int1
                end

            end

            interactions_list.uniq!

            if interactions_list.include?(gene.Gene_ID)
                interactions_list.delete(gene.Gene_ID)
            end

            if interactions_list.length() > 0
                @@direct_interactors_dictionary[gene.Gene_ID] = interactions_list.compact
            end

            
        end

        return @@direct_interactors_dictionary

    end


    def Gene.generate_indirect_interactions_dictionary

=begin
        This class method uses a interaction dictionary to create another dictionary, 
        this time with indirect interactions (it gets all interactions like A->B->C, 
        being A and C in the list)
        return: indirect interactions dictionary
=end

        @@record_list_gene.values.each do |gene| 

            final_list = Array.new

            if @@direct_interactors_dictionary.keys.include?(gene.Gene_ID)

                #We look at all the interactors of our target gene
                @@direct_interactors_dictionary[gene.Gene_ID].each do |value|

                    #If it's included in our initial list(initial file), we add it to the output list
                    if @@direct_interactors_dictionary.keys.include?(value)

                        final_list << value
                        
                        #And if it interacts with another gene of the initial list, we also add it
                        @@direct_interactors_dictionary.each do |key, values|

                            if values.include?(value)

                                final_list << key

                            end

                        end

                    else
                        
                        #If it's not included in our initial list, but it interacts with
                        #another gene in the initial list, we add both to the output list. 
                        @@direct_interactors_dictionary.each do |key, values|

                            if values.include?(value)

                                final_list << value unless key == gene.Gene_ID

                                final_list << key unless key == gene.Gene_ID

                            end

                        end

                    end

                end

                #If there are results
                if final_list.length > 0

                    #We add the target gene to the network and get the output list
                    final_list << gene.Gene_ID


                    #we sort it to get rid of repeated elements
                    final_list_sort = final_list.sort

                    @@indirect_interactors_dictionary[gene.Gene_ID] = final_list_sort.uniq()

                end
            end

        end

        return @@indirect_interactors_dictionary

    end

    def Gene.generate_networks

=begin
        This class method generates networks given an interaction dictionary.
        return: a list of networks. 
=end

        networks_list_values = @@indirect_interactors_dictionary.values

        while true

            #big list
            b_list = Array.new

            @@indirect_interactors_dictionary.keys.each do |key|

                #little list
                l_list = Array.new

                networks_list_values.each do |value|

                    if value.include?(key)
                        l_list << value
                    end

                end 

                #we try to flatten the list, if not "a" will be nil
                a = l_list.flatten

                if not a.nil?
                    l_list = a.uniq
                else
                    l_list = l_list.uniq
                end

                b_list << l_list
            end

            b_list.uniq!

            #when all the little networks are all merged, we stop
            if b_list == networks_list_values

                break

            else #we repeat the process

                networks_list_values = b_list

            end

        end

        return b_list.uniq

    end
 
end