
require 'business_time'
require 'httparty'

namespace :wco do


  desc 'run office actions'
  task run_office_actions: :environment do
    puts! "Starting wco_email:run_office_actions..."
    while true do

      schs = Wco::OfficeAction.active.where({ :perform_at.lte => Time.now })
      print "[#{schs.length}]" if schs.length != 0
      schs.each do |sch|

        sch.do_run

        print "[#{sch.id}]^"
        sleep 15
      end

      print '.'
      sleep 15
    end
  end

end
