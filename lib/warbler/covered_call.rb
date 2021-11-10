
class Ish::CoveredCall
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'ish_covered_call'

  field :expires_on, type: Date
  validates :expires_on, presence: true
  field :n_contracts, type: Integer
  validates :n_contracts, presence: true
  field :ticker
  validates :ticker, uniqueness: { scope: :expires_on }
  validates :ticker, presence: true

  #
  # Internal, below
  #

end
