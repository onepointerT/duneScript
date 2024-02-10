cssyml = require('css.yml')

purecss =
   version: '3.0.0'
   href: "https://cdn.jsdelivr.net/npm/purecss@#{ purecss.version }/build/"
   modules: ['pure.css']
   modulehrefs: href + m for m in modules
   menuitems: "{{- cssyml.menuitems -}}"
   menu_type: 'vertical'

   includecss: () ->
        jinja = "{% include 'css.jinja' as css %}
            {% include 'purecss.jinja' as pure %}
            {{ css.includecss_multi(#{ modulehrefs })  }}
        "
        return jinja
    
    import Yaml from '../../../dbion/dbiondb.js'

    menu =
        menu: yml.Yaml.load('./css.yml')
        addmenu_cssstyle: () ->
            html = "<style>
                .custom-restricted-width {
                    /* To limit the menu width to the content of the menu: */
                    display: inline-block;
                }
                </style>"
            return html

        menu_vertical: () ->
            jinja = "

                "

    addtolayout_hdr: () ->
        includecss()
