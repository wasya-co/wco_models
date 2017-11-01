
# Don't forget to be in development_production environment!

=begin
scoped galleries: 207
unscoped: 389
unscoped not trash: 338

scoped photos: 8657
all photos: 9077

irb(main):006:0> Report.unscoped.count
=> 1346 (before import)
irb(main):007:0> Report.count
=> 1213
irb(main):008:0> Report.unscoped.where( :is_trash => false ).count
=> 1312

=end

Gallery.unscoped.destroy
AppModel2.unscoped.where( :_type => 'Gallery' ).destroy

# take all those galleries from app_model2s and put them in galleries
Gallery.unscoped.count
aggregate = AppModel2.collection.aggregate([
  { '$match' => { '_type': 'Gallery' } },
  { '$project' => { '_id': 1, 
                    'city_id' => 1, 'site_id' => 1, 'tag_id' => 1,
                    'created_at' => 1, 'galleryname' => 1, 'is_public' => 1, 'is_trash' => 1, 'name' => 1, 'updated_at' => 1 } },
  { '$out' => 'galleries' }
])
Gallery.unscoped.count

# reports
# there are 23 to import
aggregate = AppModel2.collection.aggregate([
  { '$match' => { '_type': 'Report' } },
  { '$project' => { '_id': 1, 'city_id' => 1, 'site_id' => 1, 'created_at' => 1, 'name_seo' => 1, 'is_public' => 1, 'is_trash' => 1, 'name' => 1, 'tag_id' => 1, 'updated_at' => 1,
                    'x': 1, 'y': 1, 'subhead': 1, 'descr': 1, } }
])
results = aggregate.to_a
results.each_with_index do |result, idx|
  r = Report.new result.to_h
  r.name_seo = "#{r.name_seo}-#{idx}"
  if r.save
    print '.'
    puts r.name_seo
  else
    puts r.errors.messages
  end
end; nil

# tags: there are 32 unscoped, and 11 to import
aggregate = AppModel2.collection.aggregate([
  { '$match' => { '_type': 'Tag' } },
  { '$project' => { '_id': 1, 'created_at' => 1, 'updated_at' => 1, 'is_public' => 1, 'is_trash' => 1, 'name_seo' => 1, 'name' => 1 } }
])
results = aggregate.to_a
results.each_with_index do |result, idx|
  t = Tag.new result.to_h
  if t.save
    print '.'
  else
    puts "+++ +++ #{t.name}"
    puts t.errors.messages
  end
end; nil


