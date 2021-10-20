
= Important DB Changes

 db.reports.update({}, {$rename:{"name_seo":"slug"}}, false, true)
 db.venues.update({}, {$rename:{"name_seo":"slug"}}, false, true)

 db.reports.updateMany( {}, [ {"$set": {"name_seo": "$name" } } ] )
 db.galleries.updateMany( {}, [ {"$set": {"slug": "$galleryname" } } ] )

= Test =

 be rspec spec


