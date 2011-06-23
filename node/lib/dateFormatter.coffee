class DateFormatter
  constructor: (@d) ->

  rfc3339: () =>
    "#{this.year()}-#{twoDigits(this.month())}-#{twoDigits(this.date())}T#{twoDigits(this.hours())}:#{twoDigits(this.minutes())}:#{twoDigits(this.seconds())}#{this.timezoneOffset()}"

  year: () =>
    @d.getFullYear()
  month: () =>
    @d.getMonth() + 1
  date: () =>
    @d.getDate()
  hours: () =>
    @d.getHours()
  minutes: () =>
    @d.getMinutes()
  seconds: () =>
    @d.getSeconds()
  timezoneOffset: () =>
    hours = @d.getTimezoneOffset() / 60
    "-#{twoDigits(hours)}:00"

  twoDigits = (number) ->
    if number >= 10
      number
    else
      "0#{number}"

exports.DateFormatter = DateFormatter
