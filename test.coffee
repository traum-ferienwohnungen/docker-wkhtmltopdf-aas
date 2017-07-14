chakram = require 'chakram'
Promise = require 'bluebird'
writeFile = Promise.promisify require('fs').writeFile
textract = Promise.promisify require('textract').fromFileWithPath
expect = chakram.expect
app = require("./app.coffee")
supertest = require("supertest")(app)

user = 'gooduser'
pass = 'secretpassword'
api = "http://"+user+":"+pass+"@127.0.0.1:80"
b64 = (s) -> new Buffer(s).toString 'base64'

Curl = require( 'node-libcurl' ).Curl
curl = new Curl()

# this is a big html site result in 29 pdf pages ( bigger than 100 kb )
testurl = 'http://demo.borland.com/testsite/stadyn_largepagewithimages.html'
curl.setOpt( 'URL', testurl )
curl.setOpt( 'FOLLOWLOCATION', true )

bigBody = new Promise((resolve) ->
  curl.perform()
  curl.on 'end', ( statusCode, body, headers ) ->
    resolve(body)
    this.close()
)

describe "PDF JSON REST API BDD Endpoint Integration Tests", ->

  describe "API should answer with", ->
    it "200 OK on plain get request", ->
      res = chakram.get api
      expect(res).to.have.status 200

    it "content-type html on plain get request", ->
      res = chakram.get api
      expect(res).to.have.header "content-type", /html/

    it "200 OK on GET /metrics", ->
      res = chakram.get api + "/metrics"
      expect(res).to.have.status 200

    it "content-type text on GET /metrics", ->
      res = chakram.get api + "/metrics"
      expect(res).to.have.header "content-type", /text/

    it "401 UNAUTHORIZED on empty user and pass", ->
      res = chakram.post "http://127.0.0.1:80"
      expect(res).to.have.status 401

    it "401 UNAUTHORIZED on invalid user and pass", ->
      res = chakram.post "http://"+user+":wrongpass@127.0.0.1:80"
      expect(res).to.have.status 401

    it "valid PDF content", ->
      content = b64 "<html>Hello</html>"
      json = contents: "#{content}"
      chakram.post api, json, {encoding: 'binary'}
      .then (res) -> writeFile '/tmp/test-content.pdf',
        res.body, 'binary'
      .then -> textract '/tmp/test-content.pdf'
      .then (text) ->
        expect(text).to.contain "Hello"

    it "valid PDF with big payload", ->
      # this test takes a litte bit longer due to big payload
      bigBody.then (b) ->
        content = b64 b
        json = contents: "#{content}"
        chakram.post api, json, {encoding: 'binary'}
        .then (res) -> writeFile '/tmp/test-content-big.pdf',
          res.body, 'binary'
        .then -> textract '/tmp/test-content-big.pdf'
        .then (text) ->
          expect(text).to.contain "generated payments were canceled"

    it "valid PDF content and header", ->
      header = b64 "<!DOCTYPE html><html>Bob</html>"
      content = b64 "<html>Schwammkopf</html>"
      json = header: "#{header}", contents: "#{content}"
      chakram.post api, json, {encoding: 'binary'}
      .then (res) -> writeFile '/tmp/test-content-header.pdf',
        res.body, 'binary'
      .then -> textract '/tmp/test-content-header.pdf'
      .then (text) ->
        expect(text).to.contain "Bob"
        expect(text).to.contain "Schwammkopf"

    it "valid PDF content and footer", ->
      content = b64 "<html>stackoverflow</html>"
      footer = b64 "<html>stack smashing</html>"
      json = contents: "#{content}", footer: "#{footer}"
      chakram.post api, json, {encoding: 'binary'}
      .then (res) -> writeFile '/tmp/test-content-footer.pdf',
        res.body, 'binary'
      .then -> textract '/tmp/test-content-footer.pdf'
      .then (text) ->
        expect(text).to.contain "stackoverflow"
        expect(text).to.contain "stack smashing"

    it "valid PDF containing header, content and footer", ->
      header = b64 "<!DOCTYPE html><html>Header</html>"
      content = b64 "<html>Hello World</html>"
      footer = b64 "<html>Lorem ipsum</html>"
      json = header: "#{header}", contents: "#{content}",
      footer: "#{footer}", options: "disable-smart-shrinking":"",
      "margin-top":"20mm", "header-spacing":"10"
      chakram.post api, json, {encoding: 'binary'}
      .then (res) -> writeFile '/tmp/test.pdf', res.body, 'binary'
      .then -> textract '/tmp/test.pdf'
      .then (text) ->
        expect(text).to.contain "Header"
        expect(text).to.contain "Hello World"
        expect(text).to.contain "Lorem ipsum"

    it "should answer with 400 BAD_REQUEST on shell injection", ->
      json = options: "margin-right": "20;killall -u $(whoami);"
      res = chakram.post api, json
      expect(res).to.have.status 400
      expect(res).to.have.not.header "content-type", /pdf/

    it "should answer with 400 BAD_REQUEST on invalid options", ->
      json = options: "invalid-invalid": "42"
      res = chakram.post api, json
      expect(res).to.have.status 400
      expect(res).to.have.not.header "content-type", /pdf/

describe "PDF SERVICE Functional Code Coverage Tests", ->

  before ->
    process.env.USER = user
    process.env.PASS = pass

  # documentation will be build in the docker container
  # so it is not available by default
  it "cover documentation", ->
    supertest
      .get("/")
      .auth(user, pass)
      .expect(404)

  # also covers the disable smart shrinking -> option without param
  it "cover valid content and footer pdf generation", ->
    content = b64 "<html>Hello World</html>"
    footer = b64 "<html>Lorem ipsum</html>"
    json = contents: "#{content}", footer: "#{footer}",
    options: "disable-smart-shrinking":""
    supertest
      .post("/")
      .auth(user, pass)
      .type('json')
      .send(json)
      .expect(200)

  it "cover valid content and header pdf generation", ->
    header = b64 "<html>Hello World</html>"
    content = b64 "<html>Hello World</html>"
    json = contents: "#{content}", header: "#{header}"
    supertest
      .post("/")
      .auth(user, pass)
      .type('json')
      .send(json)
      .expect(200)

  it "cover invalid user and pass", ->
    supertest
      .post("/")
      .auth(user, "wrongpass")
      .type('json')
      .expect(401)

  it "cover invalid arguments", ->
    supertest
      .post("/")
      .auth(user, pass)
      .type('json')
      .send({options: "invalid"})
      .expect(400)
