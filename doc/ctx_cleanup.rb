
lead = Wco::Lead.where( email: 'no-reply@wasya.co' ).first
blank = WcoEmail::EmailTemplate.where( slug: 'blank' ).first

w = 1000 ## window
(1...160).each do |n|
  WcoEmail::Context.all.skip(w*n).limit(w).each do |ctx|
    dirty = false

    if ctx.lead.blank?
      puts "#{ctx.id} subj:`#{ctx.subject}` no-lead"
      ctx.lead = lead
      dirty = true
    end

    if ctx.tmpl.blank?
      ctx.email_template = blank
      dirty = true
    end

    if dirty
      ctx.save
    end

  end
end
