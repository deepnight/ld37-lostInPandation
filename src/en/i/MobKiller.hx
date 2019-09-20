package en.i;


class MobKiller extends en.Interactive {
	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "empty");
	}

	override public function activate(by:en.Hero) {
		super.activate(by);

		if( game.gen.empty() )
			by.say(Lang.t._("The main generator must be charged if I want to kill any menace."));
		else if( en.Mob.ALL.length==0 )
			by.say(Lang.t._("There is no enemy around."));
		else if( game.gen.useCharge(1) ) {
			fx.flashBang(0x9537C8, 0.5, 0.2);
			game.delayer.addS( function() {
				fx.flashBang(0x0093FF, 0.7, 2);
			},0.1);
			for(e in en.Mob.ALL)
				game.delayer.addS(e.kill, rnd(0.3,1));
			if( game.realGameStarted )
				game.initMobLoop();
		}
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("Menace clearer"));
	}

	override public function postUpdate() {
		super.postUpdate();
	}

	override public function update() {
		super.update();
	}
}
