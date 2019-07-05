package en;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.heaps.Controller;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	var ang : Float;
	var tentacles : Array<{s:HSprite, spd:Float, a:Float, off:Float, ox:Float, oy:Float}> = [];
	var cores : Array<{s:HSprite, ox:Float, oy:Float, a:Float, spd:Float}> = [];
	var eyes : HSprite;
	var col : UInt;

	public function new(x,y) {
		super(x,y);

		ALL.push(this);
		spr.set("empty");
		ang = 0;

		var cols = [ 0x0E2C34, 0x280F33, 0x38140A, 0x10321C ];
		col = cols[Std.random(cols.length)];

		var n = 12;
		for(i in 0...n) {
			var s = Assets.tiles.h_getAndPlay("tentacle");
			game.scroller.add(s, Const.DP_MAIN_FRONT);
			tentacles.push({ s:s, spd:rnd(0.6,1), a:6.28*i/n+rnd(0,0.2,true), off:rnd(0,6.28), ox:rnd(0,3,true), oy:rnd(0,3,true) });

			s.anim.setSpeed(rnd(0.10,0.15));
			s.setCenterRatio(0.5,0.9);
			s.anim.unsync();
			s.rotation = rnd(0,6.28);
			var c = mt.deepnight.Color.hueInt(col, rnd(0,0.05,true));
			s.colorize( Color.brightnessInt(c,rnd(0,0.5)) );
		}

		var n = 3;
		for(i in 0...n) {
			var s = Assets.tiles.h_getAndPlay("tcore");
			game.scroller.add(s, Const.DP_MAIN_FRONT);
			cores.push( { s:s, spd:rnd(0.8,1), a:6.28*i/n + rnd(0,0.3,true), ox:rnd(0,3,true), oy:rnd(0,3,true) } );
			s.setCenterRatio(0.5,0.5);
			s.colorize( mt.deepnight.Color.brightnessInt( mt.deepnight.Color.hueInt(col, rnd(0,0.1,true)), i/(n-1)*0.5 ) );
		}

		eyes = Assets.tiles.h_get("eyes");
		eyes.setCenterRatio(0.5,0.5);
		game.scroller.add(eyes, Const.DP_MAIN_FRONT);
		eyes.blendMode = Add;

		dir = Std.random(2)*2-1;
		cd.setS("spawn", rnd(1.8,3));
		dx = rnd(0,0.1,true);
		dy = -rnd(0.9,1.1);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		for(s in tentacles) s.s.remove();
		for(s in cores) s.s.remove();
		eyes.remove();
	}

	public function kill() {
		fx.mobDeath(sprX, sprY-10, col);
		destroy();
	}

	override public function postUpdate() {
		super.postUpdate();

		var ss = cd.has("spawn") ? 0.3 + 0.7 * (1-cd.getRatio("spawn")) : 1;

		var i = 0;
		for(s in cores) {
			s.s.setPosition(sprX+s.ox, sprY+s.oy-6*ss);
			s.s.rotation = ang + s.a;
			s.s.setScale(ss);
			i++;
		}
		var i = 0;
		for(s in tentacles) {
			s.s.setPosition(sprX+s.ox, sprY+s.oy-7*ss);
			s.s.rotation = ang + s.a + 0.3 * Math.sin(s.off + game.ftime*0.02 * s.spd);
			var a = s.s.rotation;
			var d = mt.deepnight.Lib.angularDistanceRad(3.14,a);
			var r = MLib.fclamp(d/0.85, 0, 1);
			s.s.setScale( (0.25+r*0.50 ) * ss );
			i++;
		}

		eyes.setPosition(sprX+dir*2, sprY-10*ss);
		eyes.setScale(ss);
		eyes.scaleX *= dir;
	}

	inline function isAngry() {
		return cd.has("anger");
	}

	inline function nearEnd() {
		return lMap.hasAnyColl(cx+dir,cy) || !lMap.hasAnyColl(cx+dir,cy+1);
	}

	function canReach(e:Entity) {
		if( cy!=e.lastStableY )
			return false;

		var x = cx;
		while( x!=e.cx ) {
			x+=dirTo(e);
			if( lMap.hasAnyColl(x,cy) || !lMap.hasAnyColl(x,cy+1) )
				return false;
		}
		return true;
	}

	override public function update() {
		super.update();

		if( cd.has("spawn") ) {
			return;
		}

		if( !cd.has("turning") && !cd.has("iaLock") ) {
			var spd = isAngry() ? 2 : 0.8;
			if( isAngry() ) {
				dir = dirTo(hero);
			}

			#if debug
			//var ok = canReach(hero);
			//for(s in tentacles) s.s.alpha = ok ? 1 : 0.5;
			//for(s in cores) s.s.alpha = ok ? 1 : 0.5;
			#end

			// Detect hero
			if( (dirTo(hero)==dir && MLib.fabs(hero.cx-cx)<=7 || dirTo(hero)!=dir && MLib.fabs(hero.cx-cx)<=2 ) && MLib.fabs(hero.cy-cy)<=2 && canReach(hero) ) {
				if( onGround && !isAngry() ) {
					cd.setS("iaLock", 0.5);
					dy = -0.5;
				}
				cd.setS("anger", 3.5);
			}

			if( !cd.has("iaLock") && !nearEnd() && onGround && !cd.has("step") ) {
				cd.setS("step", rnd(0.35,0.5));
				cd.setS("moving", rnd(0.1,0.3));
			}
			if( cd.has("moving") )
				dx += dir * rnd(0.02,0.05) * spd * tmod;

			if( dx!=0 ) {
				var i = 0;
				for(c in cores) {
					c.a-=dx*0.3 * i/cores.length;
					i++;
				}
				ang+=dx;
			}

			if( !cd.has("iaLock") && nearEnd() ) {
				dx*=Math.pow(0.2,tmod);
				dy*=Math.pow(0.5,tmod);
				if( !isAngry() ) {
					dy = -0.3;
					var d = -dir;
					cd.setS("turning", 0.5, function() dir=d);
				}
			}

			// Kill hero
			if( onGround && distCase(hero)<=2.5 && !nearEnd() )
				dy = -rnd(0.2,0.4);

			//if( distCase(hero)<=3.5 )
				//hero.cd.setS("mobCold", 2);

			if( distCase(hero)<=0.8 && hero.climbTarget==null ) {
				//Assets.SBANK.death0(1);
				hero.die(Lang.t._("Eaten by a... SOMETHING"), true);
			}
		}
	}
}