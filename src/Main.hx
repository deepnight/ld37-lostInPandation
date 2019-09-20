import Data;
import dn.heaps.GamePad;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

		createRoot(s);
		root.setScale(Const.SCALE);

		hxd.Res.initEmbed({compressSounds:true});
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


		#if !debug
		engine.fullScreen = true;
		#end
		delayer.addF( function() {
			var music = new dn.heaps.Sfx( hxd.Res.music );
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
		// buffer.width = M.ceil(w()/Const.SCALE);
		// buffer.height = M.ceil(h()/Const.SCALE);
	}

	override public function update() {
		dn.heaps.Controller.beforeUpdate();
		super.update();
		//mt.flash.Sfx.update();
	}
}
