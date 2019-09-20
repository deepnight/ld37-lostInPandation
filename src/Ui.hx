
class Ui extends dn.Process {
	public var heat : Bar;
	//public var life : Bar;
	var flow : h2d.Flow;
	var temp : h2d.Text;

	public function new() {
		super(Game.ME);
		createRoot(Game.ME.root);
		flow = new h2d.Flow(root);
		flow.isVertical = true;
		flow.verticalSpacing = 2;

		var row = new h2d.Flow(flow);
		row.verticalAlign = Middle;
		var label = Assets.tiles.h_get("heatLabel", row);
		heat = new Bar(row);
		@:privateAccess heat.warn.x += 20;
		temp = new h2d.Text(Assets.smallest, row);
		temp.text = "-20°C";
		temp.letterSpacing = -0;
		temp.textColor = 0xFFFFFF;
		row.getProperties(temp).paddingLeft = 3;
		row.getProperties(temp).paddingTop = -1;


		//var row = new h2d.Flow(flow);
		//row.verticalAlign = Middle;
		//var label = Assets.tiles.h_get("lifeLabel", row);
		//life = new Bar(row);

		onResize();
	}

	public function show() {
		if( root.visible )
			return;
		root.visible = true;
		tw.createMs(root.y, -40>40, 1000);
	}

	public function hide() {
		root.visible = false;
	}

	override public function onResize() {
		super.onResize();
		var b = root.getBounds(root);
		root.x = Std.int( w()*0.5/Const.SCALE - b.width*0.5 );
		root.y = 40;
	}

	override public function update() {
		super.update();
		var t = -5 + Game.ME.hero.bodyTemp * 5;
		temp.text = t+"°C";
		root.alpha = Game.ME.messageCount>0 ? 0.3 : 1;
	}
}