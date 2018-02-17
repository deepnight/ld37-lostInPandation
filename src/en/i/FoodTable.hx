package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class FoodTable extends en.Interactive {
	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "foodTable");
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( by.use("food") )
			by.life+=0.10;
		else if( by.use("wood") )
			by.life+=0.33;
		else
			by.say(Lang.t._("I don't have food."));
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("A table, a plate and a fork, for me to eat something."));
	}
}
