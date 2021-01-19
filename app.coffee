fileWrite = require 'fs-writefile-promise'
prometheusMetrics = require 'express-prom-bundle'
{spawn} = require 'child-process-promise'
status = require 'express-status-monitor'
{flow, map, compact, values, flatMap,
  toPairs, first, last, concat, remove,
  flatten, negate} = require 'lodash/fp'
health = require 'express-healthcheck'
promisePipe = require 'promisepipe'
bodyParser = require 'body-parser'
parallel = require 'bluebird'
tmp = require 'tmp-promise'
express = require 'express'
auth = require 'http-auth'
helmet = require 'helmet'
log = require 'morgan'
fs = require 'fs'
app = express()

payload_limit = process.env.PAYLOAD_LIMIT or '100kb'

basic = auth.basic {}, (user, pass, cb) ->
  cb(user == process.env.USER && pass == process.env.PASS)

app.use helmet()
app.use '/healthcheck', health()
app.use '/', express.static(__dirname + '/documentation')
app.use auth.connect(basic)
app.use status()
app.use prometheusMetrics()
app.use log('combined')

app.post '/', bodyParser.json(limit: payload_limit), ({body}, res) ->

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
    files = [['--header-html', body.header],
             ['--footer-html', body.footer],
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
