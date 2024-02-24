## Compatibility script for using jinja from coffeescript or the web-browser

import subprocess from 'coffeelib/exec'
import { File } from '../coffeelib/path'
import { Yaml } from '../dbion/dbiondb'

coffeec: {
    run_on: (fpath, yml_file_path) ->
        return subprocess("python ./coffeec.py " + fpath + ' -yml ' + yml_file_path)
    
    run: (fpath, yml) ->
        ymlf = new Yaml(fpath + '.jinja.yml', yml)
        ymlf.write()
        return run_on fpath, fpath + '.jinja.yml'
}
