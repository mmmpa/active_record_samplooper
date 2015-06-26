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
      raise ActiveRecord::RecordNotFound unless id
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
      klass.find(id)
    rescue ActiveRecord::RecordNotFound => e
      raise Gone, id
    end


    def sample(count = 1)
      count > 1 ? count.times.map { do_sampling } : do_sampling
    end


    def pick(count = 1)
      count > 1 ? count.times.map { do_picking } : do_picking
    end


    def loop(count = 1)
      count > 1 ? count.times.map { do_looping } : do_looping
    end


    def init!
      self.id_store = klass.pluck(:id).shuffle!
      reset!
    end


    def reset!
      self.rest = id_store.dup.shuffle
    end


    private
    def do_sampling
      find(id_store.sample)
    end


    def do_picking
      return if rest.blank?
      find(rest.shift)
    end


    def do_looping
      reset! if rest.blank?
      pick
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
    def sample(count = 1)
      count > 1 ? count.times.map { do_sampling } : do_sampling
    end


    def sampler
      ActiveRecordSamplooper.(self)
    end

    private
    def do_sampling
      offset(rand(count(:all))).first
    end
  end
end