class Boot extends hxd.App {
	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});
		new Boot();
	}

	// Engine ready
	override function init() {
		engine.backgroundColor = 0xff<<24|0x0;

		hxd.Timer.wantedFPS = Const.FPS;
		new Main(s2d);
		mt.Process.resizeAll();
	}

	override function onResize() {
		super.onResize();
		mt.Process.resizeAll();
	}

	override function update(dt:Float) {
		super.update(dt);

		#if debug
		var n = 1;
		if( Game.ME!=null && @:privateAccess Game.ME.hero.controller.yDown() )
			n+=6;
		while( n-->0 )
			mt.Process.updateAll(dt);
		#else
		mt.Process.updateAll(dt);
		#end
	}
}

