require './Annotation_Object'
require './Functions.rb'
require './Gene_Object.rb'
require './Network_Object.rb'
require 'json'
require 'rest-client'


help

check_format(ARGV[0], /^[A-a][T-t][0-9][G-g][0-9]{5}/)

Gene.load_from_file(ARGV[0])

Gene.get_url_information

Gene.generate_direct_interactions_dictionary

Gene.generate_indirect_interactions_dictionary

networks = Gene.generate_networks

Network.load_from_list(networks)

Network.create_report

File.delete('Interactions.tsv')
