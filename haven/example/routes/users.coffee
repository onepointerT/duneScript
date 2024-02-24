
require('../../server')
routerProps = ServerApplication.RouterProperties + { siteContext: 'users' }
usersRouter = ServerApplication.ExpressRouter(routerProps)

### GET users listing. ###

usersRouter.get '/users', (req, res, next) ->
  res.send 'respond with a resource'
  return
module.exports = usersRouter
