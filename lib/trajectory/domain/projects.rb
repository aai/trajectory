require 'delegate'

module Trajectory
  class Projects < SimpleDelegator
    alias :projects :__getobj__

    # Creates a new collection of {Projects}
    #
    # @param projects [Array<Project>] a arbitrary lenght list of {Project} objects
    def initialize(*projects)
      super(projects)
    end

    # Create a new collection of {Project} from a JSON array of attributes from trajectory API
    #
    # @param json_attributes [Hash] the hash of attributes of each project of the collection
    def self.from_json(json_attributes)
      new(*json_attributes.map do |attributes|
        Project.new(attributes.symbolize_keys!)
      end)
    end

    # Fetch the project with the given id in the collection. If it is not found,
    # it returns false
    #
    # @param id [Integer] the project id
    # @return [Project, false] the found project or false
    def find_by_id(id)
      projects.find { |project| project.id == id } || false
    end

    # Fetch the project with the given keyword in the collection. If it is not found,
    # it returns false
    #
    # @param keyword [String] the project keyword
    # @return [Project, false] the found project or false
    def find_by_keyword(keyword)
      projects.find { |project| project.keyword == keyword } || false
    end

    # Returns the archived projects of the collection
    #
    # @return [Projects] the filtered collection
    def archived
      projects.select { |project| project.archived? }
    end

    # Returns the active projects of the collection
    #
    # @return [Projects] the filtered collection
    def active
      projects.select { |project| !project.archived? }
    end
  end
end
