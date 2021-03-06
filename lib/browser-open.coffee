{BufferedProcess} = require 'atom'
OS = require 'os'
StatusView = require './status-view'

MacChromeCmd = """
tell application "Google Chrome"
  "chrome"
  set winref to a reference to (first window whose title does not start with "Developer Tools - ")
  set winref's index to 1
  reload active tab of winref
end tell
"""

MacFirefoxCmd = """
tell application "Firefox"
  activate
  tell application "System Events" to keystroke "r" using command down
end tell
"""

MacSafariCmd = """
tell application "Safari"
  activate
  tell its first document
    set its URL to (get its URL)
  end tell
end tell
"""

Commands = {
  darwin: {
    firefox: MacFirefoxCmd,
    chrome: MacChromeCmd,
    safari: MacSafariCmd
  },
  linux: {
    firefox: ['search', '--sync', '--onlyvisible', '--class', 'firefox', 'key', 'F5', 'windowactivate'],
    chrome: ['search', '--sync', '--onlyvisible', '--class', 'firefox', 'key', 'F5', 'windowactivate']
  }
}

RunMacCmd = (BrowserCmd) ->
  new BufferedProcess({
    command: 'osascript'
    args: ['-e', BrowserCmd]
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
  })

RunLinuxCmd = (BrowserArgs) ->
  new BufferedProcess({
    command: 'xdotool'
    args: BrowserArgs
    stderr: (data) ->
      new StatusView(type: 'alert', message: data.toString())
  })


RunCmd = (browser) ->
  if OS.platform() == 'darwin'
    RunMacCmd(Commands['darwin'][browser])
  else if OS.platform() == 'linux' and browser isnt 'safari'
    RunLinuxCmd(Commands['linux'][browser])
  else
    new StatusView(type: 'alert', message: 'Unsupported platform')


BrowserOpen = ()->
  if(atom.config.get 'browser-refresh.firefox')
    RunCmd('firefox')
  if(atom.config.get 'browser-refresh.googleChrome')
    RunCmd('chrome')
  if(atom.config.get 'browser-refresh.safari')
    RunCmd('safari')

module.exports = BrowserOpen
