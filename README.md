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

A database that operates on `.yaml`, `.json` and `.coffee` files. Further development will integrate a rest api and the json format. Basic functionality is currently usable with python and coffeescript.

````
directories
- dbion 
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
