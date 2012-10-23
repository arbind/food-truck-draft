class Speed
  @@depth = 0
  SQUIGLES = "~~~~~~~~"

  def self.of(tag='timed', threshhold=0, &blk)
      @@depth = @@depth + 1

      start_time = Time.now
    result = yield
      done_time = Time.now

      duration = 1000 * (done_time - start_time) # convert seconds to ms

    return result if duration < threshhold

      indent = "" << SQUIGLES
      # (2*@@depth).times { indent << "~~" }
      @@depth = @@depth - 1

      duration = duration.to_i
      puts "#{indent}[ #{duration}ms #{tag} ] #{SQUIGLES}#{SQUIGLES}#{SQUIGLES}#{SQUIGLES}"
    result
  end

end