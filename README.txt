
WasyaCo Models. The functionality shared across all (most) projects, including:

* the ActiveRecord models
* some stylesheets
* some javascript
* some controllers and views

= Setup =

Docker is reqiured for development. It is used for mongo (?), and localstack.

Some infrastructure is driven by ansible - therefore, local python3 and ansible are required:

  python3 -m venv zenv
  . zenv/bin/activate
  pip install -r requirements.txt

= Develop / Use =


  cmd = "#{cmd} [ -f newspartial_#{idx}.mp4 ] || ffmpeg -y -i newspartial_#{idx}.webm -r 24 -pix_fmt yuv420p newspartial_#{idx}.mp4 ; "


  == Image to video ==

    ffmpeg -loop 1 -i $inn -c:v libx264 -t 3 -pix_fmt yuv420p output.mp4


    export width=848
    export height=480
    export duration_sec=3
    magick "$inn" -resize "${width}x${height}^" -gravity center -extent "${width}x${height}" "$inn"
    ffmpeg -loop 1 -i $inn -c:v libx264 -t $duration_sec -pix_fmt yuv420p $inn-out.mp4


= Test =

See doc/localstack.txt

In ruby console:

  stub = WcoEmail::MessageStub.create({
    object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1',
    bucket: 'wco-email-ses-development',
    config: { process_images: false }.to_json,
  })
  stub.do_process

