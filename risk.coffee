
class RiskGame extends Backbone.Model
	initialize: ->
		@set 'countries': new buckets.Set,
			 'players': new buckets.Set


class RiskGameView extends Backbone.View
	render: ->
		$(@el).html 'Teste'


class RiskGameController extends Backbone.Controller
	initialize: (el) ->
		model = new RiskGame
		view = new RiskGameView 'el': el, 'model': model


init = ->
	controller = new RiskGameController $('#risk')


$(document).ready init
