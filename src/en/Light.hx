package en;


class Light extends Entity {
	var wasOff = true;

	public function new(x,y) {
		super(x,y);

		spr.set(Assets.tiles, "light");
		spr.alpha = 0;
		spr.setCenterRatio(0.5,0.5);
		hasGravity = false;
		//spr.blendMode = Add;
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.x+=5;
		spr.y+=2;
		if( !game.gen.empty() ) {
			spr.alpha = cd.has("flicker") ? rnd(0.2,0.4) : rnd(0.9,1);
		}
		else {
			spr.alpha+=(0-spr.alpha)*0.1;
		}
		spr.alpha*=game.gen.ratio();
	}


	override public function update() {
		super.update();
		if( wasOff && game.gen.hasCharge() ) {
			cd.setS("flicker", rnd(0.6,0.8));
			cd.setS("flickerCd", cd.getS("flicker")+rnd(3,10));
		}

		if( !cd.has("flickerCd") ) {
			cd.setS("flicker", rnd(0.3,1));
			cd.setS("flickerCd", cd.getS("flicker")+rnd(3,10));
		}
		wasOff = game.gen.empty();
	}
}
