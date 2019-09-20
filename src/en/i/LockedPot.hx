package en.i;


class LockedPot extends en.Interactive {
	var pot  : HSprite;
	public function new(x,y) {
		super(x,y);

		pot = Assets.tiles.h_get("potSpawn");
		game.scroller.add(pot, Const.DP_MAIN_BG);
		pot.setCenterRatio(0.5,0.5);

		spr.set(Assets.tiles, "empty");
	}

	override public function dispose() {
		super.dispose();
		pot.remove();
	}

	override public function activate(by:en.Hero) {
		super.activate(by);

		if( game.gen.useCharge(1) ) {
			new en.i.Pot(cx, cy-2);
			Tutorial.ME.nextIfAt(5);
			destroy();
		}
		else
			by.say(Lang.t._("The main generator must be charged if I want to unlock a new PLANT POT here."));
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("Locked plant pot"));
	}

	override public function postUpdate() {
		super.postUpdate();
		pot.setPosition(sprX, sprY-26);
	}

	override public function update() {
		super.update();
	}
}
