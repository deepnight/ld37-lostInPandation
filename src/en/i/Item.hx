package en.i;


class Item extends en.Interactive {
	public var id : String;
	var sideBumps = 0;

	public function new(x,y, id) {
		super(x,y);
		this.id = id;

		spr.set(Assets.tiles, id);
		//tf.text = id;
	}

	override public function activate(by:en.Hero) {
		super.activate(by);
		by.pickItem(id, cx, cy);
		destroy();
	}


	override public function onFocus() {
		super.onFocus();
		var txt = switch( id ) {
			case "grass" : Lang.t._("Long grass.");
			case "rope" : Lang.t._("A long and solid rope.");
			case "wood" : Lang.t._("Multi purpose bamboo!");
			case "food" : Lang.t._("Oily pear");
			case "wseed" : Lang.t._("Bamboo seeds");
			case "plank" : Lang.t._("Old wood planks");
			case "battery" : Lang.t._("Insanely large battery");
			default : Lang.t._("[Unknown item]");
		}
		showDesc(txt, 0xFFBB3C);
	}

	override public function update() {
		super.update();

		if( onGround ) {
			for(e in en.Interactive.ALL) {
				if( e!=this && e.cx==cx && e.cy==cy && uid>e.uid ) {
					if( lMap.hasAnyColl(cx+1,cy) || !lMap.hasAnyColl(cx+1,cy+1) ) {
						sideBumps++;
						dir*=-1;
					}
					if( sideBumps<2 ) {
						dx = dir*0.25;
						dy = -rnd(0.3,0.4);
					}
				}
			}
		}
	}
}
