{ BAD_REQUEST, UNAUTHORIZED } = require 'http-status-codes'
{ spawn } = require 'child_process'
bodyParser = require 'body-parser'
tmpWrite = require 'temp-write'
express = require 'express'
_ = require 'underscore'
fs = require 'fs'
app = express()

app.get '/', (req, res) ->
  res.send 'service is up an running'

app.post '/', bodyParser.json(), (req, res) ->
  if not req.body.token? or req.body.token != process.env.API_TOKEN
    return res.send UNAUTHORIZED, 'wrong token'

  decode = (base64) ->
    (Buffer.from base64, 'base64').toString 'ascii' if base64?

  decodeToFile = (content) ->
    tmpWrite decode(content), '.html'

  argumentize = (options) -> # compile options to arguments
    return [] if not options?
    _.flatten _.map options, (_,k) -> ['--'+k, options[k]]

  (tmpWrite '', '.pdf').then (output) -> # non blocking file creations
    (decodeToFile req.body.footer).then (footer) ->
      (decodeToFile req.body.contents).then (content) ->
        exec = spawn 'wkhtmltopdf',
          argumentize(req.body.options)
          .concat(['--footer-html', footer], [content, output])
        exec.on 'close', (code) ->
          res.setHeader('Content-type', 'application/pdf')
          stream = fs.createReadStream(output)
          stream.on 'open', () -> stream.pipe(res)
          stream.on 'error', (err) -> res.end(err)

app.listen process.env.PORT or 5555
