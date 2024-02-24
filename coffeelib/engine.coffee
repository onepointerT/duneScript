
import File from '../coffeelib/path'


class Engine
    @engineProperties = EngineProperties: {
        doctype: ''
        filename: ''
        globabls: [String]
    }

    # Specify, if wanted
    setup: () =>

    constructor: (@extension) ->
        this.setup()


    # Specify this function in each extending subclass with `SUBCLASSNAME::render_now = =>`
    render_now: (content, paramDict) =>
        return content

    render: (fpath, paramDict) ->
        f = new File fpath
        fc = f.read()
        return render_now fc, paramDict
        