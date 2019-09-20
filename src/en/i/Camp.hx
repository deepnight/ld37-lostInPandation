package en.i;


class Camp extends en.Interactive {
	static var DECAY_DELAY = 40;
	public var power : Int;
	public var range = 4;
	var shine : HSprite;

	public function new(x,y) {
		super(x,y);

		power = 1;
		cd.setS("decay", getDecayDelay());
		spr.set(Assets.tiles, "camp");
		shine = Assets.tiles.h_get("campShine");
		shine.setCenterRatio(0.5,1);
		Game.ME.scroller.add(shine, Const.DP_MAIN);
	}

	public inline function isOn() return power>0;

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( power>=3 ) {
			by.say( Lang.t._("The fire is at max capacity.") );
		}
		else if( by.has("wood") && game.isLastItem("wood") ) {
			hero.say(Lang.t._("I shouldn't burn my BAMBOO, it's my last one... "), 0xC40000);
		}
		else if( by.useAny(["wood","plank"]) ) {
			power++;
			//Assets.SBANK.burn0(0.2);
			cd.setS("decay", getDecayDelay());
			Tutorial.ME.nextIfAt(2);
		}
		else {
			hero.say(Lang.t._("I need some combustible."));
		}
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("A fire camp"));
	}

	//override public function canBeActivated(by:en.Hero) {
		//return by.hasAny(["wood","grass"]);
	//}

	override public function postUpdate() {
		super.postUpdate();
		if( power>0 ) {
			fx.camp(sprX, sprY, power);
			shine.setPosition(sprX, sprY);
			shine.visible = true;
			shine.alpha = 0.7 + 0.3* Math.cos(Game.ME.ftime*0.2) + rnd(0,0.1,true);
			//spr.x +=rnd(0,1,true);
		}
		else
			shine.visible = false;
	}

	function getDecayDelay() {
		return switch( power ) {
			case 3 : 35;
			case 2 : 40;
			case 1 : 45;
			default : 0;
		}
	}

	override public function update() {
		super.update();
		if( power>1 )
			Tutorial.ME.nextIfAt(2);

		if( power>0 && !cd.has("decay") ) {
			power--;
			cd.setS("decay", getDecayDelay());
		}
	}
}
