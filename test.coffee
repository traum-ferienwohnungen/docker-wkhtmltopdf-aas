chakram = require 'chakram'
Promise = require 'bluebird'
writeFile = Promise.promisify require('fs').writeFile
textract = Promise.promisify require('textract').fromFileWithPath
expect = chakram.expect
app = require("./app.coffee")
supertest = require("supertest")(app)
# supertest = require("supertest").agent(app.listen());

user = 'gooduser'
pass = 'secretpassword'
api = "http://"+user+":"+pass+"@127.0.0.1:80"

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

        it "401 UNAUTHORIZED on plain post request without user and pass", ->
            res = chakram.post "http://127.0.0.1:80"
            expect(res).to.have.status 401

        it "401 UNAUTHORIZED on plain post request on invalid user and pass", ->
            res = chakram.post "http://"+user+":wrongpass@127.0.0.1:80"
            expect(res).to.have.status 401

        it "200 OK on valid user and pass", ->
            res = chakram.post api
            expect(res).to.have.status 200

        it "content-type pdf on valid user and pass", ->
            res = chakram.post api
            expect(res).to.have.header "content-type", /pdf/

        it "PDF containing contents and footer, contents and footer", ->
            content = new Buffer("<html>Hello World</html>").toString 'base64'
            footer = new Buffer("<html>Lorem ipsum</html>").toString 'base64'
            json = contents: "#{content}", footer: "#{footer}", options: "disable-smart-shrinking":""
            chakram.post api, json, {encoding: 'binary'}
            .then (res) -> writeFile 'test.pdf', res.body, 'binary'
            .then -> textract 'test.pdf'
            .then (text) ->
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

    it "cover documentation", ->
        supertest
            .get("/") # documentation will be build in the docker container
            .auth(user, pass)
            .expect(404) # so it is not available by default

    it "cover valid pdf generation", ->
        content = new Buffer("<html>Hello World</html>").toString 'base64'
        footer = new Buffer("<html>Lorem ipsum</html>").toString 'base64'
        json = contents: "#{content}", footer: "#{footer}"
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
