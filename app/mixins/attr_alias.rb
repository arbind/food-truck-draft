module AttrAlias
  def attr_alias(new_attr, original)
    alias_method(new_attr, original) if method_defined? original
    alias_method("#{new_attr}=", "#{original}=") if method_defined? "#{original}="
  end
end