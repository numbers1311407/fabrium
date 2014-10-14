module Users
  module AdminCreation
    extend ActiveSupport::Concern

    included do
      attr_writer :new_as_admin
    end

    def new_as_admin?
      !!@new_as_admin
    end

    protected

    def password_required?
      if new_record? && new_as_admin?
        false
      else
        super
      end
    end

    module ClassMethods
      def new_as_admin(attrs={})
        object = new(attrs)
        object.new_as_admin = true
        object
      end
    end
  end
end
