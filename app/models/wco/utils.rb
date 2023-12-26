
module Wco::Utils

  def export
    out = {}
    %w| created_at updated_at |.map do |f|
      out[f] = send(f)
    end
    export_fields.map do |field|
      if field[-3..-1] == '_id'
        out[field] = send(field).to_s
      else
        out[field] = send(field)
      end
    end
    out[:_id] = id.to_s
    out.with_indifferent_access
  end

  private

  def set_slug
    return if !slug.blank?
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
