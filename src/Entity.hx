import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.deepnight.Tweenie;

class Entity {
	static var UNIQ = 0;
	public static var ALL : Array<Entity> = [];
	public static var GC : Array<Entity> = [];

	public var uid : Int;
	public var cx : Int;
	public var cy : Int;
	public var xr : Float;
	public var yr : Float;
	public var dx : Float;
	public var dy : Float;
	public var dir(default,set) : Int;

	public var sprX(get,never) : Float; inline function get_sprX() return Std.int((cx+xr)*Const.GRID);
	public var sprY(get,never) : Float; inline function get_sprY() return Std.int((cy+yr)*Const.GRID);

	public var frict : Float;
	public var gravity = 0.09;
	public var lastStableY : Int;
	var hasGravity = true;

	public var spr : HSprite;
	public var cd : mt.Cooldown;
	public var destroyed : Bool;
	public var onGround(get,never) : Bool;
	var fallStartY : Float;

	var lMap(get,never) : LevelMap; inline function get_lMap() return Game.ME.lMap;
	var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	var hero(get,never) : en.Hero; inline function get_hero() return Game.ME.hero;
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var ui(get,never) : Ui; inline function get_ui() return Game.ME.ui;

	var focus : HSprite;
	//var desc : Null<mt.data.GetText.LocaleString>;
	var descTf : h2d.Text;

	private function new(x,y) {
		ALL.push(this);
		uid = UNIQ++;
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
		lastStableY = 0;
		dx = dy = 0;
		fallStartY = sprY;
		frict = 0.8;
		dir = 1;
		destroyed = false;
		cd = new mt.Cooldown(Const.FPS);

		spr = new HSprite(Assets.tiles);
		Game.ME.scroller.add(spr, Const.DP_MAIN);
		spr.setCenterRatio(0.5,1);

		focus = Assets.tiles.h_get("focus");
		Game.ME.scroller.add(focus, Const.DP_MAIN);
		focus.setCenterRatio(0.5,0.5);
		focus.visible = false;

		descTf = new h2d.Text(Assets.font);
		Game.ME.scroller.add(descTf, Const.DP_UI);
		if( cy<=20 ) {
			descTf.setPos(26*Const.GRID, 13*Const.GRID);
			descTf.maxWidth = (45-26)*Const.GRID;
		}
		else {
			descTf.setPos(20*Const.GRID, 25*Const.GRID);
			descTf.maxWidth = (45-20)*Const.GRID;
		}
		descTf.textAlign = sprX<descTf.x+descTf.maxWidth*0.4 ? Left : sprX>descTf.x+descTf.maxWidth*0.6 ? Right : Center;
	}

	public inline function setDepth(l:Int) {
		Game.ME.scroller.add(spr, l);
	}

