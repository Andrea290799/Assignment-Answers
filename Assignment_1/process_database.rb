require './Complete_db_Object.rb'

# FUNCTIONS ############################################################################
def help
    """This function print a help message if needed"""
    if ARGV[0] == "-h" || ARGV[0] == "-help"
        abort(
            "\n\t\tThis script generates a database with the information present in the
                input files. It also allows to introduce data manually.
                It simulates planting 7 grams of seeds of the ones present in the
                database. It is also able to determine if 2 genes are genetically
                linked.
                --------------------------------------------------------------------
                USAGE
                ruby ./process_database.rb gene_information_file seed_stock_data_file
                cross_data_file
                --------------------------------------------------------------------\n")
        end
    end

    def check_format(file, identifier)
        """This function checks whether the given file has the correct format.
        param file: input file
        param identifier: regular expression to search in the file. It must be
        between '/'."""

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


## CODE ############################################################################

help

check_format(ARGV[0], /Gene_ID/)
check_format(ARGV[1], /Seed_Stock/)
check_format(ARGV[2], /Parent1/)

#Information from the files is introduced into the database
Database.new(
    :gene_file => ARGV[0],
    :stock_file => ARGV[1],
    :cross_file => ARGV[2])

#Asked tasks
SeedStock.planting(7)
Database.generate_new_db_file("new_stock.tsv") 
linked_genes = HybridCross.linked?
HybridCross.final_report 

#From here on I recommend to comment and decomment the code with "#"
#new_gene = Gene.new(:Gene_ID => "some_ID", :Gene_name => "some_name",
    #:mutant_phenotype => "some_phenotype") 

## Different tests for the code to demonstrate that the functions really work #################################################################

##GENE CLASS -----------------------------------------------------------------------
#BEFORE MANUALLY ADDING A NEW INSTANCE
#gene_list = Gene.all_instances   
#gene_list.each do |a|
    #puts a.Gene_ID #a.whatever_gen_propertie
#end
#puts Gene.get_info("AT1G69120")["Gene_name"] #Gene.get_info("AT code")["whatever_gene_propertie"]

#AFTER MANUALLY ADDING A NEW INSTANCE
#new_gene = Gene.new(:Gene_ID => "AT5G12345", :Gene_name => "some_name",
    #:mutant_phenotype => "some_phenotype")


#gene_list = Gene.all_instances 

#gene_list.each do |a|
#    puts a.Gene_ID
#end
#puts Gene.get_info("AT5G12345")


##SEEDSTOCK CLASS ------------------------------------------------------------------
#BEFORE MANUALLY ADDING A NEW INSTANCE
#stock_list = SeedStock.all_instances   
#stock_list.each do |a|
#    puts a.Last_Planted
#end
#puts SeedStock.get_info("A334")["Storage"]

#AFTER MANUALLY ADDING A NEW INSTANCE
#new_gene = Gene.new(:Gene_ID => "AT5G12345", :Gene_name => "some_name",
#    :mutant_phenotype => "some_phenotype")
#new_stock =  SeedStock.new(:Seed_Stock => "A123", :Mutant_Gene_ID => "AT5G12345",
#  :Last_Planted => "some_date", :Storage => "some_place", :Grams_Remaining => 22)

#gene_list = SeedStock.all_instances 
#gene_list.each do |a|
#    puts a.Mutant_Gene_ID
#end
#puts SeedStock.get_info("A123")["Grams_Remaining"]

#SeedStock.planting(7)
#Database.generate_new_db_file("new_stock_test.tsv") 

##HYBRIDCROSS CLASS ------------------------------------------------------------------
#BEFORE MANUALLY ADDING A NEW INSTANCE
#cross_list = HybridCross.all_instances   
#cross_list.each do |a|
#    puts a.Parent1
#end
#puts HybridCross.get_info("A334", "A348")["F2_Wild"]

#AFTER MANUALLY ADDING A NEW INSTANCE
#new_gene = Gene.new(:Gene_ID => "AT5G12345", :Gene_name => "some_name",
    #:mutant_phenotype => "some_phenotype")
#new_stock =  SeedStock.new(:Seed_Stock => "A123", :Mutant_Gene_ID => "AT5G12345",
  #:Last_Planted => "some_date", :Storage => "some_place", :Grams_Remaining => 22)
#new_cross = HybridCross.new(:Parent1 => "A123", :Parent2 => "B52",
  #:F2_Wild => 152, :F2_P1 => 26, :F2_P2 => 22, :F2_P1P2 => 2)

  #HybridCross.linked?
  #HybridCross.final_report 

#cross_list = HybridCross.all_instances 
#cross_list.each do |a|
#    puts a.Parent1
#end
#puts HybridCross.get_info("A123", "B52")["F2_Wild"]

#HybridCross.linked?
#HybridCross.final_report 