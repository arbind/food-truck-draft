class TwitterService
  include Singleton
  attr_reader :twitter_client


  def self.pull(screen_name)
    begin
      tuser = Twitter.user(screen_name)
      return nil if tuser.nil?

      # create or updates the twitter presence
      twitter_presence = TwitterAccount.materialize_from_twitter(tuser.to_hash)
      # create or update the timeline
      timeline = Twitter.user_timeline(screen_name) 
      twitter_presence.update_timeline(timeline)

      return twitter_presence
    rescue Exception => e 
      puts e.message
      return nil
    end
  end

  private
  def initialize()  @twitter_client = Yelp::Client.new end

  def self.client() TwitterService.instance.twitter_client end

end