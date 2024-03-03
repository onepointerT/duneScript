import Yaml from 'dbion/dbiondb'
    
# yml = Yaml.read('./css.yml').data()
cssyml = require('./css.yml') assert { type: 'yaml' }

purecss =
   version: '3.0.0'
   href: "https://cdn.jsdelivr.net/npm/purecss@#{ purecss.version }/build/"
   modules: ['pure.css']
   modulehrefs: href + m for m in modules
   menuitems: cssyml.menuitems
   menu_type: 'vertical'
   html_out: 'pure.html'
   yml: cssyml

   includecss: () ->
        jinja = """{% include 'css.jinja' as css %}
            {% include 'purecss.jinja' as pure %}
            {{ css.includecss_multi(#{ purecss.modulehrefs })  }}
        """
        return jinja

    menu:
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

    form:
        types: {
            Default: 'default'
            Stacked: 'stacked'
            Aligned: 'aligned'
        }

        make_form: (heading, form_type = form.types.Default, formlist = cssyml.forms.testforms.formlist, form_blockname = '') ->
            return "{{ pure.form(#{heading}, #{form_blockname}, #{formlist}, #{form_type}) }}"
        
        # Accepts YAML mapping object with the attributes [blockname, heading, type, formlist] like given in css.yml for forms.testform
        make_form: (ymlform = cssyml.forms.testform) ->
            return form.make_form(ymlform.heading, ymlform.type, ymlform.formlist, ymlform.blocklist)
    
    table:
        types: {
            Default: 'default'
            Horizontal: 'horizontal'
            Striped: 'striped'
            Bordered: 'bordered'
        }

        make_table: (table_obj = cssyml.tables.testtable, table_type = table.types.Horizontal) ->
            if table_type == table.types.Horizontal
                css_classes = "pure-table-horizontal " + table_obj.cssclass
            else if table_type == table.types.Striped
                css_classes = "pure-table-striped " + table_obj.cssclass
            else if table_type == table.types.Bordered
                css_classes = "pure-table-bordered " + table_obj.cssclass
            else
                css_classes = table_obj.cssclass
            return """{{ pure.table(#{table_obj.columns}, #{table_obj.nameid}, #{css_classes}) }}"""
        
        fill_table: (table_obj = cssyml.tables.testtable, table_values = [[]]) ->
            return """{{ pure.table_add_rows(#{table_obj.nameid}, #{table_values}) }}"""
    
    make_layout: () ->
        return """<title>#{cssyml.heading}</title>"""
