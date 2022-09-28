##### Atom and all repositories under Atom will be archived on December 15, 2022. Learn more in our [official announcement](https://github.blog/2022-06-08-sunsetting-atom/)
 # Tello: A Donna metadata digest

Converts [metadata][metadata] from [donna][donna] to an intermediate doc format
using [atomdoc][atomdoc] as the docstring parser.

The tello format should be straightforward to convert into HTML. This project
does not, and will not generate HTML.

## Usage

```coffee
Tello = require 'tello'

metadata = # get from donna!
telloFormat = Tello.digest(metadata)
```

### From the command line

Generate metadata from [donna][donna], then:

```
donna -o . path/to/my/module
tello -i metadata.json -o api.json
```

## Output

Here is an example output based on [Scandal.PathSearcher][searcher]:

```js
{
  "classes": {
    "PathSearcher": {
      "name": "PathSearcher",
      "superClass": "EventEmitter",
      "filename": "src/path-searcher.coffee",
      "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L88",
      "sections": [
        {
          "name": "Searching",
          "description": ""
        }
      ],
      "classMethods": [],
      "instanceMethods": [
        {
          "name": "constructor",
          "sectionName": null,
          "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L97",
          "visibility": "Public",
          "summary": "Construct a {PathSearcher} object.",
          "description": "Construct a {PathSearcher} object.",
          "arguments": [
            {
              "children": [
                {
                  "name": "maxLineLength",
                  "description": "{Number} default `100`; The max length of the `lineText`  component in a results object. `lineText` is the context around the matched text.",
                  "type": "Number",
                  "isOptional": false
                },
                {
                  "name": "wordBreakRegex",
                  "description": "{RegExp} default `/[ \\r\\n\\t;:?=&\\/]/`;  Used to break on a word when finding the context for a match. ",
                  "type": "RegExp",
                  "isOptional": false
                }
              ],
              "name": "options",
              "description": "{Object}",
              "type": "Object",
              "isOptional": false
            }
          ]
        },
        {
          "name": "searchPaths",
          "sectionName": "Searching",
          "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L118",
          "visibility": "Public",
          "summary": "Search an array of paths.",
          "description": "Search an array of paths.\n\nWill search with a {ChunkedExecutor} so as not to immediately exhaust all\nthe available file descriptors. The {ChunkedExecutor} will execute 20 paths\nconcurrently.",
          "arguments": [
            {
              "name": "regex",
              "description": "{RegExp} search pattern",
              "type": "RegExp",
              "isOptional": false
            },
            {
              "name": "paths",
              "description": "{Array} of {String} file paths to search",
              "type": "Array",
              "isOptional": false
            },
            {
              "children": [
                {
                  "name": "results",
                  "description": "{Array} of Result objects in the format specified above;  null when there are no results",
                  "type": "Array",
                  "isOptional": false
                },
                {
                  "name": "errors",
                  "description": "{Array} of errors; null when there are no errors. Errors will  be js Error objects with `message`, `stack`, etc. ",
                  "type": "Array",
                  "isOptional": false
                }
              ],
              "name": "doneCallback",
              "description": "called when searching the entire array of paths has finished",
              "type": null,
              "isOptional": false
            }
          ]
        },
        {
          "name": "searchPath",
          "sectionName": "Searching",
          "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L144",
          "visibility": "Public",
          "summary": "Search a file path for a regex",
          "description": "Search a file path for a regex",
          "arguments": [
            {
              "name": "regex",
              "description": "{RegExp} search pattern",
              "type": "RegExp",
              "isOptional": false
            },
            {
              "name": "filePath",
              "description": "{String} file path to search",
              "type": "String",
              "isOptional": false
            },
            {
              "children": [
                {
                  "name": "results",
                  "description": "{Array} of Result objects in the format specified above;  null when there are no results",
                  "type": "Array",
                  "isOptional": false
                },
                {
                  "name": "error",
                  "description": "{Error}; null when there is no error ",
                  "type": "Error",
                  "isOptional": false
                }
              ],
              "name": "doneCallback",
              "description": "called when searching the entire array of paths has finished",
              "type": null,
              "isOptional": false
            }
          ]
        }
      ],
      "classProperties": [],
      "instanceProperties": [],
      "visibility": "Public",
      "summary": "Will search through paths specified for a regex.",
      "description": "Will search through paths specified for a regex.\n\nLike the {PathScanner} the {PathSearcher} keeps no state. You need to consume\nresults via the done callbacks or events.\n\nFile reading is fast and memory efficient. It reads in 10k chunks and writes\nover each previous chunk. Small object creation is kept to a minimum during\nthe read to make light use of the GC.",
      "events": [
        {
          "name": "results-found",
          "summary": "Fired when searching for a each path has been completed and matches were found.",
          "description": "Fired when searching for a each path has been completed and matches were found.",
          "visibility": "Private",
          "arguments": [
            {
              "name": "results",
              "description": "{Object} in the result format:\n```js\n{\n  \"path\": \"/Some/path.txt\",\n  \"matches\": [{\n    \"matchText\": \"Text\",\n    \"lineText\": \"Text in this file!\",\n    \"lineTextOffset\": 0,\n    \"range\": [[9, 0], [9, 4]]\n  }]\n}\n```",
              "type": "Object",
              "isOptional": false
            }
          ]
        },
        {
          "name": "results-not-found",
          "summary": "Fired when searching for a path has finished and _no_ matches were found.",
          "description": "Fired when searching for a path has finished and _no_ matches were found.",
          "visibility": "Private",
          "arguments": [
            {
              "name": "filePath",
              "description": "path to the file nothing was found in `\"/Some/path.txt\"`",
              "type": null,
              "isOptional": false
            }
          ]
        },
        {
          "name": "file-error",
          "summary": "Fired when an error occurred when searching a file. Happens for example when a file cannot be opened.",
          "description": "Fired when an error occurred when searching a file. Happens for example when a file cannot be opened.",
          "visibility": "Private",
          "arguments": [
            {
              "name": "error",
              "description": "{Error} object",
              "type": "Error",
              "isOptional": false
            }
          ]
        }
      ],
      "examples": [
        {
          "description": "",
          "lang": "coffee",
          "code": "{PathSearcher} = require 'scandal'\nsearcher = new PathSearcher()\n\n# You can subscribe to a `results-found` event\nsearcher.on 'results-found', (result) ->\n  # result will contain all the matches for a single path\n  console.log(\"Single Path's Results\", result)\n\n# Search a list of paths\nsearcher.searchPaths /text/gi, ['/Some/path', ...], (results) ->\n  console.log('Done Searching', results)\n\n# Search a single path\nsearcher.searchPath /text/gi, '/Some/path', (result) ->\n  console.log('Done Searching', result)",
          "raw": "```coffee\n{PathSearcher} = require 'scandal'\nsearcher = new PathSearcher()\n\n# You can subscribe to a `results-found` event\nsearcher.on 'results-found', (result) ->\n  # result will contain all the matches for a single path\n  console.log(\"Single Path's Results\", result)\n\n# Search a list of paths\nsearcher.searchPaths /text/gi, ['/Some/path', ...], (results) ->\n  console.log('Done Searching', results)\n\n# Search a single path\nsearcher.searchPath /text/gi, '/Some/path', (result) ->\n  console.log('Done Searching', result)\n```"
        },
        {
          "description": "A results from line 10 (1 based) are in the following format:",
          "lang": "js",
          "code": "{\n  \"path\": \"/Some/path\",\n  \"matches\": [{\n    \"matchText\": \"Text\",\n    \"lineText\": \"Text in this file!\",\n    \"lineTextOffset\": 0,\n    \"range\": [[9, 0], [9, 4]]\n  }]\n}",
          "raw": "```js\n{\n  \"path\": \"/Some/path\",\n  \"matches\": [{\n    \"matchText\": \"Text\",\n    \"lineText\": \"Text in this file!\",\n    \"lineTextOffset\": 0,\n    \"range\": [[9, 0], [9, 4]]\n  }]\n}\n```"
        }
      ]
    }
  }
}
```

[metadata]:https://github.com/atom/tello/blob/master/spec/fixtures/scandal-metadata.json
[searcher]:https://github.com/atom/scandal/blob/master/src/path-searcher.coffee
[donna]:https://github.com/atom/donna
[atomdoc]:https://github.com/atom/atomdoc
