import mt.MLib;
import mt.deepnight.Lib;

class Viewport extends mt.Process {
	public var x : Float;
	public var y : Float;
	public var dx : Float;
	public var dy : Float;
	public var wid(get,never) : Float;
	public var hei(get,never) : Float;
	var frict = 0.9;
	var target : Entity;
	public var tracking : Bool;
	public var slow = false;

	public var top(get,never) : Float; inline function get_top() return y-hei*0.5;
	public var bottom(get,never) : Float; inline function get_bottom() return y+hei*0.5;

	public function new() {
		super(Game.ME);
		tracking = true;
		x = y = 0;
		dx = dy = 0;
	}

	public function track(e:Entity) {
		target = e;
		x = e.sprX;
		y = e.sprY;
	}

	inline function get_wid() return w()/Const.SCALE;
	inline function get_hei() return h()/Const.SCALE;
	//inline function get_wid() return w()/Const.SCALE;
	//inline function get_hei() return h()/Const.SCALE;

	override public function update() {
		super.update();

		if( tracking ) {
			var tx = target.sprX;
			var ty = target.sprY - 30;
			var d = Lib.distance(tx, ty, x, y);
			if( d>=10 ) {
				var s = 2 * MLib.fclamp((d-10)/100, 0, 1) * (slow?0.15:1);
				var a = Math.atan2(ty-y, tx-x);
				dx+=Math.cos(a)*s;
				dy+=Math.sin(a)*s;
			}
		}

		x+=dx;
		y+=dy;

		dx*=frict;
		dy*=frict;

		x = MLib.fclamp(x, wid*0.5, Game.ME.lMap.lData.width*Const.GRID-wid*0.5);
		y = MLib.fclamp(y, hei*0.5, Game.ME.lMap.lData.height*Const.GRID-hei*0.5);

		Game.ME.scroller.setPosition( -(x-wid*0.5), -(y-hei*0.5) );
		//Game.ME.scroller.setPosition( Std.int( -(x-wid*0.5) ), Std.int( -(y-hei*0.5) ) );
	}
}