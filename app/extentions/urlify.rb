class NilClass
  def looks_like_url?() false end
end

class String
  def looks_like_url?
    !!(self.match /(^https?\:\/\/|^www\.)[^\s<]+|[^\s<]+\.(com|net|org|us|me|co|info|ws|ca|biz|me|cc|tv|asia)[^\s<]*$/)
  end

  def urlify!
    self.insert(0, 'http://') unless self.downcase.match /^http/
    self
  end
end

