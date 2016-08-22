{ BAD_REQUEST, UNAUTHORIZED } = require 'http-status-codes'
bodyParser = require 'body-parser'
tmpWrite = require 'temp-write'
express = require 'express'
fs = require 'fs'
app = express()

app.get '/', (req, res) ->
  res.send 'service is up an running'

app.post '/', bodyParser.json(), (req, res) ->
  check = (token) -> return res.send UNAUTHORIZED, 'wrong token' if not token? or token != 'travisci-test123456789'
  decode = (base64) -> (Buffer.from base64, 'base64').toString 'ascii' if base64?
  argumentize = (options) -> (Object.keys(options).map (_) -> ['--'+_, options[_]]).reduce (_, __) -> _.concat __
  [token, options] = [(check req.body.token), argumentize req.body.options]
  [contents, footer] = [req.body.contents, req.body.footer].map (item) -> tmpWrite.sync decode item
  output = contents + '.pdf'

  args = (option, footer, content, output) ->
    (options.concat ['--footer-html', footer]).concat [contents, output]

  {spawn} = require 'child_process'
  exec = spawn 'wkhtmltopdf', args(options, footer, contents, output)

  res.setHeader('Content-disposition', 'inline; filename="' + output + '"')
  res.setHeader('Content-type', 'application/pdf')

  stream = fs.createReadStream(output);
  steam.on 'open', () -> readStream.pipe(res)
  steam.on 'error', (err) -> res.end(err)

app.listen process.env.PORT or 4000
