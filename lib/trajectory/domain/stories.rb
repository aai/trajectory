require 'delegate'

module Trajectory
  class Stories < SimpleDelegator
    alias :stories :__getobj__

    # Creates a new collection of {Stories}
    #
    # @param stories [Array<Story>] a arbitrary lenght list of {Story} objects
    def initialize(*stories)
      super(stories)
    end

    # Returns started stories of the collection
    #
    # @return [Stories] started stories collection
    def started
      stories.select(&:started?)
    end

    # Returns unstarted stories of the collection
    #
    # @return [Stories] unstarted stories collection
    def unstarted
      stories.select(&:unstarted?)
    end

    # Returns not completed stories of the collection
    #
    # @return [Stories] not completed stories collection
    def not_completed
      stories.reject(&:completed?)
    end

    # Returns stories of the collection that are in the given iteration
    #
    # @param iteration [Iteration] an iteration
    # @return [Stories] stories collection in iteration
    def in_iteration(iteration)
      stories.select do |story|
        story.in_iteration?(iteration)
      end
    end
  end
end
