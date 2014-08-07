# Grappa: Biscotto metadata digest

Converts [metadata][metadata] from [biscotto][biscotto] to an intermediate format.

## Usage

```coffee
{digest} = require 'grappa'

metadata = # get from biscotto
grappaFormat = digest(metadata)
```

## Output

Here is an example output based on [Scandal::PathSearcher][searcher]:

```js
{
  "classes": {
    "PathSearcher": {
      "name": "PathSearcher",
      "filename": "./src/path-searcher.coffee",
      "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L80",
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
          "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L89",
          "visibility": "Public",
          "summary": "Construct a {PathSearcher} object.",
          "description": "Construct a {PathSearcher} object.",
          "arguments": {
            "description": "",
            "list": [
              {
                "children": [
                  {
                    "name": "maxLineLength",
                    "description": "{Number} default `100`; The max length of the `lineText`  component in a results object. `lineText` is the context around the matched text.",
                    "type": "Number"
                  },
                  {
                    "name": "wordBreakRegex",
                    "description": "{RegExp} default `/[ \\r\\n\\t;:?=&\\/]/`;  Used to break on a word when finding the context for a match. ",
                    "type": "RegExp"
                  }
                ],
                "name": "options",
                "description": "{Object}",
                "type": "Object"
              }
            ]
          }
        },
        {
          "name": "searchPaths",
          "sectionName": "Searching",
          "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L110",
          "visibility": "Public",
          "summary": "Search an array of paths.",
          "description": "Search an array of paths.\n\nWill search with a {ChunkedExecutor} so as not to immediately exhaust all\nthe available file descriptors. The {ChunkedExecutor} will execute 20 paths\nconcurrently.",
          "arguments": {
            "description": "",
            "list": [
              {
                "name": "regex",
                "description": "{RegExp} search pattern",
                "type": "RegExp"
              },
              {
                "name": "paths",
                "description": "{Array} of {String} file paths to search",
                "type": "Array"
              },
              {
                "children": [
                  {
                    "name": "results",
                    "description": "{Array} of Result objects in the format specified above;  null when there are no results",
                    "type": "Array"
                  },
                  {
                    "name": "errors",
                    "description": "{Array} of errors; null when there are no errors. Errors will  be js Error objects with `message`, `stack`, etc. ",
                    "type": "Array"
                  }
                ],
                "name": "doneCallback",
                "description": "called when searching the entire array of paths has finished",
                "type": null
              }
            ]
          }
        },
        {
          "name": "searchPath",
          "sectionName": "Searching",
          "srcUrl": "https://github.com/atom/scandal/blob/v1.0.1/src/path-searcher.coffee#L136",
          "visibility": "Public",
          "summary": "Search a file path for a regex",
          "description": "Search a file path for a regex",
          "arguments": {
            "description": "",
            "list": [
              {
                "name": "regex",
                "description": "{RegExp} search pattern",
                "type": "RegExp"
              },
              {
                "name": "filePath",
                "description": "{String} file path to search",
                "type": "String"
              },
              {
                "children": [
                  {
                    "name": "results",
                    "description": "{Array} of Result objects in the format specified above;  null when there are no results",
                    "type": "Array"
                  },
                  {
                    "name": "error",
                    "description": "{Error}; null when there is no error ",
                    "type": "Error"
                  }
                ],
                "name": "doneCallback",
                "description": "called when searching the entire array of paths has finished",
                "type": null
              }
            ]
          }
        }
      ],
      "visibility": "Public",
      "summary": "Will search through paths specified for a regex.",
      "description": "Will search through paths specified for a regex.\n\nLike the {PathScanner} the {PathSearcher} keeps no state. You need to consume\nresults via the done callbacks or events.\n\nFile reading is fast and memory efficient. It reads in 10k chunks and writes\nover each previous chunk. Small object creation is kept to a minimum during\nthe read to make light use of the GC.",
      "events": {
        "description": "",
        "list": [
          {
            "children": [
              {
                "name": "results",
                "description": "{Object} in the result format: \n```js\n{\n  \"path\": \"/Some/path.txt\",\n  \"matches\": [{\n    \"matchText\": \"Text\",\n    \"lineText\": \"Text in this file!\",\n    \"lineTextOffset\": 0,\n    \"range\": [[9, 0], [9, 4]]\n  }]\n}\n```",
                "type": "Object"
              }
            ],
            "name": "results-found",
            "description": "Fired when searching for a each path has been completed  and matches were found.",
            "type": null
          },
          {
            "children": [
              {
                "name": "filePath",
                "description": "path to the file nothing was found in `\"/Some/path.txt\"`",
                "type": null
              }
            ],
            "name": "results-not-found",
            "description": "Fired when searching for a path has finished and _no_  matches were found.",
            "type": null
          },
          {
            "children": [
              {
                "name": "error",
                "description": "{Error} object",
                "type": "Error"
              }
            ],
            "name": "file-error",
            "description": "Fired when an error occurred when searching a file. Happens  for example when a file cannot be opened.",
            "type": null
          }
        ]
      },
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

[metadata]:https://github.com/atom/grappa/blob/master/spec/fixtures/scandal-metadata.json
[searcher]:https://github.com/atom/scandal/blob/master/src/path-searcher.coffee
[biscotto]:https://github.com/atom/biscotto/
