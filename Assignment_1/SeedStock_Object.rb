
class SeedStock 
=begin
    This class represents a SeedStock table of the database. It has information
    about different fields as Seed_Stock, Mutant_Gene_ID, Last_Planted, Storage and
    Grams_remaining.
    Methods: SeedStock.all_instances, SeedStock.get_info(code) and SeedStock.planting.
=end

    # This class variable will contain the different instances with the file information
    @@record_list_stock = Array.new

    attr_accessor :Seed_Stock  
    attr_accessor :Mutant_Gene_ID
    attr_accessor :Last_Planted
    attr_accessor :Storage
    attr_accessor :Grams_Remaining

    def initialize (params = {})

        @Seed_Stock = params.fetch(:Seed_Stock, nil)
        @Mutant_Gene_ID = params.fetch(:Mutant_Gene_ID, nil)
        @Last_Planted = params.fetch(:Last_Planted, nil)
        @Storage = params.fetch(:Storage, nil)
        @Grams_Remaining = params.fetch(:Grams_Remaining, nil)
        
        # We get rid off the empty fields
        if @Seed_Stock.nil? or @Mutant_Gene_ID.nil? or @Last_Planted.nil? or @Storage.nil? or @Grams_Remaining.nil?
          
          abort("\e[1;31mThere are empty fields. Please fill in the following missing fields: Seed_Stock, Mutant_Gene_ID, Last_Planted, Storage and Grams_Remaining.\e[m")
        
        end

        #Now we make sure we are introducing registered genes
        @Mutant_Gene_ID = Gene.get_info(@Mutant_Gene_ID)["Gene_ID"]

        @@record_list_stock << self

    end

    def SeedStock.all_instances
=begin
        This class method returns all instances of the class.
        return @@record_list_stock: list that contains all the instances.
=end
        return  @@record_list_stock
    end

    def SeedStock.get_info(code)
=begin
        This class method gets information related to a Seed_Stock code.
        param code: Seed_Stock we want to get information from.
        return hash: information of the instance.
=end

        # n equals zero when the introduced code is not in the database
        n = 0

        #For every instance...
        @@record_list_stock.each do |record|

          if record.Seed_Stock == code

            return {
              "Seed_Stock" => record.Seed_Stock,
              "Mutant_Gene_ID" => record.Mutant_Gene_ID,
              "Last_Planted" => record.Last_Planted,
              "Storage" =>record.Storage,
              "Grams_Remaining" => record.Grams_Remaining
            }

            #Just to change the value to indicate there is no problem
            n = 1

          end

        end

        if n == 0

          abort ("\e[1;31mError. You are trying to get information or to add an instance  from a record that does not exist in your SeedStock data base.\e[m")

        end
    end

    def SeedStock.planting(n)
=begin
        This class method simulates to plant n grams of seeds from SeedStock
        database.
        param n: number of seeds.
=end

        #For every instance...
        @@record_list_stock.each do |record|

          subtraction = record.Grams_Remaining.to_i - n

          if subtraction > 0

            record.Grams_Remaining = subtraction

          elsif subtraction == 0

            record.Grams_Remaining = subtraction
            puts "\e[1;33mWARNING: we have run out of Seed Stock #{record.Seed_Stock}.\e[m"

          else

            puts "\e[1;33mWARNING: we have run out of Seed Stock #{record.Seed_Stock} before planting the requiered amount of seeds. Planted grams: #{record.Grams_Remaining}\e[m"
            record.Grams_Remaining = 0
            
          end

      end

  end

end