package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class Computer extends en.Interactive {
	public function new(x,y) {
		super(x,y);
		spr.set("thermo");
	}

	override public function dispose() {
		super.dispose();
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("This is where you create your Ludum Dare game."));
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( game.gen.useCharge(1) ) {
			by.popDebug("LD++");
		}
		else {
			game.gen.jauge.pop(Lang.t._("Generator is empty"), 0xFF0000);
		}

	}

	override public function update() {
		super.update();
	}
}
