fileWrite = require 'fs-writefile-promise'
{ spawn }           = require 'child-process-promise'
prometheusMetrics = require 'express-prom-bundle'
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
app.use(statusMonitor({
  eventLoop: false
}))

app.use prometheusMetrics()
app.use log('combined')

app.post '/', bodyParser.json(limit: payload_limit), ({body}, res) ->
  console.log 'Fichier reçu'

  # decode base64
  # comment être sur que le traitement est à 100% ?
  decode = (base64) -> 
    Buffer.from(base64, 'base64').toString 'utf8' if base64?
  tmpFile = (ext) -> 
    (await tmp.file(dir: '/tmp', postfix: '.' + ext)).path
  tmpWrite = (content) -> 
    fileWrite await tmpFile('html'), content if content?

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
    spawn 'wkhtmltopdf', (arg(body.options)
    .concat(flow(remove(negate(last)), flatten)(files)))
    .then ->
      res.setHeader 'Content-type', 'application/pdf'
      promisePipe fs.createReadStream(output), res
    .catch -> res.status(BAD_REQUEST = 400).send 'invalid arguments'
    .then -> map fs.unlinkSync, compact([output, header, footer, content])

app.listen process.env.PORT or 5555
module.exports = app