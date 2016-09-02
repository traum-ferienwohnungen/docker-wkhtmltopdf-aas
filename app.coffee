{ BAD_REQUEST, UNAUTHORIZED } = require 'http-status-codes'
prometheusMetrics = require("express-prom-bundle")()
{ spawn } = require 'child-process-promise'
promisePipe = require 'promisepipe'
bodyParser = require 'body-parser'
tmpWrite = require 'temp-write'
parallel = require 'bluebird'
app = require('express')()
_ = require 'lodash'
fs = require 'fs'

app.use(prometheusMetrics)

app.get '/', (req, res) ->
  res.send 'service is up an running'

app.post '/', bodyParser.json(), (req, res) ->
  if not req.body.token? or req.body.token != process.env.API_TOKEN
    return res.send UNAUTHORIZED, 'wrong token'

  decode = (base64) ->
    Buffer.from(base64, 'base64').toString 'ascii' if base64?

  decodeToFile = (content) ->
    tmpWrite decode(content), '.html'

  # compile options to arguments
  argumentize = (options) ->
    return [] if not options?
    _.flatMap options, (_,k) -> ['--'+k, options[k]]

  # async parallel file creations
  parallel.join tmpWrite('', '.pdf'), decodeToFile(req.body.footer),
  decodeToFile(req.body.contents), (output, footer, content) ->
    # combine arguments and call pdf compiler using shell
    # injection save function 'spawn' goo.gl/zspCaC
    spawn 'wkhtmltopdf', (argumentize(req.body.options)
      .concat(['--footer-html', footer], [content, output]))
    .then (result) ->
      res.setHeader 'Content-type', 'application/pdf'
      promisePipe fs.createReadStream(output), res
    .catch (err) ->
      res.send BAD_REQUEST, 'invalid arguments'

app.listen process.env.PORT or 5555
