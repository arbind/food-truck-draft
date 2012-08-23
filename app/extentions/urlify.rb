class String 
  def urlify!
    self.insert(0, 'http://') unless self.downcase.match /^http/
    self
  end
end
