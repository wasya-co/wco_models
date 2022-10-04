
= Important DB Changes

 db.reports.update({}, {$rename:{"name_seo":"slug"}}, false, true)
 db.venues.update({}, {$rename:{"name_seo":"slug"}}, false, true)

 db.reports.updateMany( {}, [ {"$set": {"name_seo": "$name" } } ] )
 db.galleries.updateMany( {}, [ {"$set": {"slug": "$galleryname" } } ] )

== 1.0.0 _vp_ 2021-11-10 ==

 db.ish_models_user_profiles.renameCollection("ish_user_profiles")
 Gameui::Marker.unscoped.update_all( is_public: true )
 Gameui::Map.unscoped.update_all( is_public: true )

= Test =

 be rspec spec




