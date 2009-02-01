class Module
  def bool_reader(*attrs)
    attrs.each do |attr|
      attr_reader attr
      define_method("#{attr}?") do
        !!send(attr)
      end
    end
  end
  
  def bool_accessor(*attrs)
    attrs.each do |attr|
      attr_writer(attr)
      bool_reader(attr)
    end
  end

  def instance_class_methods(*method_names)
    method_names.each do |method_name|
      define_method(method_name) do
        self.class.send(method_name)
      end
    end
  end

  def inheritable_class_attr(attribute, &block)
    accessor = "_#{attribute}"
    meta_def attribute do |*args|
      if args.empty?
        send(accessor)
      else
        meta_def accessor do
          block ? block.call(args.first) : args.first
        end
      end
    end
  end

  def subfield_accessors(field, subfields)
    subfields.each do |subfield, index|
      define_method(subfield) do 
        self.send(field)[index]
      end
      
      define_method("#{subfield}=") do |value|
        self.send(field)[index] = value
      end
    end
  end

  def mapped_accessor(field, mapped_field, mapping)
    reverse_mapping = mapping.invert

    attr_accessor(field) if not respond_to?(field)

    meta_def("#{field}_to_#{mapped_field}") do |value|
      mapping[value]
    end

    meta_def("#{mapped_field}_to_#{field}") do |value|
      reverse_mapping[value]
    end

    define_method(mapped_field) do
      mapping[send(field)]
    end

    define_method("#{mapped_field}=") do |value|
      send("#{field}=", reverse_mapping[value])
    end
  end

end

class Object
  ## Taken from http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  # The hidden singleton lurks behind everyone
  def metaclass; class << self; self; end; end
  def meta_eval &blk; metaclass.instance_eval &blk; end

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end
  
  # Defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
  ##
end
