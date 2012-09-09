module Merge
  def merge!(from_source)
    from_source.instance_variables.each do |var| 
      self.instance_variable_set(var.symbolize, from_source.instance_variable_get(var.symbolize) )
    end
    self
  end

  def merge(from_source)
    clone = self.clone
    clone.merge!(from_source)
    clone
  end
  
end
