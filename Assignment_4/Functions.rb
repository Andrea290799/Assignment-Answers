# This function prints a help message if needed.
def help

    if ARGV[0] == "-h" || ARGV[0] == "-help"
        abort(
            "\n\t\tThis script gets the two files given by arguments and makes
            a reciprocal blast search between them, taking into account the evalue
            and coverage indicated.  
            --------------------------------------------------------------------
                USAGE
                ruby ./main file1 file2 coverage evalue
            --------------------------------------------------------------------\n")
    end
end

# This function gets the file type (prot or nucl) and checks if the file exists
# @param file [string] the file you want to know the type of
# @return [string] the file type: nucl or prot
def get_file_type(file)

    if File.file?(file) == true
    
        lines_gene = File.readlines(file)
                
        if lines_gene[1] =~ /M/

            file_type = "prot" #all proteins starts with M

        else 
            file_type = "nucl"
        end
           
    else 

        abort("\e[1;31mSorry, the #{file} file does not exist.\e[m")

    end

    return(file_type)

end


# This function gets coverage and evalue cutoffs. If they are not given in the arguments, 
# it gets a default value.
# @return [list] list containing coverage and evalue values
def get_ev_cov_cutoffs
    
    if not ARGV[2].nil?

        if ARGV[2] =~ /^\d+\.{0,1}\d*$/
            cov = ARGV[2].to_f
        else
            cov = 0.5
        end

    else
        cov = 0.5
    end

    if not ARGV[3].nil? 

        if ARGV[3] =~ /^\d+\.{0,1}\d*$/
            evalue = ARGV[3].to_f
        else 
            evalue = 10**-6
        end

    else
        evalue = 10**-6
    end

    return([cov, evalue])

end

# This function creates a Blast database given a file and the database name
# @param file [string] the file you want to create de database of
# @param db_name [string] the name of the created database
def create_blast_db(file, db_name)
    file_type = get_file_type(file)
    to_system = "makeblastdb -in #{file} -dbtype #{file_type} -out #{db_name}"
    system(to_system)
end

# This function define the kind of blast to do depending on the type of the database files
# @param file_1_type [string] file type of one of the files
# @param file_2_type [string] file type of one of the files
# @return [list] list with the prepared blast databases

def prepare_blast(file_1_type, file_2_type)

    if file_1_type == "prot" and file_2_type == "prot"
        db1 = Bio::Blast.local('blastp', 'DB1') 
        db2 = Bio::Blast.local('blastp', 'DB2') 

    elsif file_1_type == "nucl" and file_2_type == "nucl"
        db1 = Bio::Blast.local('blastn', 'DB1') 
        db2 = Bio::Blast.local('blastn', 'DB2')

    elsif file_1_type == "nucl" and file_2_type == "prot"
        db1 = Bio::Blast.local('tblastn', 'DB1') 
        db2 = Bio::Blast.local('blastx', 'DB2')
        
    elsif file_1_type == "prot" and file_2_type == "nucl"
        db1 = Bio::Blast.local('blastx', 'DB1') 
        db2 = Bio::Blast.local('tblastn', 'DB2')
    end

    return([db1, db2])
end

#Function that do a reciprocal blast search.
# @param file1 [string] a file to get the sequences.
# @param file2 [string] a file to get the sequences.
# @param db1 [string] a database to do the blast search. Contains the sequences in file1
# @param db2 [string] a database to do the blast search. Contains the sequences in file2
def reciprocal_blast(file1, file2, db1, db2)

    orthologs = []

    cov_cutoff = get_ev_cov_cutoffs[0]
    evalue_cutoff = get_ev_cov_cutoffs[1]

    Bio::FlatFile.open(Bio::FastaFormat, file1) do |fasta|

        fasta.each do |entry|
    
            report = db2.query(entry)
    
            next if report.hits[0].nil?
    
            # we get the gene IDs of the query and the first hit
            candidate_def = report.hits[0].target_def 
            query_def = report.query_def.to_s
    
            regexp = Regexp.new(/(\w+\.\w+)|/) 
    
            query_ID_1 = query_def.match(regexp)[1]
            hit_ID_1 = candidate_def.match(regexp)[1] 
    
            if hit_ID_1
    
                ev = report.hits[0].evalue 
    
                cov = (report.hits[0].query_end.to_f - report.hits[0].query_start.to_f + 1) / report.query_len.to_f
                
                # we apply the filters
                if  ev <= evalue_cutoff and cov >= cov_cutoff
    
                    Bio::FlatFile.open(Bio::FastaFormat, file2) do |fasta2|
    
                        fasta2.each do |entry2|
    
                            query_ID_2 = entry2.entry_id.match(regexp)[1]
    
                            if hit_ID_1 == query_ID_2
    
                                report2 = db1.query(entry2)
    
                                next if report2.hits[0].nil?
    
                                result = report2.hits[0].target_def 
    
                                hit_ID_2 = result.match(regexp)[1]

                                ev = report2.hits[0].evalue 
    
                                cov = (report2.hits[0].query_end.to_f - report2.hits[0].query_start.to_f + 1) / report2.query_len.to_f

                                if hit_ID_2 == query_ID_1 and ev <= evalue_cutoff and cov >= cov_cutoff

                                    match = regexp.match(result)
    
                                    orthologs = [entry2.entry_id, match]
    
                                    File.open("Report.txt", "a") do |file|
                                        file.puts "#{orthologs[0]}\t#{orthologs[1]}"
                                    end
                                end    
                            end
                        end
                    end
                end
            end
        end
    end
end

