module ActiveRecordSamplooper
  class << self
    def call(*args)
      ready(*args)
    end


    def ready(klass)
      Samplooper.new(klass)
    end
  end


  class Samplooper
    attr_accessor :klass, :id_store, :rest


    def initialize(klass)
      self.klass = klass
      reset!
    end


    def sample
      return if rest.blank?
      klass.find(id = rest.shift)
    rescue ActiveRecord::RecordNotFound => e
      raise Gone, id
    end


    def loop
      reset! if rest.blank?
      sample
    end


    def reset!
      self.id_store = klass.pluck(:id).shuffle!
      self.rest = id_store.dup
    end
  end

  class Gone < StandardError
    attr_accessor :id


    def initialize(id)
      self.id = id
    end
  end
end

class ::ActiveRecord::Base
  class << self
    def sample
      offset(rand(count)).first
    end


    def sampler
      ActiveRecordSamplooper.(self)
    end
  end
end