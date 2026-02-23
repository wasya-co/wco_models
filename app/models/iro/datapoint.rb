require 'csv'

##
## Datapoints are at most daily!
## See Priceitem for intra-day data
##
class Iro::Datapoint
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_datapoints'

  field :kind
  validates :kind, presence: true
  index({ kind: -1 })
  KIND_CRYPTO   = 'CRYPTO'
  KIND_STOCK    = 'STOCK'
  KIND_OPTION   = 'OPTION' ## but not PUT or CALL
  KIND_CURRENCY = 'CURRENCY'
  KIND_TREASURY = 'TREASURY'

  field :symbol ## ticker, but use 'symbol' here
  ## crypto
  SYMBOL_BTC = 'BTC'
  SYMBOL_ETH = 'ETH'
  ## currencies
  SYMBOL_JPY = 'JPY'
  SYMBOL_COP = 'COP'
  SUMBOL_EUR = 'EUR'
  ## treasuries
  SYMBOL_T1MO  = 'T1MO'
  SYMBOL_T2MO  = 'T2MO'
  SYMBOL_T3MO  = 'T3MO'
  SYMBOL_T4MO  = 'T4MO'
  SYMBOL_T6MO  = 'T6MO'
  SYMBOL_T1YR  = 'T1YR'
  SYMBOL_T2YR  = 'T2YR'
  SYMBOL_T3YR  = 'T3YR'
  SYMBOL_T5YR  = 'T5YR'
  SYMBOL_T7YR  = 'T7YR'
  SYMBOL_T10YR = 'T10YR'
  SYMBOL_T20YR = 'T20YR'
  SYMBOL_T30YR = 'T30YR'

  field :date, type: Date
  index({ kind: -1, date: -1 })
  validates :date, uniqueness: { scope: [ :kind, :symbol ] }

  ## @obsolete, @deprecated, use :date instead?
  field :quote_at, type: DateTime
  index({ kind: -1, quote_at: -1 })
  ## I don't understand why this was forced to be unique... I want the date to be unique.
  # validates :quote_at, uniqueness: { scope: [ :kind, :symbol ] } ## scope-by-kind is unnecessary here? _vp_ 2024-08-08

  field :open,  type: Float
  field :high,  type: Float
  field :low,   type: Float
  field :value, type: Float
  validates :value, presence: true
  def close;    value;    end
  def close= a; value= a; end


  field :volume, type: Integer


  def self.test_0trash
    add_fields = { '$addFields':  {
      'date_string': {
        '$dateToString': { 'format': "%Y-%m-%d", 'date': "$created_at" }
      }
    } }
    # group = { '$group': {
    #   '_id': "$date_string",
    #   'my_doc': { '$first': "$$ROOT" }
    # } }
    group = { '$group': {
      '_id': "$date",
      'my_doc': { '$first': "$$ROOT" }
    } }
    lookup = { '$lookup': {
      'from':         'iro_dates',
      'localField':   'date_string',
      'foreignField': 'date',
      'as':           'dates',
    } }
    lookup_merge = { '$replaceRoot': {
      'newRoot': { '$mergeObjects': [
        { '$arrayElemAt': [ "$dates", 0 ] }, "$$ROOT"
      ] }
    } }
    match = { '$match': {
      'kind': 'some-type',
      'created_at': {
        '$gte': '2023-12-01'.to_datetime,
        '$lte': '2023-12-31'.to_datetime,
      }
    } }

    outs = Iro::Datapoint.collection.aggregate([
      add_fields,
      lookup, lookup_merge,
      match,

      { '$sort': { 'date_string': 1 } },
      group,
      # { '$replaceRoot': { 'newRoot': "$my_doc" } },
      # { '$project': { '_id': 0, 'date_string': 1, 'value': 1 } },
    ])

    puts! 'result'
    pp outs.to_a
    # puts! outs.to_a, 'result'
  end

  def self.test
    lookup = { '$lookup': {
      'from':         'iro_datapoints',
      'localField':   'date',
      'foreignField': 'date',
      'pipeline': [
        { '$sort': { 'value': -1 } },
      ],
      'as':           'datapoints',
    } }
    lookup_merge = { '$replaceRoot': {
      'newRoot': { '$mergeObjects': [
        { '$arrayElemAt': [ "$datapoints", 0 ] }, "$$ROOT"
      ] }
    } }


    match = { '$match': {
      'date': {
        '$gte': '2023-12-25',
        '$lte': '2023-12-31',
      }
    } }

    group = { '$group': {
      '_id': "$date",
      'my_doc': { '$first': "$$ROOT" }
    } }

    outs = Iro::Date.collection.aggregate([
      match,

      lookup,
      lookup_merge,

      group,
      { '$replaceRoot': { 'newRoot': "$my_doc" } },
      # { '$replaceRoot': { 'newRoot': "$my_doc" } },


      { '$project': { '_id': 0, 'date': 1, 'value': 1 } },
      { '$sort': { 'date': 1 } },
    ])

    puts! 'result'
    pp outs.to_a
    # puts! outs.to_a, 'result'
  end

  def self.import_stock symbol:, path:
    csv = CSV.read(path, headers: true)
    csv.each do |row|
      flag = create({
        kind:     KIND_STOCK,
        symbol:   symbol,
        date:     row['date'],
        quote_at: row['date'],

        volume: row['volume'],

        open:  row['open'],
        high:  row['high'],
        low:   row['low'],
        value: row['close'],
      })
      if flag.persisted?
        print '^'
      else
        puts flag.errors.messages
      end
    end
    puts 'ok'
  end

end