	public function setPosCase(x,y) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
		fallStartY = sprY;
	}

	public function onFocus() {
		showFocus();
	}
	public function onBlur() {
		hideDesc();
		hideFocus();
	}

	function hideFocus() focus.visible = false;
	function showFocus() {
		//focus.setScale(2);
		focus.visible = true;
	}

	public function showDesc(str:mt.data.GetText.LocaleString, ?c=0x7887C2) {
		descTf.text = str;
		descTf.textColor = c;
		descTf.visible = true;
		Game.ME.tw.createS(descTf.alpha, 0>1, 0.2);
	}

	public function hideDesc() {
		Game.ME.tw.createS(descTf.alpha, 0, 0.3).end( function() {
			descTf.visible = false;
		});
	}

	public inline function popDebug(txt:Dynamic, ?c=0xFF00FF) {
		pop(Lang.t.untranslated(txt), c);
	}

	public function pop(txt:mt.data.GetText.LocaleString, ?c=0xffffff) {
		var txt = Std.string(txt);
		var tf = new h2d.Text(Assets.font);
		Game.ME.scroller.add(tf, Const.DP_UI);
		tf.text = txt;
		tf.x = sprX-tf.textWidth*0.5;
		tf.y = sprY-Const.GRID*1.5;
		tf.textColor = c;
		Game.ME.tw.createS(tf.y, tf.y-30, TEaseOut, 0.3).end( function() {
			var t = Game.ME.tw.createS(tf.alpha, 0, 0.5).end( function() {
				tf.remove();
			});
			t.delay = Std.int( Game.ME.secToFrames(0.2 + txt.length*0.015) );
		});
	}

	public inline function secToFrames(v) return Game.ME.secToFrames(v);
	public inline function rnd(min, max, ?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min, max, ?sign) return Lib.irnd(min,max,sign);
	public inline function rndSeconds(min, max, ?sign) return MLib.round( secToFrames( Lib.rnd(min,max,sign) ) );
	public inline function dist(e:Entity) return Lib.distance(sprX, sprY, e.sprX, e.sprY);
	public inline function distCase(e:Entity) return Lib.distance(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	public inline function pretty(v:Float,?p=2) return Lib.prettyFloat(v,p);
	public inline function is<T:Entity>( t : Class<T> ) : Bool return Std.is(this, t);
	public inline function dirTo(e:Entity) return e.sprX<sprX ? -1 : 1;

	inline function set_dir(v) return dir = v<0 ? -1 : 1;

	inline function get_onGround() {
		return yr==1 && dy==0 && lMap.hasAnyColl(cx,cy+1);
	}

	public inline function destroy() {
		if( !destroyed ) {
			GC.push(this);
			destroyed = true;
		}
	}

	public function dispose() {
		ALL.remove(this);

		spr.remove();
		spr = null;
	}

	public function preUpdate(dt:Float) {
		cd.update(dt);
	}

	public function postUpdate() {
		spr.x = sprX;
		spr.y = sprY;
		spr.scaleX = dir;

		focus.scaleX += (1-focus.scaleX)*0.3;
		focus.scaleY += (1-focus.scaleY)*0.3;
		//focus.rotation*=0.65;
		focus.setPos(sprX, sprY-Const.GRID*0.5);
		focus.alpha = 1 - MLib.fabs( 0.7*Math.cos(Game.ME.ftime*0.2) );
	}

	function onLand(caseHei:Float) {}

	public function update() {
		var repel = 0.08;
		var repelF = 0.6;
		// X
		xr+=dx;
		if( xr>=0.9 && lMap.hasHardColl(cx+1,cy) ) { xr = 0.9; }
		if( xr>0.8 && lMap.hasHardColl(cx+1,cy) ) {
			dx*=repelF;
			dx -= repel;
		}

		if( xr<=0.1 && lMap.hasHardColl(cx-1,cy) ) { xr = 0.1; }
		if( xr<0.2 && lMap.hasHardColl(cx-1,cy) ) {
			dx*=repelF;
			dx += repel;
		}

		while( xr>1 ) { xr--; cx++; }
		while( xr<0 ) { xr++; cx--; }
		dx*=frict;
		if( MLib.fabs(dx)<=0.01 ) dx = 0;

		// Y
		if( hasGravity && !onGround )
			dy+=gravity;
		yr+=dy;
		if( dy<=0 )
			fallStartY = sprY;
		if( yr>1 && lMap.hasAnyColl(cx,cy+1) ) {
			dy = 0;
			yr = 1;
			onLand( (sprY-fallStartY)/Const.GRID );
		}
		if( yr<=0.6 && lMap.hasHardColl(cx,cy-1) ) { dy = 0; yr = 0.6; }
		if( yr<0.2 && lMap.hasHardColl(cx,cy-1) ) {
			dy*=repelF;
			dy += repel;
		}

		while( yr>1 ) { yr--; cy++; }
		while( yr<0 ) { yr++; cy--; }
		dy*=frict;
		if( MLib.fabs(dy)<=0.01 ) dy = 0;

		if( onGround )
			lastStableY = cy;
	}
}