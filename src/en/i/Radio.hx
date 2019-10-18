package en.i;


class Radio extends en.Interactive {
	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "empty");
	}

	override public function activate(by:en.Hero) {
		super.activate(by);

		Assets.music.togglePlay(true);
		if( !Assets.music.isPlaying() )
			pop(Lang.t._("Music OFF"), 0xff3300);
		else
			pop(Lang.t._("Music ON"), 0xccff00);
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("Radio"));
	}
}
