
class RiskGame extends Backbone.Model
	initialize: ->
		@set 'countries': new buckets.Set,
			 'players': new buckets.Set


class Country extends Backbone.Model


class CountryView extends Backbone.View
	render: ->
		alert 'ae'


class RiskGameView extends Backbone.View
	initialize: ->
		$(@el).append $('<img src="images/map.jpg">').css('width', '100%')

	render: ->
		return @


class RiskGameController
	constructor: (el) ->
		model = new RiskGame
		view = new RiskGameView 'el': el, 'model': model
		view.render()


init = ->
	controller = new RiskGameController $('#risk')


$(document).ready init
