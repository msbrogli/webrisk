
class Player extends Backbone.Model
	defaults:
		name: ''

	play: ->
		name = @.get 'name'
		console.log name + ' is playing'
		'cmd': 'done'


class PlayerCollection extends Backbone.Collection
	model: Player


class RiskGame extends Backbone.Model
	defaults: ->
		lands: new LandCollection


class Land extends Backbone.Model
	defaults: ->
		name: ''
		player: null
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
		tokens = @model.get 'tokens'
		player = @model.get 'player'
		if player
			player = player.get 'name'
		$(@el).html(tokens + player)


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
		@currentPlayerIndex = 0
		@lands = new LandCollection
		@players = new PlayerCollection
		@game = new RiskGame 'lands': @lands
		@view = new RiskGameView 'el': el, 'model': @game
		@view.render()

	distributeLands: ->
		lands = @lands
		players = @players
		v = [0 .. lands.length-1]
		shuffle v
		_.each v, (idxLand, idx) ->
			lands.at(idxLand).set 'player': players.at(idx % players.length)

	step: ->
		player = @players.at @currentPlayerIndex
		ret = player.play()
		if ret.cmd == 'done'
			@next()
		else
			console.log 'invalid return, ignoring'
			@next()

	next: ->
		@currentPlayerIndex++
		@currentPlayerIndex %= @players.length

	run: ->


init = ->
	controller = new RiskGameController $('#risk')
	controller.lands.fetch url: 'lands.json'

	controller.players.add
		name: 'msbrogli'
	controller.players.add
		name: 'patty'

	afterLoadResources = ->
		controller.distributeLands()
		controller.step()
		controller.step()
		controller.step()
		controller.step()

	setTimeout afterLoadResources, 1000


$(document).ready init
