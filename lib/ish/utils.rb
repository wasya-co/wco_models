
module Ish::Utils

  private

  def set_slug
    return if slug
    if name
      new_slug = name.downcase.gsub(/[^a-z0-9\s]/i, '').gsub(' ', '-')
    else
      new_slug = '1'
    end
    if self.class.where( slug: new_slug ).first
      loop do
        if new_slug[new_slug.length-1].to_i != 0
          # inrement last digit
          last_digit = new_slug[new_slug.length-1].to_i
          new_slug = "#{new_slug[0...new_slug.length-1]}#{last_digit+1}"
        else
          # add '-1' to the end
          new_slug = "#{new_slug}-1"
        end
        break if !self.class.where( slug: new_slug ).first
      end
    end
    self.slug = new_slug
  end

end
