fs = require 'fs'
{digest} = require '../src/digester'

getArgs = ->
  optimist = require('optimist')
    .usage("""
    Usage: $0 [options] [source_files]
    """)
    .options('o',
      alias: 'output-file'
      describe: 'The output directory'
      default: './api.json'
    )
    .options('i',
      alias: 'input-file'
      describe: 'The output directory'
      default: './metadata.json'
    )
    .options('h',
      alias: 'help'
      describe: 'Show the help'
    )
  argv = optimist.argv

  if argv.h
    console.log(optimist.help())
  else
    input: argv.i
    output: argv.o

main = ->
  return unless args = getArgs()

  metadata = JSON.parse(fs.readFileSync(args.input, 'utf8'))
  json = digest(metadata)
  fs.writeFileSync(args.output, JSON.stringify(json, null, '  '))

module.exports = {main}
