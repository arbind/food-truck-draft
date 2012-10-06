class String

  def integer?
    return true if self =~ /^\d+$/
  end

  def number?
    return true if integer?
    true if Float(self) rescue false
  end

end
