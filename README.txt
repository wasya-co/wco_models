
= Important DB Changes

 db.reports.update({}, {$rename:{"name_seo":"slug"}}, false, true)
 db.venues.update({}, {$rename:{"name_seo":"slug"}}, false, true)

= Test =

 be rspec spec


