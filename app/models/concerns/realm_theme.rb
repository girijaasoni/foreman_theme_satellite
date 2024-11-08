module RealmTheme
  extend ActiveSupport::Concern
  included do
    remove_const(:TYPES)
    const_set(:TYPES, ["Red Hat Identity Management", "Active Directory"])
    #removed validator that was using the old TYPES const
    Realm.class_eval do
      _validators.delete(:realm_type)
      _validate_callbacks.each do |callback|
        filter_method = callback.respond_to?(:raw_filter) ? :raw_filter : :filter
        if callback.send(filter_method).respond_to? :attributes
          callback.send(filter_method).attributes.delete :realm_type
        end
      end
      validates :realm_type, :presence => true, :inclusion => { :in => ["Red Hat Identity Management", "Active Directory"] }
    end
  end

end
