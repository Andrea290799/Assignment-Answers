class Gene
=begin
  This class represents a Gene table of the database. It has information
  about different fields as Gene_ID, Gene_name and mutant_phenotype.
  Methods: Gene.all_instances and Gene.get_info(code).
=end

    # This class variable will contain the different instances with the file information
    @@record_list_gene = Array.new

    attr_accessor :Gene_ID  
    attr_accessor :Gene_name
    attr_accessor :mutant_phenotype
    attr_accessor :linked_genes

    
    def initialize (params = {})

        @Gene_ID = params.fetch(:Gene_ID, nil)
        @Gene_name = params.fetch(:Gene_name, nil)
        @mutant_phenotype = params.fetch(:mutant_phenotype, nil)

        @linked_genes = Hash.new

        # We get rid off the empty fields
        if @Gene_ID.nil? or @Gene_name.nil? or @mutant_phenotype.nil?

          abort("\e[1;31mThere are empty fields. Please fill in the following missing fields: Gene_ID, Gene_name and mutant_phenotype.\e[m")

        end

        # We check the Gene_ID format is correct
        match_ID = Regexp.new(/AT\dG\d{5}$/) 
        
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

        @@record_list_gene << self

    end


    def Gene.all_instances
=begin
      This class method returns all instances of the class.
      return @@record_list_gene: list that contains all the instances.
=end
      return @@record_list_gene

    end


    def Gene.get_info(code)
=begin
      This class method gets information related to a Gene_ID code.
      param code: Gene_ID we want to get information from.
      return hash: information of the instance.
=end

      # n equals zero when the introduced code is not in the database
      n = 0
      
      #For every instance...
      @@record_list_gene.each do |record|

        if record.Gene_ID == code

          return {
            "Gene_ID" => record.Gene_ID, 
            "Gene_name" => record.Gene_name,
            "mutant_phenotype" => record.mutant_phenotype}

          #Just to change the value to indicate there is not problem
          n = 1

        end

      end

      if n == 0    

        abort ("\e[1;31mError. You are trying to get information or to add an instance from a record that does not exist in the Gene data base.\e[m")
      
      end

    end

    def add_linked_gene_chi2(linked_gene, chi2)
=begin
      This method creates a hash as an object property that contain the name of the 
      linked gene and its chi2 score.
      param linked_gene: the name of the gene that is linked.
      param chi2: chi2 score of the link.
=end

      @linked_genes[linked_gene] = chi2

    end
    
end


