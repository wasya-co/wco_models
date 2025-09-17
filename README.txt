
WasyaCo Models. The functionality shared across all (most) projects, including:
* The ActiveRecord models
* some stylesheets,
* some javascript.

== Setup ==

Docker is reqiured for development. It is used for mongo, and localstack.

Some infrastructure is driven by ansible - therefore, local python is required:

  python3 -m venv zenv
  . zenv/bin/activate

== Test ==

Login to the localstack container, then:

  awslocal s3api put-object --bucket wco-email-ses-development \
    --key 00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1 \
    --body /opt/tmp/00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1

In ruby console:

  stub = WcoEmail::MessageStub.create({
    object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1',
    bucket: 'wco-email-ses-development',
    config: { process_images: false }.to_json,
  })
  stub.do_process

