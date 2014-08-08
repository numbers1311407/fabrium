module HasState
  extend ActiveSupport::Concern

  module ClassMethods
    def define_states *args
      enum state: args

      # overwrite the state getter to return a comparable
      # state object
      define_method :state do
        super() && State.new(super(), self)
      end
    end

    def state(*args)
      options = args.extract_options!
      val = args.map {|arg| states[arg] }.compact
      return none if val.empty?
      val = val.first if val.length == 1
      conditions = {state: val}
      options[:negate] ? where.not(conditions) : where(conditions)
    end

    def not_state(*args)
      state(*args, negate: true)
    end
  end

  def bump_state
    current = read_attribute(:state)
    self.state = current + 1
  rescue
    false
  end

  def states
    self.class.states
  end

  protected

  def method_missing(method_name, *args, &block)
    if method_name =~ /transitioning_from_(.+)_to_(.+)\?/
      # The `persisted?` is a little odd here but the way things work,
      # we're never transitioning new records.  
      return persisted? && state_changed? &&
             states[$1.to_sym] && states[$2.to_sym] &&
             state_was == $1 && state == $2
    else
      super
    end
  end

  class State < String
    include Comparable

    def initialize(str, model)
      super(str)
      @model = model
    end

    def <=>(other)
      step = @model.states[self]
      other_step = @model.states[other] || -1
      step <=> other_step
    end
  end
end
