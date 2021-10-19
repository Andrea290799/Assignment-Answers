class HybridCross 
=begin
    This class represents a HybridCross table database. It has information
    about different fields as Parent1, Parent2, F2_Wild,
    F2_Wild, F2_P2 and F2_P1P2.
    Methods: HybridCross.all_instances, HybridCross.get_info(code1, code2),
    HybridCross.linked? and HybridCross.final_report.
=end

    # This class variable will contain the different instances with the file information
    @@record_list_cross = Array.new

    # This class variable will contain the different genes that are linked
    @@linked_list = Array.new

    attr_accessor :Parent1  
    attr_accessor :Parent2
    attr_accessor :F2_Wild
    attr_accessor :F2_P1
    attr_accessor :F2_P2
    attr_accessor :F2_P1P2

    def initialize (params = {})

        @Parent1 = params.fetch(:Parent1, nil)
        @Parent2 = params.fetch(:Parent2, nil)
        @F2_Wild = params.fetch(:F2_Wild, nil)
        @F2_P1 = params.fetch(:F2_P1, nil)
        @F2_P2 = params.fetch(:F2_P2, nil)
        @F2_P1P2 = params.fetch(:F2_P1P2, nil)

        # We get rid off the empty fields
        if @Parent1.nil? or @Parent2.nil? or @F2_Wild.nil? or @F2_P1.nil? or @F2_P2.nil? or @F2_P1P2.nil?
          
          abort("\e[1;31mThere are empty fields. Please fill in the following missing fields: Parent1, Parent2, F2_Wild, F2_P1, F2_P2 and F2_P1P2.\e[m")
        
        end

        #We make sure parents are existing records in SeedStock table
        @Parent1 = SeedStock.get_info(@Parent1)["Seed_Stock"]
        @Parent2 = SeedStock.get_info(@Parent2)["Seed_Stock"]

        @@record_list_cross << self

    end

    def HybridCross.all_instances
=begin
        This class method returns all instances of the class.
        return @@record_list_cross: list that contains all the instances.
=end
        return  @@record_list_cross

    end

    def HybridCross.get_info(code1, code2)
=begin
        This class method gets information related to a HybridCross code.
        params code1, code2: Seed_Stock codes hybrid cross we want to get information from.
        return hash: information of the instance.
=end

        # n equals zero when the introduced code is not in the database
        n = 0

        #For every instance...
        @@record_list_cross.each do |record|

          if record.Parent1 == code1 and record.Parent2 == code2

            return {
            "Parent1" => record.Parent1,
            "Parent2" => record.Parent2,
            "F2_Wild" => record.F2_Wild,
            "F2_P1" => record.F2_P1,
            "F2_P2" => record.F2_P2, 
            "F2_P1P2" => record.F2_P1P2
          }

            #Just to change the value to indicate there is no problem
            n = 1

          end

        end

        if n == 0

          abort ("\e[1;31mError. You are trying to get information or to add an instance from a record that does not exist in your HybridCross database.\e[m")
        
        end

    end


    def HybridCross.linked?
=begin
        This class method determines whether 2 genes are genetically
        linked or not.
=end

        @@linked_list = Array.new
        
        #This indicates there are not linked genes

        @@record_list_cross.each do |record|
              
          observed = [
            record.F2_Wild.to_f,
            record.F2_P1.to_f,
            record.F2_P2.to_f,
            record.F2_P1P2.to_f
          ]

          total = 0

          observed.each do |a| total+=a end

          expected = [total * 9/16, total * 3/16, total * 3/16, total * 1/16]

          sum = 0

          (0...observed.length()).each do |n|

            sum = ((observed[n] - expected[n])**2)/expected[n] + sum

          end

          #sum has to be greater than this value for the 2 genes to be linked
          if sum > 7.815 #we take into account a pvalue cutoff = 0.05

            gene_code_P1 = SeedStock.get_info(record.Parent1)["Mutant_Gene_ID"] 
            gene_code_P2 = SeedStock.get_info(record.Parent2)["Mutant_Gene_ID"]

            gene_name_P1 = Gene.get_info(gene_code_P1)["Gene_name"] 
            gene_name_P2 = Gene.get_info(gene_code_P2)["Gene_name"]

            #We get the objects of the linked genes and put them together with 
            #the name and the chi2 value into a list.
            Gene.all_instances.each do |instance|

              if instance.Gene_name == gene_name_P1

                @@linked_list << [gene_name_P2, instance, sum]

              elsif instance.Gene_ID == gene_code_P2

                @@linked_list << [gene_name_P1, instance, sum]

              end
              
            end

            puts "\n\e[1;34mRecording: #{gene_name_P1} is genetically linked to #{gene_name_P2} with chisquare score #{sum}.\n\e[m"
                    
          end
    end

    if @@linked_list.length() == 0

      puts "\e[1;34mNone of the genes are linked.\e[m"

    end 

    #We add the linked genes property in the gene objects
    @@linked_list.each do |link|

      linked_gene, gene_object, chi2 = link

      gene_object.add_linked_gene_chi2(linked_gene, chi2)

    end

    return @@linked_list

  end

  def HybridCross.final_report
=begin
      This class method prints a final report about linked genes.
=end
      puts "\e[1;32mFinal Report:"
      puts "\e[1;32m-----------------------------------------------------------------\e[m"

      gene_list = Gene.all_instances 
  
      gene_list.each do |gene|

        #linked_genes is a hash with linked_genes as keys
        gene.linked_genes.keys.each do |linked|

          puts "\e[1;32m#{gene.Gene_name} is linked to #{linked}\e[m"
              
        end

      end

      puts "\e[1;32m-----------------------------------------------------------------\e[m"

    end

end


  
