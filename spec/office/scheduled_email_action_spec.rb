
require 'spec_helper'

describe Office::ScheduledEmailAction do
  before do
  end

  describe 'validations' do

    it 'uniqueness of lead, scoped to action' do
      act = create( :email_action )

      sch = Sch.new lead_id: 555, email_action: act
      sch.save.should eql true

      sch = Sch.new lead_id: 555, email_action: act
      sch.save.should eql false
      sch.errors.full_messages.should eql(["Email action is already taken"])
    end

  end

end
