exec  = require('child_process').exec


subprocess: (path_to_binary) ->
    exec(path_to_binary,
        (error, stdout, stderr) =>
            console.log('stdout:', stdout);
            console.log('stderr:', stderr);
            if error isnt null
                console.log('exec error:', error)
        )