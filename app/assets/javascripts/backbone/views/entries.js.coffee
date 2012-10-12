App.Views.EntriesView = Backbone.View.extend

#... is a list tag.
  tagName: 'li'

  # Cache the template function for a single item.
  template: JST["backbone/templates/item_template"]

  # The DOM events specific to an item.
  events:
    'click .toggle': 'togglecompleted'
    'dblclick label': 'edit'
    'click .destroy': 'clear'
    'keypress .edit': 'updateOnEnter'
    'blur .edit': 'close'

  # The TodoView listens for changes to its model, re-rendering. Since there's a one-to-one correspondence between a **Todo** and a **TodoView** in this app, we set a direct reference on the model for convenience.
  initialize: ()->
    @model.on 'change', @render, @
    @model.on 'destroy', @remove, @
    @model.on 'visible', @toggleVisible, @

  # Re-render the titles of the todo item.
  render: ()->
    @$el.html(@template(@model.toJSON()))
    @$el.toggleClass('completed', @model.get('is_completed'))

    @toggleVisible()
    @input = @$('.edit')
    @

  toggleVisible: ()->
    @$el.toggleClass('hidden', @isHidden())

  isHidden: ()->
    isCompleted = @model.get('is_completed')
    (!isCompleted && App.EntryFilter == 'completed') || (isCompleted && App.EntryFilter == 'active')

  # Toggle the `"completed"` state of the model.
  togglecompleted: ()->
    @model.toggle()

  # Switch this view into `"editing"` mode, displaying the input field.
  edit: ()->
    @$el.addClass('editing')
    @input.focus()

  # Close the `"editing"` mode, saving changes to the todo.
  close: ()->
    value = @input.val().trim()

    if value
      @model.save({title: value})
    else
      @clear()

    @$el.removeClass('editing')

  # If you hit `enter`, we're through editing the item.
  updateOnEnter: (e)->
    if e.which == App.Utils.ENTER_KEY
      @close()

  # Remove the item, destroy the model from *localStorage* and delete its view.
  clear: ()->
    @model.destroy()
