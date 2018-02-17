package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class Thermometer extends en.Interactive {
	public static var ME : Thermometer;
	public function new(x,y) {
		super(x,y);
		ME = this;
		spr.set("thermo");
		hasGravity = false;
		setDepth(Const.DP_MAIN_BG);
	}

	override public function dispose() {
		super.dispose();
		if( ME==this )
			ME = null;
	}

	override public function onFocus() {
		super.onFocus();
		//var txt = switch( game.temperature ) {
			//case -1,-2,-3,-4 : Lang.t._("You will probably die soon.");
			//case 0 : Lang.t._("It's very cold. Like in \"REALLY fucking cold\"");
			//case 1 : Lang.t._("Quite warm.");
			//case 2,3,4 : Lang.t._("This place is really warm now!");
			//default : Lang.t.untranslated("Unknown temp "+game.temperature);
		//}
		//showDesc(Lang.t._("The thermometer says: \"::msg::\"", { msg:txt } ));
		var t = -5 + game.outsideTemp * 5;
		showDesc( Lang.t._("Outside temperature: ::t::°C", { t:t }) );
	}

	override public function update() {
		super.update();

		spr.setFrame( switch( game.outsideTemp ) {
			case -1,-2,-3,-4 : 0;
			case 0 : 1;
			case 1 : 2;
			case 2,3,4 : 3;
			default : 0;
		});
	}
	//override public function canBeActivated(by:en.Hero) {
		//return false;
	//}

	//override public function activate(by:en.Hero) {
		//super.activate(by);
		//var txt = switch( by.temperature ) {
			//case 0 : Lang.t._("It's very cold. Like in Deadly Cold");
			//case 1 : Lang.t._("Quite warm.");
			//case 2 : Lang.t._("This place is really warm now!");
			//default : Lang.t.untranslated("Unknown temp "+by.temperature);
		//}
		//by.popDebug(txt);
	//}
}
