package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class Radio extends en.Interactive {
	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "empty");
	}

	override public function activate(by:en.Hero) {
		super.activate(by);

		if( mt.deepnight.Sfx.toggleMuteGroup(1) ) {
			mt.deepnight.Sfx.muteGroup(0);
			pop(Lang.t._("Music ON"), 0xFFFF80);
		}
		else {
			mt.deepnight.Sfx.unmuteGroup(0);
			pop(Lang.t._("Music OFF"), 0xFF4A2B);
		}

		//if( mt.flash.Sfx.toggleMuteChannel(1) ) {
			//mt.flash.Sfx.muteChannel(0);
			//pop(Lang.t._("Music ON"), 0xFFFF80);
		//}
		//else {
			//mt.flash.Sfx.unmuteChannel(0);
			//pop(Lang.t._("Music OFF"), 0xFF4A2B);
		//}
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("Radio"));
	}
}
