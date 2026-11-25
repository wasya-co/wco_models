
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

  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def list
      [[nil,nil]] + all.map { |a| [ a, a.id ] }
    end
  end

  def self.voice_to_avatar(which)
    case which
    when 'af_jessica'
      return 'brunette'
    when 'am_fernir'
      return 'denis'
    end
  end

  def self.default_studio_config
    { active_camera: 'spot_1',
      active_spot:  'spot_1',
      studio: 'newsroom_green',
      spot_1: 'brunette',
      spot_2: 'denis',
      spot_3: 'eve',
    }
  end

  private

  def set_slug
    return if !slug.blank?
    if defined? name
      new_slug = name.downcase.gsub(/[^a-z0-9\s_-]/i, '').gsub(' ', '-')
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
