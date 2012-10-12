App.Models.Entry = Backbone.Model.extend
  paramRoot: 'entry'

  defaults:
    title: null,
    is_completed: false

  toggle: ()->
    @save
      is_completed: !@get('is_completed')

  formatError: (json)->
    msgs = []
    _.each json, (errs, attr)->
      msgs.push "" + attr + ' ' + errs.join(", ")
    msgs.join("\n")

App.Collections.Entries = Backbone.Collection.extend
  # Reference to this collection's model.
  model: App.Models.Entry
  url: '/entries'

  # Filter down the list of all todo items that are finished.
  completed: ()->
    @filter (entry)->
      entry.get('is_completed')

  # Filter down the list to only todo items that are still not finished.
  remaining: ()->
    @without.apply(@, @completed() );

  # We keep the Todos in sequential order, despite being saved by unordered GUID in the database. This generates the next order number for new items.
  nextOrder: ()->
    if !@length
      1
    else
      @last().get('order') + 1

  # Todos are sorted by their original insertion order.
  comparator: (entry)->
    entry.get('order')


App.Collections.entries = new App.Collections.Entries();
