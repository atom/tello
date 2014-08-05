fs = require 'fs'
{digest} = require '../src/digester'

describe 'digesting atom metadata', ->
  it 'can digest', ->
    rootPath = fs.realpathSync("spec/fixtures/scandal-metadata.json")
    metadata = JSON.parse(fs.readFileSync(rootPath))

    json = digest(metadata)
    console.log JSON.stringify(json, null, '  ')
