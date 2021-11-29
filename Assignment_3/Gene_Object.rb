# Class whose instances are genes. Attributes: Gene ID, motif position in + and - strands and
# sequence. 
class Gene

    # @return [string] gene ID
    attr_accessor :Gene_ID 
    
    ## The next two lists are attribute lists containing lists representing 
    ## exons and CTTCTT positions inside them (attribute list > exons > positions).

    # @return [list] motif position in + strand
    attr_accessor :positions_forward
    
    # @return [list] motif position in - strand
    attr_accessor :positions_reverse

    # @return [string] gene sequence
    attr_accessor :sequence

    @@record_hash_gene = Hash.new


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

        @@record_hash_gene[@Gene_ID] = self

    end

    
    # This class method loads the information from a file.
    # @param file [string] name of the file
    def Gene.load_from_file(file)
        
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

    # This class method returns all instances of the class.
    # @return [hash] all Gene instances.
    def Gene.all_instances

        return @@record_hash_gene
        
    end

end