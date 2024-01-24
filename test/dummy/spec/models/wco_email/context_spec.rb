
RSpec.describe WcoEmail::Context do

  before do
    destroy_every(
      Wco::Lead,
      WcoEmail::Context,
      WcoEmail::EmailTemplate,
    );
    @tmpl = create( :email_template )
    @lead = create( :lead )
  end

  context 'callbacks' do
    it 'clears empty body' do
      @ctx = build( :email_context, body: "<p><br /></p>", lead: @lead, email_template: @tmpl )
      @ctx.save
      @ctx.reload
      @ctx.body.should eql '' # after two fallbacks (thru template), the body is empty string.
    end
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
    WcoEmail::Context.scheduled.map( &:id ).should eql([ past_ctx.id ])
  end

end


