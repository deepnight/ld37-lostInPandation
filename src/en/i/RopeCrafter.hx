package en.i;


class RopeCrafter extends en.Interactive {
	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "foodTable");
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( by.use("wood") ) {
			by.say(Lang.t._("Crafted a rope"));
			var e = new en.i.Item(cx + (by.cx<cx?1:-1), cy, "rope");
			e.dx = rnd(0.1,0.3,true);
			e.dy = -0.5;
		}
		else
			by.say(Lang.t._("I can make a ROPE from bamboo here."));
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("A sewing workshop to turn bamboo into ropes."));
	}

	override public function postUpdate() {
		super.postUpdate();
	}

	override public function update() {
		super.update();
	}
}
