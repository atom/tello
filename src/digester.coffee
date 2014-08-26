path = require 'path'
_ = require 'underscore'
atomdoc = require 'atomdoc'

class Digester
  constructor: ->
    @current = {}

  digest: (metadata) ->
    classes = {}
    for packageObject in metadata
      @current.package = packageObject
      files = packageObject.files
      for filename, fileData of files
        @current.filename = filename
        @current.objects = fileData.objects
        @current.sections = @extractSections(fileData.objects)

        for row, columnsObj of fileData.objects
          for column, object of columnsObj
            switch object.type
              when 'class'
                classResult = @digestClass(object)
                classes[classResult.name] = classResult if classResult?

    {classes}

  digestClass: (classEntity) ->
    classDoc = @docFromDocString(classEntity.doc)
    return unless classDoc

    sections = @filterSectionsForRowRange(classEntity.range[0][0], classEntity.range[1][0])
    classMethods = @extractEntities(sections, classEntity.classProperties, 'function')
    instanceMethods = @extractEntities(sections, classEntity.prototypeProperties, 'function')
    classProperties = @extractEntities(sections, classEntity.classProperties, 'primitive')
    instanceProperties = @extractEntities(sections, classEntity.prototypeProperties, 'primitive')

    # Only sections that are used should be in the output
    filteredSections = []
    for section in sections
      for method in classMethods.concat instanceMethods
        if section.name is method.sectionName
          filteredSections.push(_.pick section, 'name', 'description')
          break

    parsedAttributes = ['visibility', 'summary', 'description', 'events', 'examples']

    _.extend {
      name: classEntity.name
      superClass: classEntity.superClass
      filename: @current.filename
      srcUrl: @linkForRow(classEntity.range[0][0])
      sections: filteredSections
      classMethods: classMethods
      instanceMethods: instanceMethods
      classProperties: classProperties
      instanceProperties: instanceProperties
    }, _.pick(classDoc, parsedAttributes...)

  digestEntity: (sections, entity, entityPosition) ->
    doc = @docFromDocString(entity.doc)
    return unless doc?

    parsedAttributes = [
      'visibility', 'summary', 'description',
      'arguments', 'events', 'examples', 'returnValues'
    ]

    _.extend {
      name: entity.name
      sectionName: @sectionNameForRow(sections, entityPosition[0])
      srcUrl: @linkForRow(entityPosition[0])
    }, _.pick(doc, parsedAttributes...)

  ###
  Section: Utils
  ###

  extractEntities: (sections, entityPositions, entityType) ->
    entities = []
    for entityPosition in entityPositions
      entityObject = @objectFromPosition(entityPosition)
      if entityObject.type is entityType
        entity = @digestEntity(sections, entityObject, entityPosition)
        entities.push entity if entity?
    entities

  extractSections: (objects) ->
    sections = []
    for row, columnsObj of objects
      for column, object of columnsObj
        if object.type is 'comment'
          section = @sectionFromCommentEntity(object)
          sections.push section if section?
    sections

  sectionFromCommentEntity: (commentEntity) ->
    doc = atomdoc.parse(commentEntity.doc)
    if doc?.visibility is 'Section'
      name: doc.summary
      description: doc.description?.replace(doc.summary, '').trim() ? ''
      startRow: commentEntity.range[0][0]
      endRow: commentEntity.range[1][0]
    else
      null

  filterSectionsForRowRange: (startRow, endRow) ->
    sections = []
    for section in @current.sections
      sections.push section if section.startRow >= startRow and section.startRow <= endRow
    sections.sort (sec1, sec2) -> sec1.startRow - sec2.startRow
    sections

  sectionNameForRow: (sections, row) ->
    return null unless sections.length
    for i in [sections.length-1..0]
      section = sections[i]
      return section.name if row > section.startRow
    null

  docFromDocString: (docString) ->
    classDoc = atomdoc.parse(docString) if docString?
    if classDoc and classDoc.isPublic()
      classDoc
    else
      null

  objectFromPosition: (position) ->
    @current.objects[position[0]][position[1]]

  linkForRow: (row) ->
    return null unless @current.package.repository?

    repo = @current.package.repository.replace(/\.git$/i, '')
    filePath = path.normalize "/blob/v#{@current.package.version}/#{@current.filename}"
    "#{repo}#{filePath}#L#{row + 1}"

module.exports =
  digest: (metadata) ->
    new Digester().digest(metadata)
