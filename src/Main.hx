import Data;
import dn.heaps.GamePad;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	var overlay : dn.heaps.OverlayTextureFilter;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

		createRoot(s);
		root.setScale(Const.SCALE);
		root.filter = new h2d.filter.ColorMatrix();

		hxd.Res.initEmbed();
		Lang.init("en");
		Assets.init();
		Data.load( hxd.Res.load("data.cdb").toText() );
		new dn.heaps.GameFocusHelper(s, Assets.font);
		s.addChild( new Console() );

		controller = new dn.heaps.Controller(s);
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.DOWN, Key.S, Key.ESCAPE);
		controller.bind(SELECT, Key.R);

		overlay = new dn.heaps.OverlayTextureFilter(Soft);
		overlay.alpha = 0.3;
		s.filter = overlay;

		#if !debug
		engine.fullScreen = true;
		#end
		delayer.addF( function() {
			#if hl
			var music = new dn.heaps.Sfx( hxd.Res.music_hl );
			#else
			var music = new dn.heaps.Sfx( hxd.Res.music_js );
			#end
			music.playOnGroup(1,true);
			new Game(true);
		},1);
	}

	override public function onResize() {
		super.onResize();
		Const.SCALE = M.floor( h()/240 );
		#if debug
		//Const.SCALE = 2;
		#end
		root.setScale(Const.SCALE);
		overlay.bevelSize = Std.int(Const.SCALE);
	}

	override public function update() {
		dn.heaps.Controller.beforeUpdate();
		super.update();
		//mt.flash.Sfx.update();
	}
}
