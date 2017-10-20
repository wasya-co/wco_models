
module Ish
  class GalleryName
    include Mongoid::Document
    include Mongoid::Timestamps
    field :text
    embedded_in :gallery
  end
end

