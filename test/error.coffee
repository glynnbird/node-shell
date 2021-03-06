
should = require 'should'
shell = require '../lib/Shell'
NullStream = require '../lib/NullStream'
router = require '../lib/plugins/router'
error =  require '../lib/plugins/error'

describe 'plugin error', ->
  it 'should print a thrown error', (next) ->
    stdout = new NullStream
    out = ''
    stdout.on 'data', (data) ->
      out += data
    app = shell
      command: 'test error'
      stdin: new NullStream
      stdout: stdout
    app.configure ->
      app.use router shell: app
      app.use error shell: app
    app.cmd 'test error', (req, res) ->
      should.not.exist true
    app.on 'quit', ->
      out.should.match /AssertionError/ 
      next()
  it 'should emit thrown error', (next) ->
    app = shell
      command: 'test error'
      stdin: new NullStream
      stdout: new NullStream
    app.configure ->
      app.use router shell: app
      app.use error shell: app
    app.cmd 'test error', (req, res) ->
      should.not.exist true
    app.on 'error', (err) ->
      err.name.should.eql 'AssertionError'
      next()
  it 'router should graph error from previous route and emit it', (next) ->
    app = shell
      command: 'test error'
      stdin: new NullStream
      stdout: new NullStream
    app.configure ->
      app.use router shell: app
    app.cmd 'test error', (req, res, n) ->
      n new Error 'My error'
    app.on 'error', (err) ->
      err.message.should.eql 'My error'
      next()
  
