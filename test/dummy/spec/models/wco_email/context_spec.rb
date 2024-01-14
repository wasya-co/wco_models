
RSpec.describe WcoEmail::Context do

  before do
    WcoEmail::Context.unscoped.map &:destroy!
    WcoEmail::EmailTemplate.unscoped.map &:destroy!
    @tmpl = create( :email_template )
    Wco::Lead.unscoped.map &:destroy!
    @lead = create( :lead )
  end

  it '#scheduled' do
    past_ctx   = create( :email_context, {
      send_at: Time.now - 10.days,
      email_template: @tmpl,
      lead: @lead,
    })
    future_ctx = create( :email_context, {
      send_at: Time.now + 10.days,
      email_template: @tmpl,
      lead: @lead,
    })
    WcoEmail::Context.scheduled.map( &:id ).should eql([ future_ctx.id ])
  end

end


