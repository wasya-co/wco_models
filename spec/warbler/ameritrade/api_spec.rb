
require 'spec_helper'

describe 'Warbler::Ameritrade::Api' do

  describe '#get_option_chain' do

    it 'validations' do
      expect do
        result = ::Warbler::Ameritrade::Api.get_option_chain({})
      end.to raise_error Ish::InputError
    end
  end

end

