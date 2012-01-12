class Object
   #note: Object does not define Object#empty?
   def blank?
     respond_to?(:empty?) ? empty? : !self
   end
end

class String
  def constantize()
    camel_cased_word = self
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?
    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end
end

