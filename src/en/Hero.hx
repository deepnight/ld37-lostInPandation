package en;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class Hero extends Entity {
	var controller : ControllerAccess;
	var selection : Null<Interactive>;
	var tf : h2d.Text;
	var item : Null<String>;
	public var climbTarget : Null<en.i.Ladder>;
	public var dead = false;

	public var heat : Float;
	public var life : Float;

	public var bodyTemp(get,never) : Int;

	//var cold : h3d.Vector;
	var coldPow : Float;
	var backIcon : HSprite;

	public function new(x,y, ?d=-1) {
		super(x,y);
		controller = Main.ME.controller.createAccess("hero");
		dir = !Math.isNaN(d) ? d : 1;

		spr.set(Assets.tiles, "heroIdle");
		spr.anim.registerStateAnim("heroClimbIdle", 4, function() return climbTarget!=null);
		spr.anim.registerStateAnim("heroJumpUp", 3, function() return !onGround && dy<0);
		spr.anim.registerStateAnim("heroJumpDown", 3, function() return !onGround && dy>=0);
		spr.anim.registerStateAnim("heroWalk", 2, 0.22, function() return onGround && MLib.fabs(dx)>0.05);
		spr.anim.registerStateAnim("heroHeat", 1, 0.05, function() return cd.has("heating"));
		spr.anim.registerStateAnim("heroIdle", 0);

		life = 1;
		heat = 1;
		coldPow = 0;

		backIcon = new HSprite(Assets.tiles);
		Game.ME.scroller.add(backIcon, Const.DP_MAIN_BG);
		backIcon.setCenterRatio(0.5,1);

		tf = new h2d.Text(Assets.font);
		Game.ME.scroller.add(tf, Const.DP_UI);

		//cold = h3d.Vector.fromColor(0x113860,0.5);

		//spr.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(0x4067A2,0.7);
	}


	public inline function has(itemId:String) return item==itemId;
	public inline function hasLast(itemId:String) return has(itemId) && game.isLastItem(item);

	public function hasAny(ids:Array<String>) {
		for(id in ids)
			if( item==id ) return true;
		return false;
	}

	public inline function noItem() return item==null;

	public function use(itemId:String) {
		if( item==itemId ) {
			destroyItem();
			return true;
		}
		else
			return false;
	}

	public function useAny(ids:Array<String>) {
		for(id in ids)
			if( use(id) )
				return true;
		return false;
	}

	public function destroyItem() {
		item = null;
	}

	public function dropItem() {
		if( item==null )
			return;

		var e = new en.i.Item(cx,cy, item);
		e.yr = 0.5;
		item = null;
		//Assets.SBANK.drop0(0.5);
	}

	public function pickItem(id:String) {
		//Assets.SBANK.pick1(1);
		dropItem();
		backIcon.set(id);
		item = id;
	}


	public inline function isOverMarker(m:Data.Level_markers) {
		return cx>=m.x && cx<m.x+m.width && cy>=m.y && cy<m.y+m.height;
	}


	override public function postUpdate() {
		super.postUpdate();
		tf.visible = item!=null;
		if( tf.visible ) {
			tf.x = Std.int( sprX - tf.textWidth*0.5 );
			tf.y = Std.int( sprY - tf.textHeight*0.5 - 10 );
		}

		backIcon.visible = item!=null;
		if( item!=null ) {
			backIcon.setPosition(sprX-dir*1, spr.y-12);
			backIcon.rotation = -dir*switch( item ) {
				case "battery", "food" : backIcon.x-=dir*4; backIcon.y+=5; -0.2;
				default : 1.4;
			}
		}

		//cold.
		coldPow += ( MLib.fclamp((-bodyTemp+1)/3, 0, 1) - coldPow ) * 0.2;
		spr.colorAdd = h3d.Vector.fromColor(0x113860,coldPow);
	}


	public function climb(e:en.i.Ladder) {
		climbTarget = e;
		setPosCase(climbTarget.cx, climbTarget.cy);
		if( sprX>climbTarget.sprX )
			xr = 0.8;
		else
			xr = 0.2;
		yr = 1;
		dx = 0;
		dir = climbTarget.dir;
		hasGravity = false;
	}


	override function onLand(ch) {
		super.onLand(ch);
		//if( ch>=3 )
			//Assets.SBANK.land1(0.2);
		//else
			//Assets.SBANK.land0(0.4);
		if( ch>=3 ) {
			dx *= 0.2;
			lockControlS(0.2);
			spr.anim.play("heroLand").setSpeed(0.06);
		}
		else
			dx*=0.4;
	}

	public inline function controlsLocked() return cd.has("controls") || Console.ME.isActive();
	public inline function lockControlS(t:Float) {
		cd.setS("controls", t);
	}
	public inline function unlockControls() {
		cd.unset("controls");
	}


	function delayedAction(cb:Void->Void, sec:Float) {
		dx*=0.3;
		lockControlS(sec);
		spr.anim.playAndLoop("heroUse").setSpeed(0.2);
		Game.ME.delayer.addS( function() {
			spr.anim.stopWithStateAnims();
			cb();
		}, sec );

	}

	public function say(str:mt.data.GetText.LocaleString, ?c:UInt) {
		game.message(str, c);
		//pop(str, 0x98D3D2);
	}

	public inline function isOutside() {
		return cx<=19 || cx>=46;
	}

	function get_bodyTemp() {
		return
			( isOutside() ? game.outsideTemp : game.insideTemp )
			+ ( distCase(game.camp)<=game.camp.range && game.camp.isOn() ? game.camp.power : 0 )
			+ ( cd.has("mobCold") ? -3 : 0 );
		//return game.insideTemp
			//+ ( cx<=25 ? -1 : 0 )
			//+ ( cx<=19 || cx>=46 ? -2 : 0 )
			//+ ( distCase(game.camp)<=game.camp.range && game.camp.isOn() ? 2 : 0 );
	}


	public function die(reason:mt.data.GetText.LocaleString) {
		if( cd.hasSetS("death", 9999) )
			return;

		dead = true;
		lockControlS(999);
		spr.anim.play("heroDeath").setSpeed(0.3).stopOnLastFrame();
		fx.flashBang(0xFF0000,0.5,2);
		game.message( reason, 0xFF0000, true );
		//pop( Lang.t._("You died: ::reason::",{reason:reason}), 0xFF0000 );
		game.delayer.addS(game.restart, 2.8);
		if( item!=null )
			dropItem();
		if( selection!=null )
			selection.onBlur();
	}

	var idle = 0;
	override public function update() {
		super.update();
		if( dead )
			return;

		// Manage Selection
		if( game.cm.isEmpty() && onGround && !cd.hasSetS("selection", 0.1) ) {
			var dh = new DecisionHelper( Interactive.ALL );
			//dh.remove( function(e) return !e.canBeActivated(this) || distCase(e)>1.7 );
			dh.remove( function(e) return distCase(e)>2 );
			dh.score( function(e) return e.is(en.i.Item) ? 0.5 : 0 );
			dh.score( function(e) return -distCase(e) );
			var best = dh.getBest();
			if( selection!=best ) {
				if( selection!=null )
					selection.onBlur();
				selection = best;
				if( selection!=null )
					selection.onFocus();
			}
		}
		if( !onGround && selection!=null ) {
			selection.onBlur();
			selection = null;
		}

		// Idle anims
		if( !isOutside() && onGround && dx==0 && !cd.has("heating") ) {
			if( idle<=0 ) {
				if( Std.random(2)==0 )
					spr.anim.play("heroCheck");
				else
					spr.anim.play("heroScratch");
				idle = rndSeconds(3.5,6);
			}
			idle--;
		}
		else
			idle = rndSeconds(1,2);

		// Cancel idles
		if( MLib.fabs(dx)!=0 || !onGround ) {
			if( spr.anim.isPlaying("heroCheck") || spr.anim.isPlaying("heroScratch") )
				spr.anim.stopWithStateAnims();
		}


		if( climbTarget!=null ) {
			xr += ( (dir==-1?0.8:0.2) - xr ) * 0.2;
			if( !cd.has("climbHop") ) {
				// Auto climb
				cd.setS("climbHop",99999);
				dx = 0;
				xr = 0.5 + rnd(0,0.15)*-dir;
				//xr = dir==-1 ? rnd(0.5,0.65) : rnd(0.35,0.5);
				dy = -rnd(0.5,0.7);
				spr.anim.play("heroClimb").setSpeed(0.2);
				climbTarget.shake();
				hasGravity = true;
			}

			if( dy>0 ) {
				dy = -rnd(0.1,0.2);
				hasGravity = false;
				cd.setS("climbHop",rnd(0.2,0.4),true);
			}

			if( cy<=climbTarget.endY+1 ) {
				// Done
				climbTarget.onEndClimb();
				setPosCase(cx, climbTarget.endY-1);
				xr = 0.5;
				yr = 1;
				dir = climbTarget.dir;
				dx = dir*0.2;
				dy = -0.5;
				hasGravity = true;
				spr.anim.stopWithStateAnims();
				climbTarget = null;
				cd.unset("climbHop");
				lockControlS( 0.2 );
			}
		}
		else {
			if( !controlsLocked() ) {
				// Controls
				var s = 0.072 * ( spr.is("heroWalk",1) || spr.is("heroWalk",3) ? 0.75 : 1 ) * (isOutside() ? 0.4 : 1);
				spr.anim.setGlobalSpeed( isOutside() ? 0.5 : 1 );

				if( controller.leftDown() ) {
					dir = -1;
					dx-=s;
				}
				else if( controller.rightDown() ) {
					dir = 1;
					dx+=s;
				}
				else
					dx*=0.8;

				if( onGround && selection!=null && ( controller.xPressed() || controller.isKeyboardPressed(hxd.Key.UP) && selection.is(en.i.Ladder) ) ) {
					if( selection.beginActivation(this) )
						if( selection.activationDelay<=0 )
							selection.activate(this);
						else {
							delayedAction(function() {
								if( selection!=null )
									selection.activate(this);
							}, selection.activationDelay);
						}
				}

				//if( controller.xPressed() && item!=null && selection==null )
					//delayedAction(dropItem, 0.15);

				if( onGround )
					cd.setS("onGroundRecent", 0.1);

				if( cd.has("onGroundRecent") && !controlsLocked() && controller.aPressed() ) {
					// Jump start
					cd.setS("jumpPow", 0.2);
					dy = -0.35;
					dx*=1.2;
					//Assets.SBANK.jump0(0.4);
				}
				if( cd.has("jumpPow") )
					dy -= 0.13;

				if( controller.bPressed() && item!=null)
					delayedAction(dropItem, 0.15);
			}
		}

		if( dx==0 && game.camp.isOn() && distCase(game.camp)<=game.camp.range ) {
			dir = dirTo(game.camp);
			cd.setS("heating", 0.1);
		}

		if( game.cm.isEmpty() ) {
			ui.heat.setWarn(0);
			switch( bodyTemp ) {
				case -4, -5, -6, -7 :
					ui.heat.setWarn(2);
					heat-=0.0050;
				case -2, -3 :
					ui.heat.setWarn(2);
					heat-=0.0020;
				case -1 :
					ui.heat.setWarn(1);
					heat-=0.0008;
				case 0 :
					ui.heat.setWarn(1);
					heat-=0.0004;
				case 1 :
					heat+=0.0045;
				case 2 :
					heat+=0.0080;
				case 3,4,5,6 :
					heat+=0.0150;
				default : popDebug("Unknown temp "+bodyTemp);
			}
			heat = MLib.fclamp(heat,0,1);
			ui.heat.set(heat);
			if( heat<=0 ) {
				//Assets.SBANK.death1(1);
				die(Lang.t._("You froze to death."));
			}
		}

		// Death
		if( cy>=lMap.hei+2 ) {
			//Assets.SBANK.death0(1);
			die( Lang.t._("You are a panda, not a bird.") );
		}

		#if debug
		if( controller.rbPressed() ) {
			//game.message(Lang.t._("The main generator must be charged if I want to produce a BATTERY here."));
			//game.end();
			game.addMob();
			//fx.mobDeath(hero.sprX, hero.sprY-10, 0x2F4925);
			//spr.anim.play("heroDeath").setSpeed(0.3).stopOnLastFrame();
		}
		#end

		if( game.cm.isEmpty() && heat<=0.25 && !cd.hasSetS("alarm",0.5) )
			fx.flashBang(0xFF0000,0.2,0.3);

		if( !Console.ME.isActive() && controller.isKeyboardPressed(hxd.Key.M) ) {
			if( mt.deepnight.Sfx.toggleMuteGroup(1) ) {
				mt.deepnight.Sfx.muteGroup(0);
				pop(Lang.t._("Music ON"), 0xFFFF80);
			}
			else {
				mt.deepnight.Sfx.unmuteGroup(0);
				pop(Lang.t._("Music OFF"), 0xFF4A2B);
			}
		}

		if( !Console.ME.isActive() && controller.selectPressed() )
			Game.ME.restart();

		if( !Console.ME.isActive() && controller.isKeyboardPressed(hxd.Key.ENTER) && controller.isKeyboardDown(hxd.Key.ALT) )
			game.engine.fullScreen = !game.engine.fullScreen;

		if( cx<=45 && !Tutorial.ME.started() )
			Tutorial.ME.next();
	}
}
