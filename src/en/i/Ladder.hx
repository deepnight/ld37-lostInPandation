package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class Ladder extends en.Interactive {
	public var active : Bool;
	public var endY : Int;
	public var parts : Array<HSprite>;
	public var topRing : HSprite;
	//public var bottomRing : HSprite;
	public var fragile = false;

	public function new(x,y, act:Bool) {
		super(x,y);

		endY = cy;
		active = false;
		parts = [];
		activationDelay = 0.1;

		spr.set("ladderBottomRingEmpty");
		setDepth(Const.DP_MAIN_FRONT);
		topRing = Assets.tiles.h_get("ladderRingEmpty",0, 0,1);
		Game.ME.scroller.add(topRing, Const.DP_MAIN_FRONT);

		// Parse height
		var y = cy;
		while( true ) {
			if( lMap.hasAnyColl(cx,y) )
				break;

			if( !lMap.hasAnyColl(cx+1,y-1) && lMap.hasAnyColl(cx+1,y) ) {
				dir = 1;
				endY = y;
				break;
			}

			if( !lMap.hasAnyColl(cx-1,y-1) && lMap.hasAnyColl(cx-1,y) ) {
				dir = -1;
				endY = y;
				break;
			}

			y--;
		}

		if( act )
			deploy();
	}

	override public function dispose() {
		super.dispose();
		topRing.remove();
		for(s in parts)
			s.remove();
		parts = null;
	}

	function deploy() {
		fragile = false;
		active = true;
		topRing.set("ladderRing");
		spr.set("ladderBottomRing");
		shake();

		for(i in 1...(cy-endY)+1) {
			var s = Assets.tiles.h_getRandom(i==cy-endY ? "ladderEnd" : "ladder");
			parts.push(s);
			Game.ME.scroller.add(s, Const.DP_MAIN_FRONT);
			s.setCenterRatio(0.5,1);
			s.setPos(sprX, sprY-i*Const.GRID);
		}
	}

	public function onEndClimb() {
		if( fragile )
			breakLadder();
	}

	public function setFragile() {
		pop(Lang.t._("Ladder damaged"), 0xBC3D12);
		fragile = true;
		var i = 0;
		for(s in parts) {
			s.set( i==cy-endY ? "ladderEndB" : "ladderB" );
			i++;
		}
		spr.set("ladderBottomRingB");
	}

	public function breakLadder() {
		for(e in parts)
			e.remove();
		parts = [];
		fx.brokenLadder(this);
		active = false;
		pop(Lang.t._("Ladder broke"), 0xFF0000);
		spr.set("ladderBottomRingEmpty");
	}

	public function shake() {
		cd.setS("shake", rnd(1,1.5));
		cd.setS("superShake", 0.2);
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( !active ) {
			if( by.hasLast("wood") )
				hero.say(Lang.t._("I shouldn't use my BAMBOO here, it's my last one... "), 0xC40000);
			else if( by.use("wood") )
				deploy();
			else
				by.say(Lang.t._("I need bamboo here."));
		}
		else {
			shake();
			by.climb(this);
		}
	}

	override public function postUpdate() {
		super.postUpdate();

		if( dir==-1 )
			spr.x++;

		//var superShake = cd.has("superShake");
		var pow = 1.1*cd.getRatio("shake");

		//spr.y += pow*rnd(0,1);
		topRing.x = ( dir==1 ? (cx+2)*Const.GRID : (cx-1)*Const.GRID );
		topRing.y = endY*Const.GRID+5 + pow * rnd(0,1);
		topRing.scaleX = -dir;
		topRing.visible = false;
		var i = 0;
		var off = rnd(0,1,true);
		for(s in parts) {
			if( cd.has("shake") ) {
				s.x = sprX + pow * (i/parts.length) * Math.cos(2*i/parts.length + Game.ME.ftime*0.5);
				//s.x = sprX + pow*Math.cos(2*i/parts.length + Game.ME.ftime*0.5);
				if( cd.has("superShake") )
					s.x += off * (i/parts.length);
				//s.rotation = rnd(0,0.02,true);
			}
			else
				s.rotation = 0;

			s.y = sprY-(i+1)*Const.GRID;
			i++;
		}
	}

	override public function update() {
		super.update();
	}
}
