module Trajectory
  class Project
    include Virtus

    NUMBER_OF_WORKING_DAYS_BY_WEEK = 5.0

    # @private
    attr_writer :stories, :users_collection, :iterations_collection

    # @return [Integer] the unique identifier of the project.
    # @raise [MissingAttributeError] if id is nil
    attribute :id, Integer, default: lambda { |project, attribute| raise MissingAttributeError.new(project, :id) }

    # @return [String] the project name
    attribute :name, String
    # @!method archived?
    # @return [true, false] true if the project has been archived, false otherwise
    attribute :archived, Boolean
    # @return [DateTime] creation date of the project
    attribute :created_at, DateTime
    # @return [Integer] the current velocity of the project
    attribute :estimated_velocity, Integer
    # @return [Array<Integer>] the velocities of past iterations
    attribute :historic_velocity, Array[Integer]
    # @return [String] project keyword identifier
    attribute :keyword, String
    # @return [DateTime] last modification date of the project
    attribute :updated_at, DateTime
    # @return [Integer] number of completed iterations in the project
    attribute :completed_iterations_count, Integer
    # @return [Integer] number of completed stories in the project
    attribute :completed_stories_count, Integer

    # Returns true if two projects are the sames i.e they share the same id
    # attribute
    #
    # @param other [Project] the other object to compare
    # @return [true, false]
    def ==(other)
      id == other.id
    end

    # Fetch all stories that belongs to the project
    #
    # @return [Stories] the stories collection
    def stories
      @stories ||= DataStore.stories_for_project(self)
    end

    # Fetch all iterations that belongs to the project
    #
    # @return [Iterations] the iterations collection
    def iterations
      @iterations_collection ||= DataStore.iterations_for_project(self)
    end

    # Fetch all ideas that belongs to the project
    #
    # @return [Ideas] the ideas collection
    def ideas
      @ideas ||= DataStore.ideas_for_project(self)
    end

    # Fetch all users that belongs to the project
    #
    # @return [Users] the users collection
    def users
      @users_collection ||= DataStore.users_for_project(self)
    end

    # Fetch updates that belongs to the project since a given date
    #
    # @param since [DateTime] the date
    # @return [Updates] the updates collection
    def updates(since = DateTime.now)
      DataStore.updates_for_project(self, since)
    end

    # Fetch a user from the project given its id or false if it does not exist
    #
    # @return [User, false] the user or false
    def find_user_by_id(id)
      users.find_by_id(id)
    end

    # Fetch a iteration from the project given its id or false if it does not exist
    #
    # @return [Iteration, false] the iteration or false
    def find_iteration_by_id(id)
      iterations.find_by_id(id)
    end

    # Fetch the stories in a given iteration of a project
    #
    # @param iteration [Iteration] the iteration
    # @return [Stories] the user
    def stories_in_iteration(iteration)
      stories.in_iteration(iteration)
    end

    # Returns the sum of all points of each story of the project
    #
    # @return [Integer] the points accumulation
    def total_points
      stories.inject(0) do |accumulator, story|
        accumulator += story.points
      end
    end

    # Returns estimated end date of the project with the actual estimated velocity
    #
    # @return [Date] the estimated date
    def estimated_end_date
      Date.today + remaining_days
    end

    # Returns the number of needed iterations to complete the project
    #
    # @return [Integer] the number of iterations
    def remaining_iterations
      (remaining_points.to_f / estimated_velocity.to_f).ceil
    end

    # Returns the estimated number of days (weekend included) remaining before the end of the project.
    #
    # This is usefull to estimate the project end date.
    #
    # @return [Integer] the number of days
    # @raise [VelocityEqualToZeroError] if estimated velocity is equal to zero (i.e the project can't be finished because no one actually works on it)
    def remaining_days
      raise VelocityEqualToZeroError.new(self) if estimated_velocity_per_day == 0
      (remaining_points / estimated_velocity_per_day).ceil
    end

    # Returns sum of points of not completed stories
    #
    # @return [Integer] the number of points
    def remaining_points
      stories.not_completed.inject(0) do |accumulator, story|
        accumulator += story.points
      end
    end

    # Returns the estimated velocity by day over a week
    #
    # @return [Integer] the estimated velocity
    def estimated_velocity_per_day
      estimated_velocity / 7.0
    end

    # Returns the estimated number of working days (weekend excluded) remaining before the end of the project.
    #
    # This is usefull to be able to evaluate project budget as not all days are billable.
    #
    # @return [Integer] the number of days
    # @raise [VelocityEqualToZeroError] if estimated velocity is equal to zero (i.e the project can't be finished because no one actually works on it)
    def remaining_working_days
      raise VelocityEqualToZeroError.new(self) if estimated_velocity_per_working_day == 0
      (remaining_points / estimated_velocity_per_working_day).ceil
    end

    # Returns the estimated velocity by day over billable days (actually 5 days)
    #
    # @return [Integer] the estimated velocity
    def estimated_velocity_per_working_day
      estimated_velocity / NUMBER_OF_WORKING_DAYS_BY_WEEK
    end

    # Returns the completion percentage of the project
    #
    # @return [Float] the percentage
    def percent_complete
      (accepted_points.to_f / total_points * 100.0).round(1)
    end

    # Returns the sum of accepted story points
    #
    # @return [Integer] the number of points
    def accepted_points
      total_points - remaining_points
    end

    # Returns the last non null velocity of the project or raise an error if the
    # project never started
    #
    # @return [Integer] a non null velocity
    # @raise [VelocityAlwaysEqualToZero] when historic velocity was always zero
    # (i.e the project has not yet started)
    def last_non_null_velocity
      raise VelocityAlwaysEqualToZero if !has_started?
      historic_velocity.reverse.find do |velocity|
        velocity != 0
      end
    end

    # Returns true if the project has already started some development (i.e
    # stories have been accepted and a velocity has been evaluated). It returns
    # false otherwise
    #
    # @return [true, false]
    def has_started?
      historic_velocity.any? do |velocity|
        velocity != 0
      end
    end
  end
end
