
RSpec.describe WcoEmail::ApplicationMailer do

  before do
    destroy_every( Wco::Lead, Wco::Profile,
      WcoEmail::Context, WcoEmail::EmailTemplate )
    @profile = create(:profile, email: 'no-reply@wasya.co')
    @lead = create :lead
    @tmpl = create :email_template
    @ctx  = create :email_context, lead: @lead, email_template: @tmpl
  end

  it 'sends' do
    expect_any_instance_of(WcoEmail::ApplicationMailer).to receive(:mail)
    out = WcoEmail::ApplicationMailer.send_context_email( @ctx[:id].to_s )
    out.deliver_now
  end

  it 'donotsend_tags' do
    expect_any_instance_of(WcoEmail::ApplicationMailer).not_to receive(:mail)
    @lead.tags.push Wco::Tag.donotsend
    out = WcoEmail::ApplicationMailer.send_context_email( @ctx[:id].to_s )
  end

end


