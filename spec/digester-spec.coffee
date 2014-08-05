fs = require 'fs'
{digest} = require '../src/digester'

describe 'digesting atom metadata', ->
  metadata = null
  beforeEach ->
    rootPath = fs.realpathSync("spec/fixtures/atom-metadata.json")
    metadata = JSON.parse(fs.readFileSync(rootPath))

  it 'can digest', ->
    json = digest(metadata)
    console.log JSON.stringify(json, null, '  ')
