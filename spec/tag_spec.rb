
require 'spec_helper'

describe 'Tag' do
  before do
    DatabaseCleaner.clean
    @tag = FactoryBot.create :tag
  end

  subject { @tag }

  it 'the first blank choice is non-disabled in Tag.list' do
    result = Tag.list
    result[0].length.should eql 2 # no extra characteristics as the 3rd field
  end

  it { should validate_uniqueness_of(:slug) }
  it { should validate_presence_of(:slug) }

end

