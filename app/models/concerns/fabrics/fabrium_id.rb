module Fabrics::FabriumId
  extend ActiveSupport::Concern

  FABRIUM_ID_SEQ = "fabrics_fabrium_id_seq"
  FABRIUM_ID_START = 1001

  included do
    before_create :assign_fabrium_id
  end

  module ClassMethods
    def next_fabrium_id
      result = connection.execute "SELECT nextval('#{FABRIUM_ID_SEQ}')"
      result[0]['nextval']
    end
  end

  protected

  def assign_fabrium_id
    self.fabrium_id = self.class.next_fabrium_id
  end
end
