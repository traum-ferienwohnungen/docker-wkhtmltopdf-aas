chakram = require 'chakram'
Promise = require 'bluebird'
writeFile = Promise.promisify require('fs').writeFile
textract = Promise.promisify require('textract').fromFileWithPath
expect = chakram.expect
app = require("./app.coffee")
supertest = require("supertest")(app)
api = "http://localhost"

describe "PDF JSON REST API BDD Endpoint Integration Tests", ->

  it "should answer with 200 OK on plain get request", ->
    res = chakram.get api
    expect(res).to.have.status 200

  it "should answer with content-type html on plain get request", ->
    res = chakram.get api
    expect(res).to.have.header "content-type", /html/

  it "should answer with 200 OK on GET /metrics", ->
    res = chakram.get api + "/metrics"
    expect(res).to.have.status 200

  it "should answer with content-type text on GET /metrics", ->
    res = chakram.get api + "/metrics"
    expect(res).to.have.header "content-type", /text/

  it "should answer with 401 UNAUTHORIZED on plain post request", ->
    res = chakram.post api
    expect(res).to.have.status 401

  it "should answer with 401 UNAUTHORIZED on invalid token", ->
    res = chakram.post api, token: "this-is-a-invalid-token"
    expect(res).to.have.status 401

  it "should answer with 200 OK on valid token", ->
    res = chakram.post api, token: "travisci"
    expect(res).to.have.status 200

  it "should answer with content-type pdf on valid token", ->
    res = chakram.post api, token: "travisci"
    expect(res).to.have.header "content-type", /pdf/

  it "should answer with PDF containing
  contents and footer on valid token, contents and footer", ->
    content = new Buffer("<html>Hello World</html>").toString 'base64'
    footer = new Buffer("<html>Lorem ipsum</html>").toString 'base64'
    json = token: "travisci", contents: "#{content}", footer: "#{footer}"
    chakram.post api, json, {encoding: 'binary'}
    .then (res) -> writeFile 'test.pdf', res.body, 'binary'
    .then -> textract 'test.pdf'
    .then (text) ->
      expect(text).to.contain "Hello World"
      expect(text).to.contain "Lorem ipsum"

  it "should answer with 400 BAD_REQUEST on shell injection", ->
    json = token: "travisci",
    options: "margin-right": "20;killall -u $(whoami);"
    res = chakram.post api, json
    expect(res).to.have.status 400
    expect(res).to.have.not.header "content-type", /pdf/

  it "should answer with 400 BAD_REQUEST on invalid options", ->
    json = token: "travisci",
    options: "invalid-invalid": "42"
    res = chakram.post api, json
    expect(res).to.have.status 400
    expect(res).to.have.not.header "content-type", /pdf/

describe "PDF SERVICE Functional Code Coverage Tests", ->
  it "cover documentation", ->
    supertest
      .get("/") # documentation will be build in the docker container
      .expect(404) # so it is not available by default

  it "cover valid pdf generation", ->
    content = new Buffer("<html>Hello World</html>").toString 'base64'
    footer = new Buffer("<html>Lorem ipsum</html>").toString 'base64'
    json = token: "travisci", contents: "#{content}", footer: "#{footer}"
    supertest
    .post("/")
    .type('json')
    .send(json)
    .expect(200)

  it "cover invalid token", ->
    supertest
    .post("/")
    .type('json')
    .send({token: "invalid"})
    .expect(401)

  it "cover invalid arguments", ->
    supertest
    .post("/")
    .type('json')
    .send({token: "travisci", options: "invalid"})
    .expect(400)
