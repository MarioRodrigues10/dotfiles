config.load_autoconfig(False)

############################### boring settings ###############################

c.content.autoplay = True
autoplay_domains = ["youtube.com"]
try:
   with open(config.configdir / "secret_autoplay_false", "r") as saf:
      autoplay_domains += [l.strip() for l in saf if l.strip()]
except FileNotFoundError:
   pass
for dom in autoplay_domains:
   with config.pattern('*://*.'+dom+'/*') as p:
      p.content.autoplay = False

for dom in ["https://mail.google.com?extsrc=mailto&url=%25s", "https://calendar.google.com?cid=%25s"]:
   with config.pattern(dom) as p:
      p.content.register_protocol_handler = True

c.content.geolocation = False
c.content.media.audio_video_capture = False
c.content.media.audio_capture = False
c.content.media.video_capture = False
c.content.notifications.enabled = False
c.content.cookies.accept = 'no-3rdparty'
c.content.blocking.whitelist = ['thepiratebay.org']
c.content.javascript.can_access_clipboard = True
c.downloads.open_dispatcher = 'rifle'
c.downloads.position = 'bottom'
c.downloads.location.remember = False
c.downloads.location.suggestion = "both"
c.downloads.remove_finished = 5000
c.downloads.location.prompt = False
c.editor.command = ['emacsclient', '-c', '-e', '(find-file "{file}")', '-e', '(goto-line {line})', '-e', '(move-to-column {column0})']
c.scrolling.bar = 'always'
c.statusbar.widgets = ['keypress', 'url', 'history', 'tabs', 'progress']
c.tabs.background = True
c.tabs.last_close = 'default-page'
c.tabs.select_on_remove = 'last-used'
c.tabs.new_position.stacking = False
c.url.default_page = str(config.configdir / "startpage.html")
c.url.start_pages = c.url.default_page
c.colors.messages.error.bg = "#b22222"

c.url.searchengines = {
   'DEFAULT': 'https://duckduckgo.com/?q={}'
}
with open(config.configdir / "engines", "r") as f:
   for line in f:
      line = line.strip()
      if line == "" or line.startswith("#"):
         continue
      middle = line.index(" ")
      key = line[:middle]
      url = line[middle+1:]
      if key == "DEFAULT":
         url = c.url.searchengines[url]
      c.url.searchengines[key] = url

c.window.title_format = '{perc}{current_title}'
c.zoom.default = '100%'
c.zoom.levels = ['25%', '33%', '50%', '60%', '67%', '75%', '90%', '100%', '110%', '125%', '150%', '175%', '200%', '250%', '300%', '400%', '500%']
c.fonts.default_family = ["DejaVu Sans Mono"]
c.fonts.prompts = "default_size default_family"
c.completion.open_categories = ["quickmarks", "bookmarks", "history"]
c.hints.selectors["magnets"] = ["[href^=\"magnet:\"]"]

################################ emacs bindings ###############################

# Bindings for normal mode

# disable insert mode completely
c.input.media_keys = False
c.input.insert_mode.auto_enter = False
c.input.insert_mode.auto_leave = False
c.input.insert_mode.plugins = False

# Forward unbound keys
c.input.forward_unbound_keys = "all"

ESC_BIND = 'clear-keychain ;; search ;; fullscreen --leave'

