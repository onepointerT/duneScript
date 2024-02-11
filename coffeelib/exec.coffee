exec  = require('child_process').execSync


subprocess: (cmd) ->
    execSync(cmd,
            (error, stdout, stderr) =>
                console.log('stdout:', stdout);
                console.log('stderr:', stderr);
                if error isnt null
                    console.log('exec error:', error)
            )