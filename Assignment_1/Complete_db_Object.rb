require './Gene_Object.rb'
require './SeedStock_Object.rb'
require './HybridCross_Object.rb'

class Database
=begin
    This class represents a the entire database. It has 3 tables: Gene, 
    SeedStock and HybridCross.
    Methods: Database.gene_load_from_file(file), Database.stock_load_from_file(file),
    Database.cross_load_from_file(file) and Database.generate_new_db_file(file).
=end

    attr_accessor :gene_file  
    attr_accessor :stock_file
    attr_accessor :cross_file
    attr_accessor :stock_header

    def initialize(params = {})
    
        @gene_file = params.fetch(:gene_file)
        @stock_file = params.fetch(:stock_file)
        @cross_file = params.fetch(:cross_file)

        Database.gene_load_from_file(@gene_file)
        Database.stock_load_from_file(@stock_file)
        Database.cross_load_from_file(@cross_file)
    end

    def Database.gene_load_from_file(file)
=begin
        This class method loads the information from a file into the database.
        param file: the file to read.
=end
      
        lines_gene = File.readlines(file).drop(1)

        lines_gene.each do |line| 
  
            line = line.split("\t") 
    
            @Gene_ID = line[0]
            @Gene_name = line[1]
            @mutant_phenotype = line[2]
  
          # We create new instances
            Gene.new(
            :Gene_ID => @Gene_ID,
            :Gene_name => @Gene_name,
            :mutant_phenotype => @mutant_phenotype
            )
  
        end

    end


    def Database.stock_load_from_file(file)
=begin
        This class method loads the information from a file into the database.
        param file: the file to read.
=end
      
        #It wil be used to write a new file
        stockfile = File.open(file, 'r')
        @stock_header = stockfile.gets   

        # We read only the lines, not the header
        lines_stock = File.readlines(file).drop(1)
      
        lines_stock.each do |line| 
      
          line = line.split("\t")
      
          @Seed_Stock = line[0]
          @Mutant_Gene_ID = line[1]
          @Last_Planted = line[2]
          @Storage = line[3]
          @Grams_Remaining = line[4]
      
          # We create new instances
          SeedStock.new(
            :Seed_Stock => @Seed_Stock,
            :Mutant_Gene_ID => @Mutant_Gene_ID,
            :Last_Planted => @Last_Planted, 
            :Storage => @Storage, 
            :Grams_Remaining => @Grams_Remaining
          )
              
        end
    end


    def Database.cross_load_from_file(file)
=begin
        This class method loads the information from a file into the database.
        param file: the file to read.
=end
      
        # We read only the lines, not the header
        lines_cross = File.readlines(file).drop(1) 
      
        lines_cross.each do |line| 
        
            line = line.split("\t")
        
            @Parent1 = line[0]
            @Parent2 = line[1]
            @F2_Wild = line[2]
            @F2_P1 = line[3]
            @F2_P2 = line[4]
            @F2_P1P2 = line[5]
        
            # We create new instances
            HybridCross.new(
              :Parent1 => @Parent1, 
              :Parent2 => @Parent2,
              :F2_Wild => @F2_Wild, 
              :F2_P1 => @F2_P1, 
              :F2_P2 => @F2_P2, 
              :F2_P1P2 => @F2_P1P2)
        
          end
    end


          def Database.generate_new_db_file(file)
=begin
              This class method generates a new database file with updated
              information after planting.
              param file: the output file.
=end
    
            File.open(file, 'w') do |f|

              f.puts @stock_header

            end

            all_stocks = SeedStock.all_instances
      
            all_stocks.each do |record|

              File.open(file, 'a') do |f|

                f.puts "#{record.Seed_Stock}\t#{record.Mutant_Gene_ID}\t#{record.Last_Planted}\t#{record.Storage}\t#{record.Grams_Remaining}"
              
              end

            end
            
          end

      end
