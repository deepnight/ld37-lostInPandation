package en.i;


class BatteryMaker extends en.Interactive {
	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "batteryMaker");
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( game.gen.useCharge(1) ) {
			by.say(Lang.t._("Crafted a battery"));
			var e = new en.i.Item(cx, cy-1, "battery");
			//e.dx = rnd(0.10,0.15);
		}
		else
			by.say(Lang.t._("The main generator must be charged if I want to produce a BATTERY here."));
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("A battery distributor"));
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.x+=5;
	}

	override public function update() {
		super.update();
	}
}
