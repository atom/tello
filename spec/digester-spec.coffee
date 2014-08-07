fs = require 'fs'
{digest} = require '../src/digester'
Biscotto = require 'biscotto'

describe 'digest', ->
  describe 'src generation', ->
    it 'generates links to github based on repo and version', ->
      file = """
        # Public: Some class
        class Something
          # Public: this is a function
          somefunction: ->
      """
      json = Parser.generateDigest file,
        filename: 'file1.coffee'
        packageJson:
          name: 'somerepo'
          repository: 'https://github.com/atom/somerepo.git'
          version: '2.3.4'

      expect(json).toEqualJson
        classes:
          Something:
            visibility : 'Public'
            name : 'Something'
            filename : 'file1.coffee'
            summary : 'Some class '
            description : 'Some class '
            srcUrl: 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L2'
            sections : []
            classMethods : []
            instanceMethods: [{
              visibility : 'Public'
              name : 'somefunction'
              sectionName : null
              srcUrl : 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L4'
              summary : 'this is a function '
              description : 'this is a function '
            }]

  describe 'sections', ->
    it 'correctly splits the sections when there are mutiple classes in the file', ->
      file = """
        # Public: Some class
        class Something
          # Public: has no section
          noSection: ->

          ###
          Section: One
          ###

          # Public: in section one
          sectionOneFn: ->

        # Public: another class
        class Another
          # Public: another with no section
          noSection: ->

          ###
          Section: Two

          This is section two!
          ###

          # Public: in section two
          sectionTwoFn: ->
      """
      json = Parser.generateDigest(file)

      expect(json.classes.Something.sections).toEqualJson [{
        name: 'One'
        description: ''
      }]
      expect(json.classes.Another.sections).toEqualJson [{
        name: 'Two'
        description: 'This is section two!'
      }]

      expect(json.classes.Something.instanceMethods).toEqualJson [{
        srcUrl: null
        name: 'noSection'
        sectionName: null
        visibility: 'Public'
        summary: 'has no section '
        description: 'has no section '
      }, {
        name: 'sectionOneFn'
        sectionName: 'One'
        srcUrl: null
        visibility: 'Public'
        summary: 'in section one '
        description: 'in section one '
      }]

      expect(json.classes.Another.instanceMethods).toEqualJson [{
        srcUrl: null
        name: 'noSection'
        sectionName: null
        visibility: 'Public'
        summary: 'another with no section '
        description: 'another with no section '
      }, {
        name: 'sectionTwoFn'
        sectionName: 'Two'
        srcUrl: null
        visibility: 'Public'
        summary: 'in section two '
        description: 'in section two '
      }]

    it 'correctly splits the sections when there are mutiple files with classes', ->
      file1 = """
        # Public: Some class
        class Something
          # Public: has no section
          noSection: ->

          ###
          Section: One
          ###

          # Public: in section one
          sectionOneFn: ->
      """

      file2 = """
        # Public: another class
        class Another
          # Public: another with no section
          noSection: ->

          ###
          Section: Two

          This is section two!
          ###

          # Public: in section two
          sectionTwoFn: ->
      """
      parser = new Parser()
      parser.addFile(file1, filename: 'src/file1.coffee')
      parser.addFile(file2, filename: 'src/file2.coffee')
      json = parser.generateDigest()

      expect(json.classes.Something.sections).toEqualJson [{
        name: 'One'
        description: ''
      }]
      expect(json.classes.Another.sections).toEqualJson [{
        name: 'Two'
        description: 'This is section two!'
      }]

      expect(json.classes.Something.instanceMethods).toEqualJson [{
        srcUrl: null
        name: 'noSection'
        sectionName: null
        visibility: 'Public'
        summary: 'has no section '
        description: 'has no section '
      }, {
        name: 'sectionOneFn'
        sectionName: 'One'
        srcUrl: null
        visibility: 'Public'
        summary: 'in section one '
        description: 'in section one '
      }]

      expect(json.classes.Another.instanceMethods).toEqualJson [{
        srcUrl: null
        name: 'noSection'
        sectionName: null
        visibility: 'Public'
        summary: 'another with no section '
        description: 'another with no section '
      }, {
        name: 'sectionTwoFn'
        sectionName: 'Two'
        srcUrl: null
        visibility: 'Public'
        summary: 'in section two '
        description: 'in section two '
      }]

    it 'pulls out all the sections, assigns methods to sections, and only returns sections that have public methods', ->
      file = """
        # Public: Some class
        class Something
          # Public: has no section
          noSection: ->

          ###
          Section: One
          ###

          # Public: in section one
          sectionOneFn: ->

          # Public: in section one
          anotherSectionOneFn: ->

          ###
          Section: Two
          ###

          # Public: in section two
          sectionTwoFn: ->

          ###
          Section: Private
          ###

          # Nope, not in there
          privateFn: ->
      """
      json = Parser.generateDigest(file)

      expect(json.classes.Something.sections).toEqualJson [{
        name: 'One'
        description: ''
      },{
        name: 'Two'
        description: ''
      }]

      expect(json.classes.Something.instanceMethods).toEqualJson [{
        name: 'noSection'
        sectionName: null
        srcUrl: null
        visibility: 'Public'
        summary: 'has no section '
        description: 'has no section '
      }, {
        name: 'sectionOneFn'
        sectionName: 'One'
        srcUrl: null
        visibility: 'Public'
        summary: 'in section one '
        description: 'in section one '
      }, {
        name: 'anotherSectionOneFn'
        sectionName: 'One'
        visibility: 'Public'
        summary: 'in section one '
        description: 'in section one '
        srcUrl: null
      }, {
        name: 'sectionTwoFn'
        sectionName: 'Two'
        visibility: 'Public'
        summary: 'in section two '
        description: 'in section two '
        srcUrl: null
      }]

  describe 'digesting Scandal metadata', ->
    it 'can digest', ->
      rootPath = fs.realpathSync("spec/fixtures/scandal-metadata.json")
      metadata = JSON.parse(fs.readFileSync(rootPath))

      json = digest(metadata)
      console.log JSON.stringify(json, null, '  ')

# Yeah, recreating some biscotto stuff here...
class Parser
  @generateDigest: (fileContents, options) ->
    parser = new Parser
    parser.addFile(fileContents, options)
    parser.generateDigest()

  constructor: ->
    @slugs = {}
    @parser = new Biscotto.Parser
      inputs: []
      output: ''
      extras: []
      readme: ''
      title: ''
      quiet: false
      private: true
      verbose: true
      metadata: true
      github: ''

  generateDigest: ->
    slugs = []
    for k, slug of @slugs
      slugs.push(slug)
    digest(slugs)

  addFile: (fileContents, {filename, packageJson}={}) ->
    filename ?= 'src/fakefile.coffee'
    packageJson ?= {}

    slug = @slugs[packageJson.name ? 'default'] ?=
      main: packageJson.main
      repository: packageJson.repository
      version: packageJson.version
      files: {}

    @parser.parseContent(fileContents, filename)
    metadata = new Biscotto.Metadata(packageJson, @parser)
    metadata.generate(CoffeeScript.nodes(fileContents))
    Biscotto.populateSlug(slug, filename, metadata)
