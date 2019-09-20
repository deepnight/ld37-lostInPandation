package en;


class Interactive extends Entity {
	public static var ALL : Array<Interactive> = [];
	var tf : h2d.Text;
	public var activationDelay : Float;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		activationDelay = 0.3;

		tf = new h2d.Text(Assets.font);
		Game.ME.scroller.add(tf, Const.DP_UI);
	}


	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		tf.remove();
		tf = null;
	}

	public function beginActivation(by:en.Hero) { return true; }
	public function activate(by:en.Hero) {}


	override public function postUpdate() {
		super.postUpdate();
		tf.visible = tf.text!=null;
		tf.x = Std.int( sprX - tf.textWidth*0.5 );
		tf.y = Std.int( sprY - 2 );
	}

	override public function update() {
		super.update();
		if( cy>=lMap.hei+2 )
			destroy();
	}
}
