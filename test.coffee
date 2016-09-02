chakram = require 'chakram'
expect = chakram.expect
api = "http://localhost"

describe "PDF API", ->
  it "should answer with 200 OK on plain get request", ->
    res = chakram.get api
    expect(res).to.have.status 200
    expect(res).to.have.header "content-type", /html/

  it "should answer with 200 OK on GET /metrics", ->
    res = chakram.get api + "/metrics"
    expect(res).to.have.status 200
    expect(res).to.have.header "content-type", /text/

  it "should answer with 401 UNAUTHORIZED on plain post request", ->
    res = chakram.post api
    expect(res).to.have.status 401

  it "should answer with 401 UNAUTHORIZED on invalid token", ->
    json = token: "this-is-a-invalid-token"
    res = chakram.post api, json
    expect(res).to.have.status 401

  it "should answer with 200 OK on valid token", ->
    json = token: "travisci"
    res = chakram.post api, json
    expect(res).to.have.status 200
    expect(res).to.have.header "content-type", /pdf/

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
