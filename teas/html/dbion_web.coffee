
import * as dbiondb from '../../dbion/dbiondb'


dbion: {
    Query: dbiondb.Query

    query: (statement_or_file, content = '') ->
        if content.length > 0
            return (Query statement_or_file).db content
        return (Query statement_or_file).db()
}