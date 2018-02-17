package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class BatterySlot extends en.Interactive {
	public static var ME : BatterySlot;
	public var count : Int;
	var max : Int;
	var bat : HSprite;

	var cable : HSprite;
	var car : HSprite;
	var wheel : HSprite;

	var running = false;
	var progress : Float;
	var tp : Float;
	var engine : mt.flash.Sfx;

	public function new(x,y) {
		super(x,y);

		ME = this;

		#if !debug
		activationDelay = 2;
		#end
		max = 3;
		count = 0;
		progress = 0;
		tp = 0;
		spr.set(Assets.tiles, "empty");

		engine = Assets.SBANK.engine0();

		bat = Assets.tiles.h_get("battery");
		game.scroller.add(bat, Const.DP_MAIN_BG);
		bat.setCenterRatio(0.5,1);

		cable = Assets.tiles.h_get("cable");
		game.scroller.add(cable, Const.DP_MAIN_BG);

		car = Assets.tiles.h_get("cableCar");
		game.scroller.add(car, Const.DP_MAIN_BG);
		car.setCenterRatio(0.5,0);

		wheel = Assets.tiles.h_get("wheel");
		game.scroller.add(wheel, Const.DP_MAIN_BG);
		wheel.setCenterRatio(0.5,0.5);

		#if debug
		//count = max-1; progress = count/max;
		#end
	}

	override public function beginActivation(by:en.Hero) {
		super.beginActivation(by);
		if( count>=max ) {
			pop(Lang.t._("I don't need that anymore!"), 0xFF0000);
			return false;
		}
		else if( running ) {
			pop(Lang.t._("Under operation, please wait."), 0xFF0000);
			return false;
		}
		else if( !by.has("battery") ) {
			by.say(Lang.t._("I need to put a BATTERY here..."));
			return false;
		}
		return true;
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( by.use("battery") ) {
			count++;

			engine.playLoop(99999, 0);
			engine.setPanning(0.7);
			engine.fade(0.5, 300);
			if( count==max-1 )
				by.say(Lang.t._("One more to go!!"));
			running = true;
			tp = count/max;
		}
	}

	public inline function getRemaining() return max-count;

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("I need to power this in order to escape!"));
	}

	override public function postUpdate() {
		super.postUpdate();
		bat.visible = running;
		bat.setPos(sprX-1, sprY-2);
		bat.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(0xFFAC00, 0.5+0.5*Math.cos(game.ftime*0.55));

		cable.setPos(514,189);
		wheel.setPos(514,189);
		cable.scaleX = 1 + Math.sin(game.ftime*0.020)*0.015;
		//cable.scaleY = 1 + Math.cos(game.ftime*0.030)*0.030;
		if( cd.has("running") ) {
			cable.y+=Math.cos(game.ftime*0.1)*0.5;
			if( cd.has("advancing") ) {
				wheel.y+=rnd(0,1);
				wheel.rotate(-0.01);
			}
		}
		car.x = (lMap.wid-2)*Const.GRID - progress*13*Const.GRID;
		car.y = 237 - progress*34 + Math.sin(progress*3.14)*5;
		car.y += Math.cos(game.ftime*0.030)*2;
		car.rotation = running ? Math.cos(game.ftime*0.13)*0.01 : Math.cos(game.ftime*0.02)*0.02;
	}

	override public function update() {
		super.update();
		if( running && !cd.has("advCd") ) {
			cd.setS("advancing", rnd(0.6,0.8));
			cd.setS("advCd",cd.getS("advancing")+rnd(0.1,0.3));
		}
		if( running )
			progress+=rnd(0,0.002) + (cd.has("advancing")?0.002:0);

		if( running && progress>=tp ) {
			running = false;
			engine.fade(0, 1200);
			cd.unset("advancing");
			if( count>=max )
				game.end();
		}

		//progress = 0.5 + 0.5*Math.cos(game.ftime*0.1);
	}
}
