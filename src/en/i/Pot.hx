package en.i;

import mt.Process;
import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.heaps.Controller;

class Pot extends en.Interactive {
	public var output : Null<String>;
	var seed : Null<String>;
	var size : Float;

	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "potEmpty");
		setDepth(Const.DP_MAIN_BG);
		size = 0;
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( output==null ) {
			if( by.use("wood") ) {
				plant("wood");
				pop(Lang.t._("Planted: BAMBOO"), 0x5EB04F);
				//Assets.SBANK.pick0(1);
				Tutorial.ME.nextIfAt(1);
			}
			else if( by.use("food") ) {
				plant("food");
				pop(Lang.t._("Planted: OILY PEAR"), 0x5EB04F);
				//Assets.SBANK.pick0(1);
				Tutorial.ME.nextIfAt(4);
			}
			else
				by.say(Lang.t._("I can plant something here."));
		}
		else {
			if( size<1 ) {
				by.pickItem(seed, cx+1, cy);
				pop(Lang.t._("Picked up too early"), 0xFF0000);
				//Assets.SBANK.pickBad0(1);
			}
			else {
				if( output=="food" )
					game.beginRealGame();
				by.pickItem(output, cx+1, cy);
				var e = new en.i.Item(cx+1,cy,seed);
				e.dx = 0.15;
				e.dy = -0.7;
			}
			output = null;
			seed = null;
			size = 0;
		}
	}

	public function plant(id:String) {
		output = seed = id;
	}

	override public function onFocus() {
		super.onFocus();
		if( output==null )
			showDesc(Lang.t._("An empty pot..."));
		else switch( output ) {
			case "wood" : showDesc(Lang.t._("A bamboo pot. I love bamboo."));
			default : "UNKNOWN POT";
		}

	}

	override public function postUpdate() {
		super.postUpdate();
		if( output!=null && size<1 && !cd.hasSetS("shake", rnd(0.7,1.2)) )
			spr.x += Std.random(2)*2-1;

		if( output!=null ) {
			switch( output ) {
				case "wood" : spr.set("potWood");
				case "food" : spr.set("potFood");
				case "grass" : spr.set("potGrass");
			}
			spr.setFrame(
				size<0.10 ? 0 :
				size<0.5 ? 1 :
				size<1 ? 2 : 3
			);
		}
		else {
			spr.set("potEmpty",0);
		}
	}

	function getGrowDelay() {
		return switch( output ) {
			case "wood" : 30;
			case "food" : 40;
			default : 5;
		}

	}

	override public function update() {
		super.update();

		if( output=="food" )
			Tutorial.ME.nextIfAt(4);

		if( output=="wood" && size>=1 )
			Tutorial.ME.nextIfAt(3);

		if( output!=null ) {
			size += 1 / Const.FPS / getGrowDelay();
			size = MLib.fclamp(size,0,1);
		}
	}
}
