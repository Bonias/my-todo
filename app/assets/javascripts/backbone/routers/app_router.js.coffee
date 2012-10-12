App.Routers.AppRouter = Backbone.Router.extend

  routes:
    '*filter': 'setFilter'

  setFilter: (param)->
    # Set the current filter to be used
    window.App.EntryFilter = param.trim() || ''

    # Trigger a collection filter event, causing hiding/unhiding of Todo view items
    window.App.Collections.entries.trigger('filter')

App.AppRouter = new App.Routers.AppRouter()
Backbone.history.start()
