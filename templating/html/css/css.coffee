import Yaml from 'dbion/dbiondb'
    
cssyml = require('./css.yml')

purecss =
   version: '3.0.0'
   href: "https://cdn.jsdelivr.net/npm/purecss@#{ purecss.version }/build/"
   modules: ['pure.css']
   modulehrefs: href + m for m in modules
   menuitems: cssyml.menuitems
   menu_type: 'vertical'

   includecss: () ->
        jinja = """{% include 'css.jinja' as css %}
            {% include 'purecss.jinja' as pure %}
            {{ css.includecss_multi(#{ purecss.modulehrefs })  }}
        """
        return jinja

    menu =
        addmenu_cssstyle: () ->
            html = """<style>
                .custom-restricted-width {
                    /* To limit the menu width to the content of the menu: */
                    display: inline-block;
                }
                </style>"""
            return html


        menu_vertical_hdr: () ->
            jinja = """{{ pure.menu(#{ cssyml.heading }, 'vertical') }}"""
            return jinja

        menu_horizontal_hdr: () ->
            jinja = """{{ pure.menu(#{ cssyml.heading }, 'vertical') }}"""
            return jinja

        # additionalMenuItems is a list of tuples (hfref, Name)
        make_menu: (vertical = true, additionalMenuItems = []) ->
            jinja = menu.addmenu_cssstyle()
            if vertical
                jinja += menu.menu_vertical()
            else
                jinja += menu.menu_horizontal()
            jinja += "{% block main_menu_items %}
                "
            for menu_item in cssyml.menuitems
                jinja += "{{ pure.menu_item(#{menu_item[0]}, #{menu_item[1]}) }}
                    "
            
            for menu_item in additionalMenuItems
                jinja += "{{ pure.menu_item(#{menu_item[0]}, #{menu_item[1]}) }}
                    "
            jinja += "{% endblock %}
                "
            return jinja

        addtolayout_hdr: (vertical = true, additionalMenuItems = []) ->
            return make_menu(vertical, additionalMenuItems = [])

    form =
        types: {
            Default: 'default'
            Stacked: 'stacked'
            Aligned: 'aligned'
        }
        make_form: (form) ->
