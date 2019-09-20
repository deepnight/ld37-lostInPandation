package en.i;


class Message extends en.Interactive {
	var txt : LocaleString;
	public function new(x,y, str:LocaleString) {
		super(x,y);
		txt = str;
		hasGravity = false;
		spr.set("empty");
		activationDelay = 0;
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		game.message(txt);
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("Press SPACE to read"));
	}

	override public function postUpdate() {
		super.postUpdate();
	}
}
