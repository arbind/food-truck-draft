class JobQueueService
  include Singleton  

  def enqueue(key, job)
    JobQueue.create(key: key.symbolize, job: job)
  end

  def dequeue(key)
    JobQueue.where(key: key.symbolize).asc(:created_at).limit(1).first
  end

end
