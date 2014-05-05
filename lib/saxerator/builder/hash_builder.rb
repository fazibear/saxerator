module Saxerator
  module Builder
    class HashBuilder
      attr_reader :name

      def initialize(config, name, attributes)
        @config = config
        @name = config.generate_key_for(name)
        @attributes = attributes
        @children = []
        @text = false
      end

      def add_node(node)
        @text = true if node.is_a? String
        @children << node
      end

      def to_empty_element
        EmptyElement.new(@name, @attributes)
      end

      def to_s
        StringElement.new(@children.join, @name, @attributes)
      end

      def to_hash
        hash = HashElement.new(@name, @attributes)

        if @text
          add_to_hash_element(hash, '__content__', @children.join)
        else
          @children.each do |child|
            name = child.name
            element = child.block_variable

            add_to_hash_element(hash, name, element)
          end
        end

        if @config.put_attributes_in_hash?
          @attributes.each do |attribute|
            attribute.each_slice(2) do |name, element|
              add_to_hash_element(hash, name, element)
            end
          end
        end

        hash
      end

      def add_to_hash_element( hash, name, element)
        name = @config.generate_key_for(name)
        if hash[name]
          if !hash[name].is_a?(Array)
            hash[name] = ArrayElement[hash[name]]
            hash[name].name = name
          end
          hash[name] << element
        else
          hash[name] = element
        end
      end

      def block_variable
        return to_s if @text && !@config.represent_strings_as_hash?
        return to_hash if @children.count > 0
        to_empty_element
      end
    end
  end
end
