class Util
  @@number_helper = Object.new.extend(ActionView::Helpers::NumberHelper)
  @@text_helper = Object.new.extend(ActionView::Helpers::TextHelper)
  @@date_helper = Object.new.extend(ActionView::Helpers::DateHelper)

  # rylyz utils

  def self.normalized_time(time_data)
    # http://jigyasamakkar.com/ruby-on-rails-views-time-ago-in-words-for-string-time/
    time = time_data
    time = time_data.to_time if time_data.kind_of? String # convert string to time if needed
    time = time + (-Time.zone_offset(Time.now.zone))
  end
  
  def self.how_long_ago_was(time_data)
    time = normalized_time(time_data)
    "#{time_ago_in_words(time)} ago"
  end    

  def self.how_long_from(time_data)
    time = normalized_time(time_data)
    distance_of_time_in_words_to_now(time)
  end    

  def self.create_key(*tokens) tokens.join('.') end

  # ActionView::Helpers::NumberHelper utils

  def self.short_human_number(number)
    return '' if number.nil? or "#{number}".empty?

    short = number_to_human(number)
    return '' if short.nil? or short.empty? 

    tokens = short.split(' ')
    return short if 1==tokens.size
    tokens[1] = tokens[1].slice(0)
    tokens[1] = 'K' if tokens[1].eql? 'T' # Convert Thousand to K
    tokens.join
  end

  def self.percentage(decimal, precision=0) @@number_helper.number_to_percentage(100*decimal, precision: precision) end
  def self.number_to_currency(*args) @@number_helper.number_to_currency(*args) end
  def self.number_to_human(*args) @@number_helper.number_to_human(*args) end
  def self.number_to_human_size(*args) @@number_helper.number_to_human_size(*args) end
  def self.number_to_percentage(*args) @@number_helper.number_to_percentage(*args) end
  def self.number_to_phone(*args) @@number_helper.number_to_phone(*args) end
  def self.number_with_delimiter(*args) @@number_helper.number_with_delimiter(*args) end
  def self.number_with_precision(*args) @@number_helper.number_with_precision(*args) end

  # ActionView::Helpers::TextHelper utils
  def self.concat(*args) @@text_helper.concat(*args) end
  def self.current_cycle(*args) @@text_helper.current_cycle(*args) end
  def self.cycle(*args) @@text_helper.cycle(*args) end
  def self.excerpt(*args) @@text_helper.excerpt(*args) end
  def self.highlight(*args) @@text_helper.highlight(*args) end
  def self.pluralize(*args) @@text_helper.pluralize(*args) end
  def self.reset_cycle(*args) @@text_helper.reset_cycle(*args) end
  def self.safe_concat(*args) @@text_helper.safe_concat(*args) end
  def self.simple_format(*args) @@text_helper.simple_format(*args) end
  def self.truncate(*args) @@text_helper.truncate(*args) end
  def self.word_wrap(*args) @@text_helper.word_wrap(*args) end

  # ActionView::Helpers::DateHelper utils
  def self.date_select(*args) @@date_helper.date_select(*args) end
  def self.datetime_select(*args) @@date_helper.datetime_select(*args) end
  def self.distance_of_time_in_words(*args) @@date_helper.distance_of_time_in_words(*args) end
  def self.distance_of_time_in_words_to_now(*args) @@date_helper.distance_of_time_in_words_to_now(*args) end
  def self.select_date(*args) @@date_helper.select_date(*args) end
  def self.select_datetime(*args) @@date_helper.select_datetime(*args) end
  def self.select_day(*args) @@date_helper.select_day(*args) end
  def self.select_hour(*args) @@date_helper.select_hour(*args) end
  def self.select_minute(*args) @@date_helper.select_minute(*args) end
  def self.select_month(*args) @@date_helper.select_month(*args) end
  def self.select_second(*args) @@date_helper.select_second(*args) end
  def self.select_time(*args) @@date_helper.select_time(*args) end
  def self.select_year(*args) @@date_helper.select_year(*args) end
  def self.time_ago_in_words(*args) @@date_helper.time_ago_in_words(*args) end
  def self.time_select(*args) @@date_helper.time_select(*args) end
  def self.time_tag(*args) @@date_helper.time_tag(*args) end

end
