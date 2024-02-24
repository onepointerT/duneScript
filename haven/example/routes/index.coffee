require('../../server')
routerProps = ServerApplication.RouterProperties + { siteContext: 'index' }
indexRouter = ServerApplication.ExpressRouter(routerProps)

### GET home page. ###

indexRouter.get '/', (req, res, next) ->
  res.render 'index', title: 'Express'
  return
module.exports = indexRouter
