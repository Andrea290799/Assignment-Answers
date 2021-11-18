# Class whose instances are gene interaction networks. Attributes: network and processed annotations.
class Network

    # @return [list] all networks
    attr_accessor :network

    # @return [hash] processed annotations
    attr_accessor :annotations

    @@record_list_network = Array.new

    def initialize (params = {})

        @network = params.fetch(:network, nil)
      
        annotations = Hash.new

        annotations["GO"] = select_GO_information(@network)

        annotations["KEGG"] = select_KEGG_information(@network)

        @annotations = annotations

        @@record_list_network << self

    end


    # This class method loads the information from a list.
    # @param list [list] the list to read.
    def Network.load_from_list(list)

        list.each do |network|

            # We create new instances
            Network.new(
            :network => network
            )
        end
                              
    end

    # This class method returns all instances of the class.
    # @return [list] all Network instances.
    def Network.all_instances

        return @@record_list_network
                
    end


    # This class method writes a results report in a new file.
    def Network.create_report

        File.delete('Report.txt') if File.exist?('Report.txt')

        $stdout = File.new('Report.txt', 'a')

        puts "Interaction information obtained from IntAct (filtered by taxid=3702 and miscore >= 0.4)"
        puts "KEGG and GO information obtained from TogoWS (only selected biological process from GO)"
        puts
        puts "\t\t\t\t\t\t\t\t ----------------"
        puts "\t\t\t\t\t\t\t\t |Found networks|"
        puts "\t\t\t\t\t\t\t\t ----------------"
        puts

        sum = 0 #gene list counter
        n = 0 #network counter

        @@record_list_network.each do |network|

            in_list_genes = Array.new #to get the genes in the list

            n+=1

            puts "-----------------------------------------------------------------------------------------"
            puts
            puts "Network #{n}:"
            puts

            #I have decided to present the interactions showing the total network, instead of
            #binary interactions (ABCD instead of A-B, B-C, C-D), because I find this way better to see. 
            #I think both ways are correct, because the given instructions can be interpreted both ways. 
            
            print network.network
            puts
            puts

            lines = File.readlines(ARGV[0])

            network.network.each do |gene|

                lines.each do |name|
                    
                    upcase_name = name.upcase
                    
                    if upcase_name.strip == gene.strip

                        in_list_genes << gene.strip
                        sum += 1

                    end

                end

                go_terms = network.annotations["GO"][gene]
                    
                puts "\tGene #{gene} GO terms"
                puts

                if go_terms.empty?

                    puts "\t\tNo GO terms found"
                    puts

                else

                    go_terms.uniq!

                    go_terms.each do |go_term|
    
                        puts "\t\t#{go_term[0]}\t#{go_term[1]}\t#{go_term[2]}\t" 
                        puts  

                    end

                end

                kegg_terms = network.annotations["KEGG"][gene]

                puts "\tGene #{gene} KEGG terms" 
                puts 

                if kegg_terms.empty?
                    
                    puts "\t\tNo KEGG terms found"
                    puts

                else

                    kegg_terms.each do |kegg_term|

                        puts "\t\t#{kegg_term[0]}\t#{kegg_term[1]}" 
                        puts

                    end 

                end

            end

            puts
            print "\tGenes on the list: #{in_list_genes}"
            puts
        
        end

        lines = File.readlines(ARGV[0])

        total = lines.length() #total genes in the list

        puts
        percentage = sum.to_f/total.to_f
        percentage = percentage.round(2)*100
        print "#{percentage}% of the genes in the list interact with one another."
        puts

        if percentage < 50 

            print "The percentage is low, at least filtering by 0.4 miscore."

        else

            print "The percentage is high."

        end

    end
     
end