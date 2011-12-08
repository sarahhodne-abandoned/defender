module Defender
  # Public: This is the main module you'll be working with most of the time.
  # This should be included in your ActiveModel class, not called standalone.
  # Defender requires you to have a before_create callback.
  #
  # Examples
  #
  #   class Comment < ActiveRecord::Base
  #     include Defender::Model
  #   end
  module Model
    # Internal: This is used for the magical attribute mapping.
    DEFAULT_DEFENDER_MAPPINGS = {
      content: [:content, :body],
      author_email: [:author_email, :email, { author: :email }]
    }.freeze

    module ClassMethods
    end

    module InstanceMethods
      # Public: Return the data to send to Defensio. If the default mappings
      # don't work for your model, override this.
      #
      # See the README for all the valid keys of the object that is returned.
      #
      # Examples
      #
      #   class Comment < ActiveRecord::Base
      #     include Defender::Model
      #
      #     def defender_data
      #       data = super
      #       data[:content] = self.my_nonstandard_content_attribute
      #     end
      #   end
      #
      # Returns any object that responds to #[] and #[]=. The object has to
      #   return a value for #[:content].
      def defender_data
        data = {}
        DEFAULT_DEFENDER_MAPPINGS.each do |defender, model|
          data[defender] = defender_pick_attribute(model)
        end

        data
      end

      private

      # Internal: Pick an attribute that exists on the model in a list of
      # attributes, and return the value of that attribute.
      #
      # names  - A Symbol, Array of Symbols or a Hash representing the attribute
      #          name(s). Use a Hash for associations (see examples).
      # object - The object to find the attribute on. Defaults to self.
      #
      # Examples
      #
      #   class Comment < ActiveRecord::Base
      #     include Defender::Model
      #
      #     belongs_to :author
      #
      #     def defender_data
      #       # The two following lines are equivalent.
      #       { author_email: defender_pick_attribute({ author: :email }) }
      #       { author_email: self.author.email }
      #     end
      #   end
      #
      # Returns the value of value of the first attribute that exists.
      def defender_pick_attribute(names, object=nil)
        object ||= self

        [names].flatten.each do |attribute_name|
          if attribute_name.respond_to?(:to_sym)
            return object.send(attribute_name.to_sym) if object.respond_to?(attribute_name.to_sym)
          elsif attribute_name.respond_to?(:to_hash)
            attribute_name.to_hash.each do |association, association_names|
              next unless self.respond_to?(association)
              val = defender_pick_attribute(association_names, self.send(association))
              return val if val
            end
          end
        end
      end
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
  end
end

