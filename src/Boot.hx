class Boot extends hxd.App {
	// Boot
	static function main() {
		new Boot();
	}

	// Engine ready
	override function init() {
		engine.backgroundColor = 0xff<<24|0x0;

		hxd.Timer.wantedFPS = Const.FPS;
		new Main(s2d);
		dn.Process.resizeAll();
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);

		#if debug
		var n = 1;
		if( Game.ME!=null && Game.ME.hero!=null && @:privateAccess Game.ME.hero.controller.yDown() )
			n+=6;
		while( n-->0 )
			dn.Process.updateAll(hxd.Timer.tmod);
		#else
		dn.Process.updateAll(hxd.Timer.tmod);
		#end
	}
}

