chakram = require 'chakram'
expect = chakram.expect
api = "http://localhost"

describe "PDF API", () ->
  it "should answer with 200 OK on plain get request", () ->
    response = chakram.get(api)
    expect(response).to.have.status(200)
    expect(response).to.have.header("content-type", /html/)

  it "should answer with 401 UNAUTHORIZED on plain post request", () ->
    response = chakram.post(api)
    expect(response).to.have.status(401)

  it "should answer with 401 UNAUTHORIZED on invalid token", () ->
    json = token: "this-is-a-invalid-token"
    response = chakram.post(api, json)
    expect(response).to.have.status(401)

  it "should answer with 200 OK on valid token", () ->
    json = token: "travisci"
    response = chakram.post(api, json)
    expect(response).to.have.status(200)
    expect(response).to.have.header("content-type", /pdf/)

  it "should answer with 400 BAD_REQUEST on shell injection", () ->
    json = token: "travisci",
    options:
      "margin-right": "20;killall -u $(whoami);",
      "margin-bottom;rm -rf /;": "30;"
    response = chakram.post(api, json)
    expect(response).to.have.status(400)
    expect(response).to.have.not.header("content-type", /pdf/)

  it "should answer with 400 BAD_REQUEST on invalid options", () ->
    json = token: "travisci",
    options: "invalid-invalid": "42"
    response = chakram.post(api, json)
    expect(response).to.have.status(400)
    expect(response).to.have.not.header("content-type", /pdf/)
