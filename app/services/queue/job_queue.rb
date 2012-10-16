class JobQueue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :key, type: Symbol, default: nil
  field :uid, default: nil
  field :job, type: Hash, default: nil

  def self.service() JobQueueService.instance end

  def self.enqueue(key, uid, job) service.enqueue(key, uid, job) end
  def self.dequeue(key) service.dequeue(key) end
  def self.peek(key) service.peek(key) end

end
