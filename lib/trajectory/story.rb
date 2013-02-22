module Trajectory
  class Story
    include Virtus

    attribute :id, Integer, default: lambda { |project, attribute| raise MissingAttributeError.new(project, :id) }
    attribute :assignee_name, String
    attribute :task_type, String
    attribute :position, Integer
    attribute :created_at, DateTime
    attribute :state_events, Array[String]
    attribute :title, String
    attribute :design_needed, Boolean
    attribute :updated_at, DateTime
    attribute :idea_subject, String
    attribute :archived, Boolean
    attribute :points, Integer
    attribute :development_needed, Boolean
    attribute :deleted, Boolean
    attribute :user_name, String
    attribute :comments_count, Integer
    attribute :state, Symbol
    attribute :project_id, Integer

    def ==(other)
      id == other.id
    end

    def project
      DataStore.find_project_by_id(project_id)
    end

    def started?
      state == :started
    end
  end
end
