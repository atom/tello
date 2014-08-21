fs = require 'fs'
{digest} = require '../src/digester'

main = ->
  # TODO: make it handle any metadata file...
  metadata = JSON.parse(fs.readFileSync('spec/fixtures/scandal-metadata.json', 'utf8'))
  json = digest(metadata)
  fs.writeFileSync('spec/fixtures/scandal-output.json', JSON.stringify(json, null, '  '))

module.exports = {main}
