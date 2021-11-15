# Class whose instances are annotations for a gene. Attributes: url address, gene ID
# and annotation. 
class Annotator

    #uso general annotator

    # @return [string] url to search
    attr_accessor :address

    # @return [string] the gene that is being annotated
    attr_accessor :Gene_ID

    # @return [list] information obtained
    attr_accessor :information

    @@all_annotations_hash = Hash.new

    def initialize (params = {})

        @address = params.fetch(:address, nil)
        @Gene_ID = params.fetch(:Gene_ID, nil)

        @information = get_info_url(@address, "json")

        @@all_annotations_hash[@Gene_ID] = self

    end


    # This class method returns all instances of the class.
    # @return [hash] all Annotator instances.
    def Annotator.all_instances

        return @@all_annotations_hash

    end

end



