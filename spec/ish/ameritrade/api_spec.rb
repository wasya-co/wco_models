
require 'spec_helper'

describe 'Ish::Ameritrade::Api' do

  describe '#get_option_chain' do

    it 'validations' do
      expect do
        result = Ish::Ameritrade::Api.get_option_chain({})
      end.to raise_error Ish::InputError
    end
  end

end

