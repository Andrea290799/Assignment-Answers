require 'bio'
require 'stringio'
require './Functions'

create_blast_db(ARGV[0], "DB1")
create_blast_db(ARGV[1], "DB2")

dbs = prepare_blast(get_file_type(ARGV[0]), get_file_type(ARGV[1]))

File.open("Report.txt", "w") do |file|
    file.puts "Protein 1\tProtein 2"
end

reciprocal_blast(ARGV[0], ARGV[1], dbs[0], dbs[1])