module ActiveRecordSamplooper
  class << self
    def call(*args)
      ready(*args)
    end


    def ready(klass)
      Samplooper.new(klass)
    end
  end

  class ArrayLooper
    attr_accessor :array


    class << self
      def call(*args)
        new(*args)
      end
    end


    def initialize(array)
      self.array = array.dup
    end


    def find(id)
      array[id - 1] || raise(Gone, id)
    end


    def pluck(*)
      (1..array.size).to_a
    end
  end

  class Samplooper
    attr_accessor :klass, :id_store, :rest


    def initialize(klass)
      self.klass = klass
      init!
    end


    def find(id)
      raise Gone, id unless id
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

class ::Array
  def sampler
    ActiveRecordSamplooper.(ActiveRecordSamplooper::ArrayLooper.(self))
  end
end


class ::ActiveRecord::Base
  class << self
    def sample
      offset(rand(count(:all))).first
    end


    def sampler
      ActiveRecordSamplooper.(self)
    end
  end
end