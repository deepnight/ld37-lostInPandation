
class Bar extends dn.Process {
	var bg : HSprite;
	var bar : HSprite;
	var warn : HSprite;
	public var warnLevel(default,null) : Int;
	public function new(p) {
		super(Game.ME);
		createRoot(p);
		bg = Assets.tiles.h_get("barBg", root);
		bar = Assets.tiles.h_get("bar", root);
		bar.setPosition(3,3);
		warn = Assets.tiles.h_get("warning", root);
		warn.x = bg.tile.width;
		warn.visible = false;
		warnLevel = 0;
	}

	public function setWarn(v:Int) {
		warnLevel = v;
		warn.visible = v>0;
		if( warn.visible )
			warn.colorize( v==1 ? 0xFFFF00 : 0xFF0000 );
	}

	public function set(v:Float) {
		bar.scaleX = v;
	}

	override public function update() {
		super.update();
		warn.alpha = 1 - M.fabs( Math.cos(ftime*0.4)*0.7 );
	}
}