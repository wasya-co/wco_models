

namespace :db do

  desc 'seed'
  task :seed do
    leadset = Wco::Leadset.find_or_create_by({ company_url: 'poxlovi@gmail.com' })
    leadset.persisted?
    lead    = Wco::Lead.find_or_create_by({ email: 'poxlovi@gmail.com', leadset: leadset })
    lead.persisted?
  end

end
