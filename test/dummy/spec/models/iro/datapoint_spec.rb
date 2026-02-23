
RSpec.describe Iro::Datapoint do

  before do
    destroy_every( Iro::Datapoint )
  end

  describe 'positive' do
    it 'sanity' do
      n = Iro::Datapoint.all.length
      Iro::Datapoint.create( kind: 'something', value: 1 )
      Iro::Datapoint.all.length.should eql(n + 1 )
    end
  end

  describe 'validations' do
    it 'requires kind (k) and value (v)' do
      lambda { Iro::Datapoint.create!
        }.should raise_exception( Mongoid::Errors::Validations )
      lambda { Iro::Datapoint.create!( kind: 'something' )
        }.should raise_exception( Mongoid::Errors::Validations )
      lambda { Iro::Datapoint.create!( value: 1 )
        }.should raise_exception( Mongoid::Errors::Validations )
    end
  end

  it '#import_stock' do
    Iro::Datapoint.all.length.should eql 0
    Iro::Datapoint.import_stock symbol: 'GME', path: '../../data/GME-test.csv'
    Iro::Datapoint.all.length.should eql 4
    Iro::Datapoint.import_stock symbol: 'GME', path: '../../data/GME-test.csv'
    Iro::Datapoint.all.length.should eql 4
  end

end

