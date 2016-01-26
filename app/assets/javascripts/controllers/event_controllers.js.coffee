Twitarr.EventsPageController = Twitarr.ObjectController.extend
  has_next_page: (->
    @get('next_page') isnt null and @get('next_page') isnt undefined
  ).property('next_page')

  has_prev_page: (->
    @get('prev_page') isnt null and @get('prev_page') isnt undefined
  ).property('prev_page')

  actions:
    next_page: ->
      return if @get('next_page') isnt null and @get('next_page') isnt undefined
      @transitionToRoute 'events.page', @get('next_page')
    prev_page: ->
      return if @get('prev_page') isnt null and @get('prev_page') isnt undefined
      @transitionToRoute 'events.page', @get('prev_page')
    create_event: ->
      @transitionToRoute 'events.new'

Twitarr.EventsMetaPartialController = Twitarr.ObjectController.extend()

Twitarr.EventsDetailController = Twitarr.ObjectController.extend
  editable: (->
    @get('logged_in') and (@get('author') is @get('login_user') or @get('login_admin'))
  ).property('logged_in', 'author', 'login_user', 'login_admin')

  signed_up: (->
    @get('signups').includes(@get('author'))
  ).property('author', 'signups')

  can_sign_up: (->
    return true if @get('signups').includes(@get('author')) # Let people unsign up
    @get('signups').length <= @get('max_signups')
  ).property('signups', 'max_signups', 'author')

  actions:
    signup: ->
      @get('model').signup()
    unsignup: ->
      @get('model').unsignup()
    edit: ->
      @transitionToRoute 'events.edit', @get('id')
    delete: ->
      if(confirm("Are you sure you want to delete this event?"))
        r=@get('model').delete()
        @transitionToRoute 'events.page', 0 if r

Twitarr.EventsNewController = Twitarr.Controller.extend
  init: ->
    @set 'errors', Ember.A()

  start_time: (->
    getUsableTimeValue()
  ).property()

  actions:
    new: ->
      return if @get('posting')
      @set 'posting', true
      Twitarr.Event.new_event(@get('title'), @get('description'), @get('location'), @get('start_time'), @get('end_time'), @get('max_signups')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'title', ''
          @set 'description', ''
          @set 'location', ''
          @set 'start_time', getUsableTimeValue()
          @set 'end_time', ''
          @set 'max_signups', ''

          @set 'posting', false
          @get('errors').clear()
          @transitionToRoute 'events.detail', response.event.id
      , ->
        @set 'posting', false
        alert 'Event could not be added. Please try again later. Or try again someplace without so many seamonkeys.'
      )

getUsableTimeValue = -> d = new Date(); d.toISOString().replace('Z', '')