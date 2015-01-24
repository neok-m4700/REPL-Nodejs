fs = require 'fs'
child_process = require 'child_process'
#read_line = require 'read_line'
Format = require './ReplFormat.coffee'

class Repl

    processCmd:()->
      #console.log('2')
      if(@processing)
        process.stdout.write(@prompt)
      if(@cmdQueue.length > 0)
        @processing = true
        cmd = @cmdQueue.shift()
        @print += cmd
        @replProcess.stdin.write(cmd)
      else
        @processing = false

    processOutputData:(data) ->
      #console.log(@prompt)
      @print += ""+data
      process.stdout.write(@print)
      @print = ""
      @processCmd()
      #@prompt = true


    closeRepl:(code) ->
      console.log('child process exited with code ' + code)

    writeInRepl:(cmd) ->
      #console.log(s)
      #@replProcess.stdin.write(s)
      @cmdQueue.push(cmd)
      if(!@processing)
        @processCmd()

    constructor:(r_format) ->
      self = this
      @processing = true
      cmd = r_format.cmd
      args = r_format.args
      @prompt = r_format.prompt
      @endSequence = r_format.endSequence
      @print = ""
      @cmdQueue =   new Array()
      @replProcess = child_process.spawn(cmd, args)
      @replProcess.stdout.on('data', (data)->self.processOutputData(data))
      @replProcess.stderr.on('data', (data)->self.processErrorData(data))
      @replProcess.on('close', ()->self.closeRepl())
      process.stdout.write(@print)

ocaml = new Format.ReplFormat()
myrepl = new Repl(ocaml)
myrepl.writeInRepl("let a l = match l with\n| _ -> true;;\n")
#myrepl.writeInRepl("| _ -> true;;\n")
myrepl.writeInRepl("let _ = 3*2;;\n")
