import mt.Process;
import mt.MLib;
import Data;
import mt.heaps.GamePad;
import hxd.Key;

class Main extends mt.Process {
	public static var ME : Main;
	public var controller : mt.heaps.Controller;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

		createRoot(s);
		root.setScale(Const.SCALE);

		hxd.Res.initEmbed({compressSounds:true});
		Lang.init("en");
		Assets.init();
		Data.load( hxd.Res.load("data.cdb").toText() );
		s.addChild( new Console() );

		controller = new mt.heaps.Controller(s);
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.DOWN, Key.S, Key.ESCAPE);
		controller.bind(SELECT, Key.R);

		var music = new mt.deepnight.Sfx( hxd.Res.music );
		music.playOnGroup(1,true);
		// Assets.SBANK.music().playOnGroup(1,true);
		//Assets.SBANK.music().playLoopOnChannel(1);
		//#if debug
		//mt.flash.Sfx.muteChannel(1);
		//#else
		//mt.flash.Sfx.muteChannel(0);
		//#end

		//if( mt.deepnight.Lib.ludumProtection(false,true) ) {
			#if !debug
			engine.fullScreen = true;
			#end
			new Game(true);
		//}
		//else {
			//var t = new h2d.Text(Assets.font, s);
			//t.text = "Couldn't load data. Visit www.deepnight.net.";
			//t.scale(2);
		//}
	}

	override public function onResize() {
		super.onResize();
		Const.SCALE = MLib.floor( h()/240 );
		#if debug
		//Const.SCALE = 2;
		#end
		root.setScale(Const.SCALE);
		// buffer.width = MLib.ceil(w()/Const.SCALE);
		// buffer.height = MLib.ceil(h()/Const.SCALE);
	}

	override public function update() {
		mt.heaps.Controller.beforeUpdate();
		super.update();
		//mt.flash.Sfx.update();
	}
}
