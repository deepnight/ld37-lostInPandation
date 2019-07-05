class Console extends h2d.Console {
	public static var ME : Console;

	public function new() {
		super(Assets.font, Main.ME.root);
		ME = this;
		#if debug
		h2d.Console.HIDE_LOG_TIMEOUT = 60;
		#end
		mt.deepnight.Lib.redirectTracesToH2dConsole(this);

		#if debug
		addCommand("add", "Add item", [{ name:"i", t:AString }], function(i) {
			Game.ME.hero.pickItem(i, Game.ME.hero.cx, Game.ME.hero.cy);
		});
		addCommand("begin", "begin", [], function() {
			Game.ME.beginRealGame();
		});
		addCommand("storm", "Toggle storm", [], function() {
			if( Game.ME.storm )
				Game.ME.stopStorm();
			else
				Game.ME.startStorm();
		});
		addCommand("power", "Add power", [ { name:"v", t:AInt, opt:true } ], function(?v:Int) {
			if( v==null ) v = Game.ME.gen.max;
			Game.ME.gen.charge = v;
		});
		addCommand("vp", "Viewport", [], function() {
			Game.ME.viewport.tracking = !Game.ME.viewport.tracking;
		});
		#end
	}
}