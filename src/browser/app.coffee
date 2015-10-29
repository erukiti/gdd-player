# Copyright 2015 SASAKI, Shunsuke. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

app = require 'app'
BrowserWindow = require 'browser-window'
Menu = require 'menu'
ipc = require 'ipc'
fs = require 'fs'
probe = require 'node-ffprobe'
Tray = require 'tray'

$ = require('nodobjc')
$.import('Foundation')
$.import('Cocoa')

ipc.on 'log', (ev, arg) =>
  # console.dir ev
  console.log arg


appIcon = null

app.on 'window-all-closed', ->
  app.quit()

openBrowser = (packet) ->
  console.dir packet
  win = new BrowserWindow {
    frame: false
    x: 0
    y: 0
    width: packet.width
    height: packet.height
    transparent: true
    'always-on-top': true
  }
  win.loadUrl "file://#{__dirname}/../renderer/index.html"
  win.webContents.on 'did-finish-load', =>

    appIcon = new Tray('images/rabbit_icon.png')
    contextMenu = Menu.buildFromTemplate([
      {label: '終了', accelerator: 'Command+Q', click: => app.quit()}
    ])
    appIcon.setContextMenu contextMenu
    appIcon.setToolTip "GDD player: #{packet.path}"

    $.NSApplication('sharedApplication')('windows')('objectAtIndex', 0)('setIgnoresMouseEvents', $.YES)

    win.webContents.send 'open', packet
  win

app.on 'ready', ->
  process.argv[2..].forEach (path) ->
    probe path, (err, data) =>
      if err
        console.dir err
      else
        width = 0
        height = 0
        data.streams.forEach (stream) =>
          if stream.width && stream.height
            width = stream.width
            height = stream.height

        console.log "#{path}: #{width}, #{height}"

        if width && height
          openBrowser
            path: path
            width: width
            height: height
