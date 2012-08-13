class String 
  def symbolize
    self.underscore.gsub(/[\s\-]/, '_').to_sym
  end
end

class Symbol 
  def symbolize
    self
  end
end