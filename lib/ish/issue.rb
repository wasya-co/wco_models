
#
# Issue
# _vp_ 20171204
#
class Ish::Issue
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_issue'

  field :name

end
