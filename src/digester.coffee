path = require 'path'
_ = require 'underscore'
atomdoc = require 'atomdoc'

class Digester
  constructor: ->
    @current = {}

  digest: (metadata) ->
    classes = []
    for packageObject in metadata
      @current.package = packageObject
      files = packageObject.files
      for filename, fileData of files
        @current.filename = filename
        @current.objects = fileData.objects
        for row, columnsObj of fileData.objects
          for column, object of columnsObj
            switch object.type
              when 'class'
                klass = @digestClass(object)
                classes.push klass if klass?
              # when 'comment'

    {classes}

  digestClass: (klass) ->
    classDoc = @docFromDocString(klass.doc)
    return unless classDoc and classDoc.visibility is 'Essential'

    classMethods = @extractEntities(klass.classProperties, 'function')
    instanceMethods = @extractEntities(klass.prototypeProperties, 'function')

    {
      name: klass.name
      filename: @current.filename
      visibility: classDoc.visibility
      classMethods: classMethods
      instanceMethods: instanceMethods
    }

  extractEntities: (entityPositions, entityType) ->
    entities = []
    for entityPosition in entityPositions
      entityObject = @objectFromPosition(entityPosition)
      if entityObject.type is entityType
        entity = @digestEntity(entityObject, entityPosition)
        entities.push entity if entity?
    entities

  digestEntity: (entity, entityPosition) ->
    doc = @docFromDocString(entity.doc)
    return unless doc?

    {
      name: entity.name
      visibility: doc.visibility
      summary: doc.summary
      srcUrl: @linkForPosition(entityPosition)
    }

  ###
  Section: Utils
  ###

  docFromDocString: (docString) ->
    classDoc = atomdoc.parse(docString) if docString?
    if classDoc and classDoc.isPublic()
      classDoc
    else
      null

  objectFromPosition: (position) ->
    @current.objects[position[0]][position[1]]

  linkForPosition: (position) ->
    return null unless @current.package.repository?

    repo = @current.package.repository.replace(/\.git$/i, '')
    filePath = path.normalize "/blob/v#{@current.package.version}/#{@current.filename}"
    "#{repo}#{filePath}#L#{position[0]}"

module.exports =
  digest: (metadata) ->
    new Digester().digest(metadata)
