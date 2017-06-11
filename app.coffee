prometheusMetrics = require 'express-prom-bundle'
{spawn} = require 'child-process-promise'
status = require 'express-status-monitor'
health = require 'express-healthcheck'
promisePipe = require 'promisepipe'
bodyParser = require 'body-parser'
tmpWrite = require 'temp-write'
tmpFile = require 'tempfile'
parallel = require 'bluebird'
express = require 'express'
auth = require 'http-auth'
helmet = require 'helmet'
log = require 'morgan'
_ = require 'lodash'
fs = require 'fs'
app = express()

payload_limit = process.env.PAYLOAD_LIMIT or '50mb'

basic = auth.basic {}, (user, pass, cb) ->
  cb(user == process.env.USER && pass == process.env.PASS)

app.use helmet()
app.use '/healthcheck', health()
app.use '/', express.static(__dirname + '/documentation')
app.use auth.connect(basic)
app.use status()
app.use prometheusMetrics()
app.use log('combined')
app.use bodyParser.json({limit: payload_limit})
app.use bodyParser.urlencoded({limit: payload_limit, extended: true})

app.post '/', bodyParser.json(), (req, res) ->

  decode = (base64) ->
    new Buffer.from(base64, 'base64').toString 'utf8' if base64?

  decodeWrite = _.flow(decode, _.partialRight tmpWrite, '.html')

  # compile options to arguments
  argumentize = (options) ->
    return [] unless options?
    _.flatMap options, (val, key) ->
      if val then ['--' + key, val]
      else ['--' + key]

  # async parallel file creations
  parallel.join tmpFile('.pdf'),
  decodeWrite(req.body.header),
  decodeWrite(req.body.footer),
  decodeWrite(req.body.contents),
  (output, header, footer, content) ->
    # combine arguments and call pdf compiler using shell
    # injection save function 'spawn' goo.gl/zspCaC
    spawn 'wkhtmltopdf', (argumentize(req.body.options)
    .concat(['--header-html', header], ['--footer-html', footer], [content, output]))
    .then ->
      res.setHeader 'Content-type', 'application/pdf'
      promisePipe fs.createReadStream(output), res
    .catch ->
      res.status(BAD_REQUEST = 400).send 'invalid arguments'

app.listen process.env.PORT or 5555
module.exports = app
