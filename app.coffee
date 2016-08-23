{ BAD_REQUEST, UNAUTHORIZED } = require 'http-status-codes'
{ spawn } = require 'child_process'
bodyParser = require 'body-parser'
tmpWrite = require 'temp-write'
express = require 'express'
fs = require 'fs'
app = express()

app.get '/', (req, res) ->
  res.send 'service is up an running'

app.post '/', bodyParser.json(), (req, res) ->
  check = (token) -> # authentification
    if not token? or token != process.env.API_TOKEN
      return res.send UNAUTHORIZED, 'wrong token'
  decode = (base64) -> (Buffer.from base64, 'base64').toString 'ascii' if base64?
  argumentize = (options) -> # compile options to arguments
    (Object.keys(options).map (_) -> ['--'+_, options[_]]).reduce (_, __) -> _.concat __

  [token, options] = [check(req.body.token), argumentize(req.body.options)]
  [contents, footer] = [req.body.contents, req.body.footer].map (item) ->
    tmpWrite.sync decode(item), '.html'
  output = contents + '.pdf'

  args = (option, footer, content, output) -> # combine commandline arguments
    options.concat(['--footer-html', footer]).concat [contents, output]

  exec = spawn 'wkhtmltopdf', args(options, footer, contents, output)

  exec.on 'close', (code) ->
    res.setHeader('Content-type', 'application/pdf')
    stream = fs.createReadStream(output)
    stream.on 'open', () -> stream.pipe(res)
    stream.on 'error', (err) -> res.end(err)

app.listen process.env.PORT or 4000
