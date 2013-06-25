
class RiskGame extends Backbone.Model
	defaults: ->
		lands: new LandCollection


class Land extends Backbone.Model
	defaults: ->
		name: ''
		top: 0
		left: 0
		tokens: 0


class LandCollection extends Backbone.Collection
	model: Land


class LandView extends Backbone.View
	initialize: ->
		@el = $('<div class="land"></div>')
		@el.css('top', @model.get 'top')
		@el.css('left', @model.get 'left')
		$(@options.parent).append @el

		@.listenTo @model, 'change', @render

	render: ->
		$(@el).html(@model.get 'tokens')


class RiskGameView extends Backbone.View
	initialize: ->
		@landviews = []

		lands = @model.get 'lands'
		@.listenTo(lands, 'add', @addLand)

		$(@el).append $('<img src="images/map.jpg">').css('width', '100%')

	addLand: (land, collection) ->
		view = new LandView 'parent': @el, 'model': land
		@landviews.push view
		view.render()

	render: ->
		_.each @landviews, (view) ->
			view.render()
		return @


class RiskGameController
	constructor: (el) ->
		lands = new LandCollection
		model = new RiskGame 'lands': lands
		view = new RiskGameView 'el': el, 'model': model
		view.render()

		lands.fetch url: 'lands.json'
		$.lands = lands


init = ->
	controller = new RiskGameController $('#risk')


$(document).ready init
