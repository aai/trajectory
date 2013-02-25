module Trajectory
  module DataStore
    extend self

    def projects
      @projects ||= Projects.new(*Api.projects.map do |project|
        Project.new(project.symbolize_keys!)
      end)
    end

    def stories_for_project(project)
      Stories.new(*Api.stories_for_project(project).map do |story|
        attributes = story.symbolize_keys!.merge({project_id: project.id})
        Story.new(attributes)
      end)
    end

    def find_project_by_id(id)
      projects.find_by_id(id)
    end
  end
end