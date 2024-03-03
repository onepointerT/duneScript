# duneScript 
#### A script engine for Direct Use Now Environment Script
##### v0.0.1

A simple environment with a direct file database that can be used on your OS and for scripting with templates or the browser. Will support html templates and yaml.

````
Copyright 2012, 2024 Sebastian Lau <sebastianlau995@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
````

### Modules

The current project stage is very elementar and under active development.

#### DBiON
###### A database in object notation

A database that operates on `.yaml`, `.json` and `.coffee` files. Further development will integrate a rest api and the json format. Basic functionality is currently usable with python and coffeescript. Database set-ins can be installed to a databases root, to add more functionality and table requests.

Here an example database config:

````yaml
- webdb: {
  tabledir: "./db",
  requests: "./data_request",
  request_tmp: '#{webdb.requests}/tmp',
  tables: ['persons', 'users', 'user_profiles'],
  tabledef: {
    - {
      name: "persons",
      ## You can rjoin fields from other tables and give them aliases
      ### Fields from other tables with no alias are just name
      fields: ['uid', 'users.uname alias uname', 'name'],
      ## The condition we rjoin a fields to this table.
      ### Omitted on no match and an empty '' on no match for e.g. uid
      cond: 'uid is users.uid',
    },
    {
      name: 'users',
      fields: ['uid', 'uname', 'pw', 'persons.name', 'email'],
      cond: 'uid is persons.uid',
    },
    {
      name: 'user_profiles',
      fields: ['uid', 'last_login', 'img_href'],
      ## One may could want to join a table with some fields from a new table.
      joins: [
        {
          fields: 'last_login', 
          join_table: 'users',
          cond: 'uid is users.uid'
        },
        {
          fields: 'img_href',
          join_table: 'persons',
          cond: 'uid is persons.uid',
          alias: 'img_src'
        }
      ]
    }
  }
}
````


#### Teas
###### A template environment artifical solver

A template environment solver that can operate on `.css`, `.html`, `.coffee` and DBiON. Uses native jinja 3  and can handle html also when a dataset is changed.

````
directories
- templating
\-- example_webpage
\-- html
\--\-- css
````
