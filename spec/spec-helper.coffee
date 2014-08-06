_ = require 'underscore'

beforeEach ->
  @addMatchers
    toEqualJson: (expected) ->
      failures = {}

      class Failure
        constructor: (@path, @actual, @expected) ->

        getMessage: ->
          """
          #{@path}:
            actual:   #{@actual}
            expected: #{@expected}
          """

      addFailure = (path, actual, expected) ->
        path = path.join('.') or '<root>'
        failures[path] = new Failure(path, actual, expected)

      appendToPath = (path, value) ->
        path.concat([value])

      compare = (path, actual, expected) ->
        return if not actual? and not expected?

        if not actual? or not expected?
          addFailure(path, JSON.stringify(actual), JSON.stringify(expected))
        else if actual.constructor.name != expected.constructor.name
          addFailure(path, JSON.stringify(actual), JSON.stringify(expected))
        else
          switch actual.constructor.name
            when "String", "Boolean", "Number"
              addFailure(path, JSON.stringify(actual), JSON.stringify(expected)) if actual != expected

            when "Array"
              if actual.length != expected.length
                addFailure(path, "has length #{actual.length}", "has length #{expected.length}")
              else
                for value, i in actual
                  compare(appendToPath(path, i), actual[i], expected[i])

            when "Object"
              actualKeys = _.keys(actual)
              expectedKeys = _.keys(expected)
              unless _.isEqual(actualKeys, expectedKeys)
                addFailure(path, "has keys #{JSON.stringify(actualKeys)}", "has keys #{JSON.stringify(expectedKeys)}")
              else
                for key, value of actual
                  continue unless actual.hasOwnProperty(key)
                  compare(appendToPath(path, key), actual[key], expected[key])
        return

      compare([], @actual, expected)

      if _.size failures
        @message = =>
          messages = []
          for key, failure of failures
            messages.push failure.getMessage()
          'JSON is not equal:\n' + messages.join('\n')
        false

      else
        @message = => @actual + ' is equal to ' + expected
        true
