
require 'business_time'
require 'httparty'

namespace :office do

  desc 'run_office_actions'
  task run_office_actions: :environment do
    while true do

      OA  = Wco::OfficeAction
      OAT = Wco::OfficeActionTemplate

      OA.active.where( :perform_at.lte => Time.now ).each do |oa|
        puts "+++ +++ Office Action: #{oa}"

        oa.update({ status: INACTIVE })
        oa.tmpl.do_run
        oa.tmpl.ties.each do |tie|
          next_oa = OA.find_or_initialize_by({
            office_action_template_id: tie.next_oat.id,
          })
          next_oa.perform_at = eval( tie.next_at_exe )
          next_oa.status     = ACTIVE
          next_oa.save!
        end

        print '^'
      end

      print '.'
      sleep Rails.env.production? ? 60 : 5 # seconds
    end
  end

end
