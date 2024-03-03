## DBiON example
### An example for a dbion database

* The generated database files in `dbiondb` (generated from the `webdb.dbion.yml`) must match the manually created files in `dbiondb/example_test/**.tbl.yml` matching withof 100 % for a successful specification test.
* `_dbiondbdir` must then include a file `mapping.json` with the content like in the manually created file `dbiondb/example_test/mapping.json` with a mathing of 100 % of its content


#### Syntax and semantics of lookups and lookup variables

In a mapping of joins, rjoins or requests, a field value is referenced with a trailing '$'
- '**' indicates any value, even when there is a list of values or a list of lists or similar
- '*rjoins*' matches any ID of the JSON field rjoins: {}
- Similar, '*$tablename1/tablename2.id*' algorithmically matches any ID of the dbion table tablename1/tablename2 field value id
- $Path.Field means, that a field value is to be looked up
- $tablename1/#tablename2.fieldA means, that tablename2 will be subsituted by the table id and fieldA is then looked up
- $#Path.Field would dereference path to its table ids and then lookup field
- #$Path.Field would first lookup $Path.Field and then dereference Path (e.g. useful for compare conditions and storing after lookup)
- $$Path[.[FieldA,FieldB]] can lookup a whole set of table data
- |filename[||ext]| filters by filenames, where filename usually is something like [$uid]_#tblid_**
- A new ID can be generated with '##'
- paths without operator prefix always mean the value of a field in a table (prefixed with table(s).) or the current value of a field in the current table

That's all what can happen ;)