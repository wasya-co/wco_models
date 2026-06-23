
RSpec.describe WcoEmail::ApplicationMailer do

  before do
    destroy_every( Wco::Lead, Wco::Profile,
      WcoEmail::Context, WcoEmail::EmailTemplate )
    @profile = create(:profile, email: 'no-reply@wasya.co')
  end

  it 'sanity' do
    @lead = create :lead
    @tmpl = create :email_template
    @ctx  = create :email_context, lead: @lead, email_template: @tmpl

    out = WcoEmail::ApplicationMailer.send_context_email( @ctx[:id].to_s )
    out.deliver_now
  end

end


