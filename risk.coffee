
class Player extends Backbone.Model
	defaults:
		name: ''

	distributeArmies: (numberOfArmies, lands) ->
		# Distribute armies evenly.
		_.each lands, (land, idx) ->
			qty = Math.floor(numberOfArmies / lands.length)
			if idx < numberOfArmies % lands.length
				qty++
			land.set 'armies': qty

	play: ->
		name = @.get 'name'
		console.log name + ' is playing'
		'cmd': 'done'


class PlayerCollection extends Backbone.Collection
	model: Player


class RiskGame extends Backbone.Model
	defaults: ->
		lands: new LandCollection
		players: new PlayerCollection
		currentPlayerIndex: 0

	distributeArmies: ->
		# TODO Check if players are distributing correctly (neither more nor less and at least one per land)
		numberOfArmies = 40
		@.get('players').each ((player) ->
			lands = @.get('lands').filter (land) -> land.get('player') == player
			player.distributeArmies numberOfArmies, lands
		), @

	distributeLands: ->
		# Distribute according to the original French rules.
		# Another choice is players choosing a land one after the other.
		# http://en.wikipedia.org/wiki/Risk_(game)#Setup
		lands = @.get 'lands'
		players = @.get 'players'
		v = _.shuffle [0 .. lands.length-1]
		_.each v, (idxLand, idx) ->
			lands.at(idxLand).set 'player': players.at(idx % players.length)

	setup: ->
		@.distributeLands()
		@.distributeArmies()

	next: ->
		idx = @.get 'currentPlayerIndex'
		players = @.get 'players'
		idx = (idx+1) % players.length
		@.set 'currentPlayerIndex': idx

	step: ->
		players = @.get 'players'
		idx = @.get 'currentPlayerIndex'
		player = players.at idx
		ret = player.play()
		if ret.cmd == 'done'
			@next()
		else
			console.log 'invalid return, ignoring'
			@next()


class Land extends Backbone.Model
	defaults: ->
		name: ''
		player: null
		top: 0
		left: 0
		armies: 0


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
		armies = @model.get 'armies'
		player = @model.get 'player'
		if player
			player = player.get 'name'
		$(@el).html(armies + player)


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
		@lands = new LandCollection
		@players = new PlayerCollection
		@game = new RiskGame 'lands': @lands, 'players': @players
		@view = new RiskGameView 'el': el, 'model': @game
		@view.render()


init = ->
	numberOfResourcesToLoad = 1
	afterLoadResources = _.after numberOfResourcesToLoad, ->
		controller.game.setup()
		controller.game.step()
		controller.game.step()
		controller.game.step()

	controller = new RiskGameController $('#risk')
	controller.lands.fetch url: 'lands.json', success: afterLoadResources

	controller.players.add
		name: 'msbrogli'
	controller.players.add
		name: 'patty'


$(document).ready init
