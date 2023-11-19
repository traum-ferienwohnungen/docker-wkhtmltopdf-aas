fileWrite = require 'fs-writefile-promise'
spawn = require('child_process').spawn
prometheusMetrics = require 'express-prom-bundle'
# { spawn } = require 'child-process-promise'
statusMonitor = require 'express-status-monitor'
{flow, map, compact, values, flatMap,
  toPairs, first, last, concat, remove,
  flatten, negate} = require 'lodash/fp'
health = require 'express-healthcheck'
promisePipe = require 'promisepipe'
bodyParser = require 'body-parser'
parallel = require 'bluebird'
tmp = require 'tmp-promise'
express = require 'express'
basicAuth = require('express-basic-auth')
helmet = require 'helmet'
log = require 'morgan'
fs = require 'fs'

require('dotenv').config({ silent: true })

app = express()

payload_limit = process.env.PAYLOAD_LIMIT or '20mb'

app.use helmet()
app.use '/healthcheck', health()
app.use '/', express.static(__dirname + '/documentation')
app.use(basicAuth({
  users: { [process.env.USER]: process.env.PASS },
  challenge: true,
  realm: 'Restricted Area'
}))
# don't work
#app.use(statusMonitor({
#  eventLoop: false
#}))

app.use prometheusMetrics()
app.use log('combined')

app.post '/', bodyParser.json(limit: payload_limit), ({body}, res) ->
  console.log 'Fichier reçu'

  # decode base64
  # comment être sur que le traitement est à 100% ?
  decode = (base64) ->
    Buffer.from(base64, 'base64').toString 'utf8' if base64?

  tmpFile = (ext) ->
    tmp.file(dir: '/tmp', postfix: '.' + ext).then (f) -> f.path

  tmpWrite = (content) ->
    tmpFile('html').then (f) -> fileWrite f, content if content?

  # compile options to arguments
  arg = flow(toPairs, flatMap((i) -> ['--' + first(i), last(i)]), compact)
  
  parallel.join tmpFile('pdf'),
  map(flow(decode, tmpWrite), [body.header, body.footer, body.contents])...,
  (output, header, footer, content) ->
    files = [['--header-html', header],
             ['--footer-html', footer],
             [content, output]]
    # combine arguments and call pdf compiler using shell
    # injection save function 'spawn' goo.gl/zspCaC
    console.log 'wkhtmltopdf', (arg(body.options).concat(flow(remove(negate(last)), flatten)(files)))


    # Create a ChildProcess object for the wkhtmltopdf command
    child = spawn 'wkhtmltopdf', (arg(body.options)
    .concat(flow(remove(negate(last)), flatten)(files)))

    # Wait for the wkhtmltopdf process to finish
    child.on 'exit', (code) ->
      if code is 0
        res.setHeader('Content-type', 'application/pdf');
        fs.createReadStream(output).pipe(res);
      else
        res.status(BAD_REQUEST = 400).send('invalid arguments');

    # Delete the temporary files
    # map fs.unlinkSync, compact([output, header, footer, content])

app.listen process.env.PORT or 6555
module.exports = app