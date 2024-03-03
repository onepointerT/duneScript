import Yaml from 'dbion/dbiondb'
import purecss from 'css/css'
    
layoutyml = require('./layout.yml') asserts { type: 'yaml' }

layout =
   version: '0.0.1'
   css: purecss

   make_content: () -> return ""
   make_footer: () -> return "#{layoutyml.layout.footer}"
   