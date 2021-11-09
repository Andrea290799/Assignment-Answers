class Annotator

    #uso general annotator

    attr_accessor :address
    attr_accessor :Gene_ID
    attr_accessor :information

    @@all_annotations_hash = Hash.new

    def initialize (params = {})

        @address = params.fetch(:address, nil)
        @Gene_ID = params.fetch(:Gene_ID, nil)

        @information = get_info_url(@address, "json")

        @@all_annotations_hash[@Gene_ID] = self

    end

    def Annotator.all_instances
=begin
        This class method returns all instances of the class.
        return @@all_annotations_hash: list that contains all the instances.
=end
        return @@all_annotations_hash
    end
end



