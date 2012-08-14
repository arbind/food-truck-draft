module ToHash
  def to_hash
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@").symbolize] = instance_variable_get(var) }
    hash
  end  
end