
##
## 2023-03-04 _vp_ When I receive one.
##
class Office::EmailFilter
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from_regex
  field :body_regex

  KINDS = %i|
    autorespond autorespond-remind
    skip-inbox
  |;
  field :kind

end

