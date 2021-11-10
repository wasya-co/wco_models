
## THIS IS TRASH. I copy-paste repetitively instead!

## aka: Ish::Shareable
## adds is_public (default true) and #shared_profiles, inverse :shared_items ???
module Ish::Nonpublic

  def self.included base
    base.send :field, :is_public, type: Boolean, default: true
    base.send :has_and_belongs_to_many, :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_markers
  end

end
