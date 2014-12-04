fs = require 'fs'
{digest} = require '../src/digester'
Donna = require 'donna'
CoffeeScript = require 'coffee-script'

describe 'digest', ->
  it 'generates method arguments', ->
    file = """
      # Public: Some class
      class Something
        # Public: this is a function
        #
        # * `argument` arg
        #   * `argument` arg
        someFunction: ->
    """
    json = Parser.generateDigest(file)
    expect(json.classes.Something.instanceMethods[0].arguments.length).toBe 1
    expect(json.classes.Something.instanceMethods[0].arguments[0].children.length).toBe 1

  it 'generates titled method arguments', ->
    file = """
      # Public: Some class
      class Something
        # Public: this is a function
        #
        # ## Arguments: A title
        #
        # * `argument` arg
        #   * `argument` arg
        someFunction: ->
    """
    json = Parser.generateDigest(file)
    method = json.classes.Something.instanceMethods[0]
    expect(method.titledArguments.length).toBe 1
    expect(method.titledArguments[0].title).toBe 'A title'
    expect(method.titledArguments[0].arguments.length).toBe 1

  it 'generates examples', ->
    file = """
      # Public: Some class
      #
      # ## Examples
      #
      # This is an example
      #
      # ```js
      # a = 1
      # ```
      class Something
        # Public: this is a function
        #
        # ## Examples
        #
        # Method example
        #
        # ```js
        # a = 1
        # ```
        someFunction: ->
    """
    json = Parser.generateDigest(file)
    expect(json.classes.Something.examples.length).toBe 1
    expect(json.classes.Something.examples[0].description).toBe 'This is an example'
    expect(json.classes.Something.instanceMethods[0].examples.length).toBe 1
    expect(json.classes.Something.instanceMethods[0].examples[0].description).toBe 'Method example'

  it 'generates events', ->
    file = """
      # Public: Some class
      #
      # ## Events
      #
      # Class Events
      #
      # ### event-one
      #
      # an event
      #
      # * `argument` arg
      class Something
        # Public: this is a function
        #
        # ## Events
        #
        # Method Events
        #
        # ### event-method
        #
        # a method event
        #
        # * `argument` arg
        someFunction: ->
    """
    json = Parser.generateDigest(file)
    expect(json.classes.Something.events.length).toBe 1
    expect(json.classes.Something.events[0].description).toBe 'an event'
    expect(json.classes.Something.instanceMethods[0].events.length).toBe 1
    expect(json.classes.Something.instanceMethods[0].events[0].description).toBe 'a method event'

  describe 'when a class has a super class', ->
    it 'generates links to github based on repo and version', ->
      file = """
        # Public: Some class
        class Something extends String
      """
      json = Parser.generateDigest file

      expect(json).toEqualJson
        classes:
          Something:
            visibility : 'Public'
            name : 'Something'
            superClass: 'String'
            filename : 'src/fakefile.coffee'
            summary : 'Some class '
            description : 'Some class '
            srcUrl: null
            sections : []
            classMethods : []
            instanceMethods: []
            classProperties: []
            instanceProperties: []

  describe 'src link generation', ->
    describe 'when there are multiple packages', ->
      it 'generates links to github based on repo and version', ->
        file1 = """
          # Public: Some class
          class Something
            # Public: this is a function
            somefunction: ->
        """
        file2 = """
          # Public: Another class
          class Another

            # Public: this is a function
            anotherfunction: ->
        """
        parser = new Parser
        parser.addFile file1,
          filename: 'file1.coffee'
          packageJson:
            name: 'somerepo'
            repository: 'https://github.com/atom/somerepo.git'
            version: '2.3.4'
        parser.addFile file2,
          filename: 'file2.coffee'
          packageJson:
            name: 'anotherrepo'
            repository: 'https://github.com/atom/anotherrepo.git'
            version: '1.2.3'

        json = parser.generateDigest()
        expect(json.classes.Something.srcUrl).toEqual 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L2'
        expect(json.classes.Another.srcUrl).toEqual 'https://github.com/atom/anotherrepo/blob/v1.2.3/file2.coffee#L2'

    describe 'when there is only one package', ->
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
              superClass: null
              filename : 'file1.coffee'
              summary : 'Some class '
              description : 'Some class '
              srcUrl: 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L2'
              sections : []
              classMethods : []
              classProperties: []
              instanceProperties: []
              instanceMethods: [{
                visibility : 'Public'
                name : 'somefunction'
                sectionName : null
                srcUrl : 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L4'
                summary : 'this is a function '
                description : 'this is a function '
              }]

  describe 'class methods', ->
    it 'generates class level methods', ->
      file = """
        # Public: Some class
        class Something
          # Public: Some class level function
          @aClassFunction: ->

          # A private class function
          @privateClassFunction: ->

          # Public: this is a function
          someFunction: ->
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
            name: 'Something'
            superClass: null
            filename : 'file1.coffee'
            summary : 'Some class '
            description : 'Some class '
            srcUrl: 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L2'
            sections : []
            classProperties: []
            instanceProperties: []
            classMethods : [{
              visibility : 'Public'
              name : 'aClassFunction'
              sectionName : null
              srcUrl : 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L4'
              summary : 'Some class level function '
              description : 'Some class level function '
            }]
            instanceMethods: [{
              visibility : 'Public'
              name : 'someFunction'
              sectionName : null
              srcUrl : 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L10'
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

    it 'handles sections that only have properties', ->
      file = """
        # Public: Some class
        class Something
          ###
          Section: Methods
          ###

          # Public: A method
          someMethod: (key, options) ->

          ###
          Section: Props
          ###

          # Public: a property thing
          someProp: 1000
      """
      json = Parser.generateDigest(file)

      expect(json.classes.Something.sections).toEqualJson [{
        name: 'Methods'
        description: ''
      },{
        name: 'Props'
        description: ''
      }]

  describe 'properties', ->
    it 'outputs docs for properties', ->
      file = """
        # Public: Some class
        class Something
          # Public: Class prop
          @classProperty: null

          # Public: Instance prop
          instanceProperty: null

          # Public: this is a function
          someFunction: ->
      """
      json = Parser.generateDigest file,
        filename: 'file1.coffee'
        packageJson:
          name: 'somerepo'
          repository: 'https://github.com/atom/somerepo.git'
          version: '2.3.4'

      expect(json.classes.Something.instanceProperties).toEqualJson [{
        visibility : 'Public'
        name : 'instanceProperty'
        sectionName : null
        srcUrl : 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L7'
        summary : 'Instance prop '
        description : 'Instance prop '
      }]
      expect(json.classes.Something.classProperties).toEqualJson [{
        visibility : 'Public'
        name : 'classProperty'
        sectionName : null
        srcUrl : 'https://github.com/atom/somerepo/blob/v2.3.4/file1.coffee#L4'
        summary : 'Class prop '
        description : 'Class prop '
      }]

# Yeah, recreating some donna stuff here...
class Parser
  @generateDigest: (fileContents, options) ->
    parser = new Parser
    parser.addFile(fileContents, options)
    parser.generateDigest()

  constructor: ->
    @slugs = {}
    @parser = new Donna.Parser()

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
    metadata = new Donna.Metadata(packageJson, @parser)
    metadata.generate(CoffeeScript.nodes(fileContents))
    Donna.populateSlug(slug, filename, metadata)
