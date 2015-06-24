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
      init!
    end


    def find(id)
      klass.find(id)
    rescue ActiveRecord::RecordNotFound => e
      raise Gone, id
    end


    def sample
      find(id_store.sample)
    end


    def pick
      return if rest.blank?
      find(rest.shift)
    end


    def loop
      reset! if rest.blank?
      sample
    end


    def init!
      self.id_store = klass.pluck(:id).shuffle!
      reset!
    end


    def reset!
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