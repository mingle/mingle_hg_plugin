# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

# strip_on_write
class ActiveRecord::Base
  class << self
    def strip_on_write(options={})
      return if instance_methods.include?("write_attribute_with_strip")
      exceptions = options[:except] || []
      self.send(:define_method, :should_strip?, lambda do |attribute_name|
        !(options[:except] || []).include?(attribute_name.to_sym)
      end)
      
      self.send(:define_method, :write_attribute_with_strip, lambda do |attribute_name, value|
        if should_strip?(attribute_name) && value.respond_to?(:trim)
          value = value.trim
        end
        write_attribute_without_strip(attribute_name, value)
      end)
      
      alias_method_chain :write_attribute, :strip
    end
  end  
end

# attributes_patch
module ActiveRecord
  class Base
    
    def attributes=(new_attributes, guard_protected_attributes = true)
      return if new_attributes.nil?
      attributes = new_attributes.dup
      attributes.stringify_keys!
      
      multi_parameter_attributes = []
      attributes = remove_attributes_protected_from_mass_assignment(attributes) if guard_protected_attributes
      
      attributes.each do |k, v|
        if k.include?("(")
          multi_parameter_attributes << [ k, v ]
        else
          # next line is the patched one -- we no longer raise UnknownAttributeError
          send(:"#{k}=", v)
        end
      end
      
      assign_multiparameter_attributes(multi_parameter_attributes)
    end
    
  end
end