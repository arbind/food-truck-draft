class JobQueue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :key, type: Symbol, default: nil
  field :job, type: Hash, default: nil

  def self.service() JobQueueService.instance end

  def self.enqueue(key, job) service.enqueue end
  def self.dequeue(key) service.dequeue end

end
