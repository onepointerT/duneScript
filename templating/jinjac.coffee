## Compatibility script for using jinja from coffeescript or the web-browser

import subprocess from 'coffeelib/exec'

coffeec =
    run_on: (fpath) ->
        return subprocess("python ./coffeec.py " + fpath)