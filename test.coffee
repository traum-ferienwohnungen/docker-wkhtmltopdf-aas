chakram = require 'chakram'
expect = chakram.expect

describe "PDF API", () ->
  it "should answer with 200 OK on plain get request", () ->
    response = chakram.get("http://localhost")
    expect(response).to.have.status(200)
    expect(response).to.have.header("content-type", /html/)

  it "should answer with 401 UNAUTHORIZED on plain post request", () ->
    response = chakram.post("http://localhost")
    expect(response).to.have.status(401)

  it "should answer with 401 UNAUTHORIZED on invalid token", () ->
    json = { token: "this-is-a-invalid-token", };
    response = chakram.post("http://localhost", json)
    expect(response).to.have.status(401)

  it "should answer with 200 OK on valid token", () ->
    json = { token: "travisci", };
    response = chakram.post("http://localhost", json)
    expect(response).to.have.status(200)
    expect(response).to.have.header("content-type", /pdf/)
