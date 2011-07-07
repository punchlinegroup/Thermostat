spawn = require('child_process').spawn
RRD = require('./rrd/rrd').RRD
fs = require('fs')
http = require('http')
GoogleCalendar = require('./googleCalendar').GoogleCalendar

class Collector
  constructor: (@rrdFile, port) ->
    @rrd = new RRD(rrdFile)
    this.collectData(@rrd)
    this.serveRRDData(port)
    @googleCalendar = new GoogleCalendar

  collectData: (rrd) =>
    serial = spawn('python', ['serial_proxy.py', usbDev()])
    serial.stdout.on('data', (data) ->
      data = data.toString()
      console.log(data)
      parsedLine = parseTemperatureLine(data)
      if parsedLine.currentTemp?
        console.log(" - #{parsedLine.currentTemp}, #{parsedLine.state}")
        rrd.update new Date, [parsedLine.currentTemp, parsedLine.targetTemp, parsedLine.state], printError
    )

    serial.stderr.on('data', (data) ->
      console.log('stderr: ' + data)
    )

    setInterval () =>
      @googleCalendar.getCurrent (current) ->
        console.log("updating with #{current.temperature}")
        serial.stdin.write("#{String.fromCharCode(current.temperature)}\n")
    , 10000

  serveRRDData: (port) ->
    http.createServer((req, res) =>
      res.writeHead(200, {'Content-Type': 'text/xml'})
      @rrd.dump (err, xml) ->
        res.end xml
    ).listen(port, "0.0.0.0")
    console.log("Listening for RRD data requests on port #{port}")

  parseTemperatureLine = (string) ->
    result = string.split(" ")
    currentTemp = result[0]
    targetTemp = result[1]
    state = result[2]

    if currentTemp.match("^[0-9.]*$")
      console.log state
      if state.match(/heat-on/)
        s = 1
      else if state.match(/ac-on/)
        s = -1
      else
        s = 0
      return { currentTemp: currentTemp, targetTemp: targetTemp, state: s }
    else
      return {}

  printError = (err) ->
    console.log(" - #{err}") if err?

  usbDev = () ->
    fs.readFileSync('./config/usbDev').toString().replace(/(\n|\r)+$/, '')

exports.Collector = Collector
