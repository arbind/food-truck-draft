class JobQueueService
  include Singleton  

  def enqueue(key, job)
    JobQueue.create(key: key.symbolize, job: job)
  end

  def dequeue(key)
    entry = JobQueue.where(key: key.symbolize).asc(:created_at).limit(1).first
    return nil if entry.nil?
    entry.delete
    entry.job
  end

  def peek(key)
    entry = JobQueue.where(key: key.symbolize).asc(:created_at).limit(1).first
    return nil if entry.nil?
    entry.job
  end

end
