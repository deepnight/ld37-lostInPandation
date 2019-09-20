package en.i;


class Generator extends en.Interactive {
	public var charge : Int;
	public var max : Int;
	public var jauge : GeneratorJauge;

	public function new(x,y) {
		super(x,y);

		charge = 0;
		max = 3;
		spr.set(Assets.tiles, "generator");
		spr.setCenterRatio(0.7,1);

		jauge = new en.i.GeneratorJauge(34,15, this);
	}

	public function hasCharge() return charge>0;
	public function empty() return charge<=0;
	public function has(n) return charge>=n;
	public function ratio() return charge/max;

	override public function activate(by:en.Hero) {
		super.activate(by);
		if( charge>=max ) {
			jauge.pop(Lang.t._("Already full"), 0xFFBF00);
		}
		//else if( by.hasLast("food") && BatterySlot.ME.getRemaining()>1 ) {
			//hero.say(Lang.t._("I shouldn't use this FRUIT here, it's my last one... Better idea to plant it first, and produce more after."), 0xC40000);
		//}
		else if( by.use("food") ) {
			charge += 2;
			//Assets.SBANK.generator0(1);
			game.beginRealGame();
			showCap();
		}
		else if( by.hasLast("wood") && BatterySlot.ME.getRemaining()>1 ) {
			hero.say(Lang.t._("I shouldn't use this BAMBOO here, it's my last one... Better idea to plant it first, and produce more after."), 0xC40000);
		}
		else if( by.useAny(["wood","plank"]) ) {
			charge++;
			//Assets.SBANK.generator0(1);
			game.beginRealGame();
			showCap();
			by.say(Lang.t._("It's a better idea to use OILY PEARS here..."));
		}
		else {
			hero.say(Lang.t._("[Please insert FRUIT, BAMBOO or PLANK to refill the generator]"));
		}
		charge = M.iclamp(charge,0,max);
	}

	inline function showCap() {
		jauge.pop(Lang.t._("Generator capacity: ::n::/::max::", {n:charge, max:max}));
	}

	public function useCharge(v:Int) {
		if( charge<v )
			return false;
		charge-=v;
		showCap();
		return true;
	}

	override public function onFocus() {
		super.onFocus();
		showDesc(Lang.t._("The main generator"));
	}

	override public function postUpdate() {
		super.postUpdate();

		if( hasCharge() ) {
			spr.scaleX = 1+M.fabs( Math.cos(game.ftime*0.2)*0.05 );
			spr.scaleY = 1/spr.scaleX;
			spr.x+=rnd(0,1);
		}
		else
			spr.setScale(1);
	}

	override public function update() {
		super.update();
	}
}
