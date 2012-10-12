App.Views.AppView = Backbone.View.extend
  # Instead of generating a new element, bind to the existing skeleton of the App already present in the HTML.
  el: '#todoapp'

  # Our template for the line of statistics at the bottom of the app.
  statsTemplate: JST["backbone/templates/stats_template"]

  # Delegated events for creating new items, and clearing completed ones.
  events:
    'keypress #new-todo': 'createOnEnter'
    'click #clear-completed': 'clearCompleted'
    'click #toggle-all': 'toggleAllComplete'

  # At initialization we bind to the relevant events on the `Todos` collection, when items are added or changed. Kick things off by loading any preexisting todos that might be saved in *localStorage*.
  initialize: ()->
    @input = @$('#new-todo')
    @allCheckbox = @$('#toggle-all')[0]
    @$footer = @$('#footer')
    @$main = @$('#main')

    window.App.Collections.entries.on 'add', @addOne, @
    window.App.Collections.entries.on 'reset', @addAll, @
    window.App.Collections.entries.on 'change:completed', @filterOne, @
    window.App.Collections.entries.on "filter", @filterAll, @

    window.App.Collections.entries.on 'all', @render, @

    window.App.Collections.entries.fetch()

  # Re-rendering the App just means refreshing the statistics -- the rest of the app doesn't change.
  render: ()->
    completed = App.Collections.entries.completed().length
    remaining = App.Collections.entries.remaining().length

    if (App.Collections.entries.length)
      @$main.show()
      @$footer.show()

      @$footer.html(@statsTemplate({
        completed: completed,
        remaining: remaining
      }))

      @$('#filters li a').removeClass('selected').filter('[href="#/' + ( App.EntryFilter || '' ) + '"]').addClass('selected')
    else
      @$main.hide()
      @$footer.hide()

    @allCheckbox.checked = !remaining

  # Add a single todo item to the list by creating a view for it, and appending its element to the `<ul>`.
  addOne: (entry)->
    view = new App.Views.EntriesView({model: entry})
    $('#todo-list').append view.render().el

  # Add all items in the **Todos** collection at once.
  addAll: ()->
    @$('#todo-list').html ''
    App.Collections.entries.each @addOne, @

  filterOne: (entry)->
    entry.trigger("visible")

  filterAll: ()->
    App.Collections.entries.each @filterOne, @

  # Generate the attributes for a new Todo item.
  newAttributes: ()->
    ret =
      title: @input.val().trim()
      order: App.Collections.entries.nextOrder()
      is_completed: false

  # If you hit return in the main input field, create new **Todo** model, persisting it to *localStorage*.
  createOnEnter: (e)->
    if e.which != App.Utils.ENTER_KEY# || !@input.val().trim()
      return null

    App.Collections.entries.create @newAttributes(),
      wait: true
      error: (model, response)->
        json = $.parseJSON(response.responseText)
        error = model.formatError(json)
        alert(error)

    @input.val('')


  # Clear all completed todo items, destroying their models.
  clearCompleted: ()->
    _.each window.App.Collections.entries.completed(), (entry)->
      entry.destroy()

      false

  toggleAllComplete: ()->
    completed = @allCheckbox.checked

    App.Collections.entries.each (entry)->
      entry.save({'completed': completed})