c.bindings.default['normal'] = {}
c.bindings.commands['normal'] = {
   # Navigation
   '<ctrl-j>':      'scroll-px 0 40',
   '<ctrl-k>':      'scroll-px 0 -40',
   '<ctrl-d>':      'scroll-page 0 0.5',
   '<ctrl-u>':      'scroll-page 0 -0.5',
   '<alt-g>':       'scroll-to-perc 0',
   '<alt-shift-g>': 'scroll-to-perc',

   # Commands
   '<ctrl-r>':       'reload',
   '<ctrl-shift-r>': 'reload -f',

   '<alt-x>':          'set-cmd-text :',
   '<ctrl-x>k':        'tab-close',
   '<ctrl-x>h':        'set-cmd-text -s :help',
   '<ctrl-x>d':        'download-clear',
   '<alt-c>':          'clear-messages',
   '<alt-m>':          'messages --tab',
   '<ctrl-x><ctrl-r>': 'config-source;; message-info "reloaded config"',
   '<ctrl-x>r':        'tab-close ;; undo',
   '<ctrl-2>':         'tab-close ;; undo',
   '<ctrl-x><ctrl-x>': 'fake-key <ctrl-x>',
   '<ctrl-x>i':        'devtools window',
   '<ctrl-x>v':        'mode-enter passthrough',

   # searching
   '<ctrl-s>': 'set-cmd-text /',
   # '<ctrl-r>': 'set-cmd-text ?',

   # bookmarks
   '<ctrl-x><ctrl-b>': 'spawn --userscript bookmark_list',
   '<ctrl-x>b': 'bookmark-add',

   # zoom
   '<ctrl-+>': 'zoom-in',
   '<ctrl-->': 'zoom-out',
   '<ctrl-0>': 'zoom 100',

   # marks
   # '<ctrl-m>':  'enter-mode set_mark',
   # '<ctrl-\'>': 'enter-mode jump_mark',

   # hinting
   '<ctrl-f>': 'hint all',
   '<alt-f>':  'hint all tab-bg',
   # '<alt-a>': 'hint all download',

   # history
   '<ctrl-l>': 'forward',
   '<ctrl-h>': 'back',

   # tabs
   '<alt-j>':   'tab-next',
   '<ctrl-3>':  'tab-next',
   '<alt-k>':   'tab-prev',
   '<ctrl-w>':  'tab-close',
   '<ctrl-e>':  'tab-close --next',
   '<ctrl-t>':  'open -t',
   '<ctrl-x>u': 'undo',

   # windows
   '<ctrl-shift-n>': 'open -p',

   # open links
   '<ctrl-o>':       'set-cmd-text -s :open',
   '<ctrl-shift-o>': 'set-cmd-text -s :open -t',
   '<alt-o>':        'set-cmd-text -s :open -t',
   '<ctrl-x>o':      'set-cmd-text :open {url:pretty}',

   '<ctrl-b>':       'set-cmd-text -s :quickmark-load',
   '<ctrl-shift-b>': 'set-cmd-text -s :quickmark-load -t',
   '<alt-b>':        'set-cmd-text -s :quickmark-load -t',

   # clipboard
   '<ctrl-p>':       'open -- {clipboard}',
   '<ctrl-shift-p>': 'open -t -- {clipboard}',
   '<alt-p>':        'open -t -- {clipboard}',
   '<ctrl-y>':       'yank',
   '<alt-y>':        'spawn --userscript --output-messages save_url',
   '<alt-shift-y>':  'spawn --userscript --output-messages save_url t',

   # macro
   # '<ctrl-x>q': 'record-macro',
   # '<ctrl-x>@': 'run-macro',

   # editing
   # '<ctrl-f>': 'fake-key <Right>',
   # '<ctrl-b>': 'fake-key <Left>',
   # '<ctrl-a>': 'fake-key <Home>',
   # '<ctrl-e>': 'fake-key <End>',
   # '<ctrl-n>': 'fake-key <Down>',
   # '<ctrl-p>': 'fake-key <Up>',
   # '<alt-f>': 'fake-key <Ctrl-Right>',
   # '<alt-b>': 'fake-key <Ctrl-Left>',
   # '<ctrl-d>': 'fake-key <Delete>',
   # '<alt-d>': 'fake-key <Ctrl-Delete>',
   # '<alt-backspace>': 'fake-key <Ctrl-Backspace>',
   # '<ctrl-w>': 'fake-key <Ctrl-backspace>',
   # '<ctrl-y>': 'insert-text {primary}',

   # Numbers
   # https://github.com/qutebrowser/qutebrowser/issues/4213
   '1': 'fake-key 1',
   '2': 'fake-key 2',
   '3': 'fake-key 3',
   '4': 'fake-key 4',
   '5': 'fake-key 5',
   '6': 'fake-key 6',
   '7': 'fake-key 7',
   '8': 'fake-key 8',
   '9': 'fake-key 9',
   '0': 'fake-key 0',

   # escape hatch
   '<ctrl-g>': ESC_BIND,
   '<Escape>': ESC_BIND,

   # userscripts
   '<ctrl-x>Y': 'hint links userscript ytdl',
   '<ctrl-x>y': 'spawn --userscript ytdl',
   '<ctrl-x><ctrl-y>': 'spawn --userscript ytdl-ph',

   '<ctrl-m>': 'hint links userscript openmpv',
   '<ctrl-shift-m>': 'hint links userscript openmpv_lowres',
   '<ctrl-x>m': 'spawn --userscript openmpv',

   '<ctrl-x>t': 'hint magnets userscript torrentdownload',

   '<ctrl-x>ar': 'spawn --userscript random_anime',
   '<ctrl-x>as': 'jseval --quiet --file mal-sort-ptw-season.js',

   '<ctrl-x>nn': 'spawn --userscript nhentai_tools --download',
   '<ctrl-x>ne': 'spawn --userscript nhentai_tools --exists',
   '<ctrl-x>na': 'spawn --userscript nhentai_tools --add',
   '<ctrl-x>nr': 'spawn --userscript nhentai_tools --random',
   '<ctrl-x>nd': 'spawn --userscript nhentai_tools --remove',
   '<ctrl-x>nu': 'spawn --userscript nhentai_tools --undo',
   '<ctrl-1>'  : "spawn --userscript nhentai_tools '{url}' --add",
   '<ctrl-4>'  : "spawn --userscript nhentai_tools --mark",

   '<ctrl-5>': "spawn --userscript imgdownloader",

   '<ctrl-x>1': 'hint links userscript instacurrent',
   '<ctrl-x>2': 'hint --rapid links userscript instacurrent',
   '<ctrl-x>3': 'spawn --userscript instacurrent',
   '<ctrl-x>4': 'spawn -u instaall',

   '<ctrl-x>g': 'open -t https://images.google.com/searchbyimage?image_url={clipboard}',

   '<alt-shift-r>': 'spawn --userscript --output-messages rememberer',
   '<alt-r>':       'spawn --userscript --output-messages rememberer nosave',
   '<alt-control-r>': 'spawn --userscript --output-messages rememberer replay',

   # insta
   '<alt-w>': 'jseval -q document.querySelector("button > div > svg[aria-label=Save]").parentElement.parentElement.click()',
   '<alt-e>': 'jseval -q document.querySelector("button[aria-label=Next]").click()',
   '<alt-q>': 'jseval -q document.querySelector("button[aria-label=\'Go Back\']").click()',
   '<alt-d>': 'fake-key <right>',
   '<alt-a>': 'fake-key <left>',
}

c.bindings.commands['normal'].update({'<alt-{}>'.format(i): 'tab-focus {}'.format(i) for i in range(1,10)})

c.bindings.commands['command'] = {
   '<ctrl-s>': 'search-next',
   '<ctrl-r>': 'search-prev',

   '<ctrl-k>': 'completion-item-focus prev',
   '<ctrl-j>': 'completion-item-focus next',

   '<alt-k>': 'command-history-prev',
   '<alt-j>': 'command-history-next',

   # escape hatch
   '<ctrl-g>': 'mode-leave',
   '<Escape>': 'mode-leave'
}

c.bindings.commands['hint'] = {
   # escape hatch
   '<ctrl-g>': 'mode-leave',
   '<Escape>': 'mode-leave'
}

c.bindings.commands['caret'] = {
   # escape hatch
   '<ctrl-g>': 'mode-leave',
   '<Escape>': 'mode-leave'
}

############################# massa fake-bindings #############################
from string import ascii_lowercase
c.bindings.commands['normal'].update({"<ctrl-q>{}".format(l): "fake-key <ctrl-{}>".format(l) for l in ascii_lowercase})
c.bindings.commands['normal']['<ctrl-q><Escape>'] = "fake-key <Escape>"
