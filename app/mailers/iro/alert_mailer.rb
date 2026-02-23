
class Iro::AlertMailer < ActionMailer::Base
  default from: 'no-reply@wasya.co'
  layout 'mailer'

  def stock_alert id
    @alert = Iro::Alert.find id
    mail( to: 'victor@piousbox.com',
     subject: "#{Time.now.to_date} Iro::AlertMailer#stock_alert" )
  end

end
