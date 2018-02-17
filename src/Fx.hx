import mt.heaps.HParticle;
import mt.deepnight.Color;
import mt.MLib;
import mt.deepnight.Lib;

class Fx extends mt.Process {
	var pool : mt.heaps.HParticle.ParticlePool;
	var bgSb : h2d.SpriteBatch;
	var normalSb : h2d.SpriteBatch;
	var mainSb : h2d.SpriteBatch;
	var mainBgSb : h2d.SpriteBatch;
	var snowWind : Float;

	public function new() {
		super(Game.ME);

		bgSb = new h2d.SpriteBatch(Assets.tiles.tile);
		Game.ME.scroller.add(bgSb, Const.DP_BG);
		bgSb.hasRotationScale = true;
		bgSb.blendMode = Add;

		mainBgSb = new h2d.SpriteBatch(Assets.tiles.tile);
		Game.ME.scroller.add(mainBgSb, Const.DP_MAIN_BG);
		mainBgSb.hasRotationScale = true;
		mainBgSb.blendMode = Add;

		mainSb = new h2d.SpriteBatch(Assets.tiles.tile);
		Game.ME.scroller.add(mainSb, Const.DP_MAIN_FX);
		mainSb.hasRotationScale = true;
		mainSb.blendMode = Add;

		normalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		Game.ME.scroller.add(normalSb, Const.DP_MAIN_FX);
		normalSb.hasRotationScale = true;

		pool = new mt.heaps.HParticle.ParticlePool(Assets.tiles.tile, 800, Const.FPS);
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		pool = null;

		bgSb.remove();
		mainSb.remove();
		mainBgSb.remove();
		normalSb.remove();
	}

	inline function allocBg(k:String, x:Float, y:Float) {
		return pool.alloc(bgSb, Assets.tiles.getTileRandom(k), x, y);
	}
	inline function allocMain(k:String, x:Float, y:Float) {
		return pool.alloc(mainSb, Assets.tiles.getTileRandom(k), x, y);
	}
	inline function allocMainBg(k:String, x:Float, y:Float) {
		return pool.alloc(mainBgSb, Assets.tiles.getTileRandom(k), x, y);
	}
	inline function allocNormal(k:String, x:Float, y:Float) {
		return pool.alloc(normalSb, Assets.tiles.getTileRandom(k), x, y);
	}

	function _autoRotate(p:HParticle) {
		p.rotation = p.getMoveAng();
	}
	public function snow() {
		var vp = Game.ME.viewport;
		for( i in 0...4 )  {
			var p = allocBg("fxSnow", vp.x+rnd(0,vp.wid*0.5+30,true), vp.top+rnd(-30,vp.hei*0.8));
			p.setFadeS(rnd(0.2,1), 1, 2);
			//p.setScale(irnd(1,2));
			p.dx = rnd(0,1) * snowWind;
			p.gx = rnd(0,0.04) * snowWind;
			p.gy = rnd(0.03,0.10);
			//p.rotation = rnd(0,6.28);
			//p.dr = rnd(0,0.02,true);
			p.scaleMul = rnd(0.999,1);
			p.frict = rnd(0.8,0.9);
			p.lifeS = rnd(3,5);
		}
		for( i in 0...3 )  {
			var p = allocBg("fxSnowFast", vp.x+rnd(0,vp.wid*0.5,true), vp.top+rnd(-30,vp.hei*0.8));
			p.setFadeS(rnd(0.2,0.5), 1, 2);
			p.scaleX = rnd(1.5,3);
			p.dx = rnd(-1,2) * snowWind;
			p.dy = rnd(1,3);
			p.gx = rnd(0.03,0.10)*snowWind;
			p.gy = rnd(0.20,0.30);
			p.rotation = p.getMoveAng();
			p.scaleXMul = rnd(0.98,0.99);
			p.frict = rnd(0.90,0.95);
			p.lifeS = rnd(1,2);
			p.onUpdate = _autoRotate;
		}
	}


	public function storm() {
		var vp = Game.ME.viewport;
		for( i in 0...6 )  {
			var p = allocBg("fxSnow", vp.x+rnd(0,vp.wid*0.5,true), vp.top+rnd(-30,vp.hei*0.8));
			p.setFadeS(rnd(0.2,0.6), 1, 2);
			p.setScale(irnd(1,2));
			p.dx = rnd(0,1) * snowWind;
			p.gx = rnd(0,0.10) * snowWind;
			p.gy = rnd(0.25,0.45);
			//p.rotation = rnd(0,6.28);
			//p.dr = rnd(0,0.02,true);
			p.scaleMul = rnd(0.999,1);
			p.frict = rnd(0.85,0.95);
			p.lifeS = rnd(3,5);
		}
		for( i in 0...1 )  {
			var p = allocBg("fxSnowFast", vp.x+rnd(0,vp.wid*0.5,true), vp.top+rnd(-30,vp.hei*0.8));
			p.setFadeS(rnd(0.2,0.6), 1, 2);
			p.scaleX = rnd(1.5,3);
			p.dx = rnd(-1,2) * snowWind;
			p.dy = rnd(1,3);
			p.gx = rnd(0.03,0.15)*snowWind;
			p.gy = rnd(0.40,0.50);
			p.rotation = p.getMoveAng();
			p.scaleXMul = rnd(0.98,0.99);
			p.frict = rnd(0.90,0.95);
			p.lifeS = rnd(1,2);
			p.onUpdate = _autoRotate;
		}
		// Front smoke
		for( i in 0...irnd(1,2) )  {
			var p = allocMain("fxSmoke", vp.x-vp.wid*0.7+rnd(0,vp.wid*0.7), vp.top+rnd(-100,vp.hei*0.4));
			p.setFadeS(rnd(0.07,0.11), 1, 2);
			p.setScale(irnd(2,3));
			p.dx = rnd(0,1) * snowWind;
			p.gx = rnd(0.05,0.15) * snowWind;
			p.gy = rnd(0.30,0.50);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0.01,0.03,true);
			p.scaleMul = rnd(0.999,1);
			p.frict = rnd(0.90,0.95);
			p.lifeS = rnd(1,1.5);
		}
		// Back smoke
		for( i in 0...irnd(1,2) )  {
			var p = allocBg("fxSmoke", vp.x-vp.wid*0.7+rnd(0,vp.wid*0.7), vp.top+rnd(-100,vp.hei*0.4));
			p.setFadeS(rnd(0.1,0.2), 1, 2);
			p.setScale(irnd(2,4));
			p.dx = rnd(0,1) * snowWind;
			p.gx = rnd(0.05,0.15) * snowWind;
			p.gy = rnd(0.30,0.50);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0.01,0.03,true);
			p.scaleMul = rnd(0.999,1);
			p.frict = rnd(0.90,0.95);
			p.lifeS = rnd(1,1.5);
		}
	}


	public function camp(x:Float,y:Float, power:Int) {
		var strong = power>=2;
		var stormWind = Game.ME.storm ? MLib.sign(snowWind) : 0;
		// Flames
		for(i in 0...(power>=3 ? 5 : power>=2 ? 2 : 1)) {
			var p = allocMainBg("fxFire", x+rnd(0,strong?7:4,true), y-rnd(7,8));
			p.setFadeS(rnd(0.5,1), rnd(0.2,0.4), rnd(1,1.5));
			p.scaleX = rnd(0.6,0.9);
			p.dr = rnd(0,0.01,true);
			p.gx = rnd(0,0.01) + stormWind * rnd(0.00,0.02);
			p.gy = power>=3 ? -rnd(0.04,0.07) : power==2 ? -rnd(0.02,0.05) : -rnd(0.01,0.02);
			p.rotation = 1.57 + rnd(0,0.1,true);
			p.scaleMul = rnd(0.98,0.99);
			p.frict = 0.8;
			switch( power ) {
				case 1 : p.colorize( Color.makeColorHsl(rnd(0, 0.01), 0.9, 1) );
				case 2 : p.colorize( Color.makeColorHsl(rnd(0.03, 0.06), 0.8, 1) );
				case 3 : p.colorize( Color.makeColorHsl(rnd(0.06, 0.10), 0.8, 1) );
			}
			p.lifeS = rnd(0.7,1.5);
		}
		// Front
		for(i in 0...(power>=3?2:1)) {
			var p = allocMainBg("fxFire", x+rnd(0,7,true), y-rnd(5,8));
			p.setFadeS(rnd(0.4,0.5), 0.3, 1);
			p.scaleX = rnd(0.3,0.5);
			p.dr = rnd(0,0.01,true);
			p.dx = rnd(0,0.2,true);
			p.dy = rnd(0,0.2,true);
			p.frict = 0.9;
			p.rotation = rnd(0,0.2,true);
			p.scaleMul = rnd(0.97,0.98);
			p.colorize( Color.makeColorHsl(rnd(0,0.1), 0.8, 1) );
			p.lifeS = rnd(0.7,1.5);
		}
		// Dots
		for(i in 0...1) {
			var p = allocMainBg("fxDot", x+rnd(0,5,true), y-rnd(7,8));
			p.setFadeS(rnd(0.5,1), rnd(0.2,0.4), rnd(1,1.5));
			p.scaleX = strong ? rnd(1,2) : 1;
			//p.dr = rnd(0,0.01,true);
			p.gx = rnd(0,0.01)+ stormWind * rnd(0.01,0.05);
			p.gy = strong ? -rnd(0.03,0.08) : -rnd(0.02,0.05);
			p.rotation = 1.57 + rnd(0,0.1,true);
			p.frict = 0.8;
			p.colorize( Color.makeColorHsl(rnd(0, power>=3 ? 0.07 : power>=2 ? 0.04 : 0.02), 0.8, 1) );
			p.lifeS = rnd(0.7,1.5);
		}
	}

	function _mobDeath(p:HParticle) {
		if( p.data[1]!=null ) return;

		if( p.data[0]==null ) p.data[0] = rnd(10,20);
		else {
			p.data[0]--;
			if( p.data[0]<=0 ) {
				p.data[1] = 1;
				p.gy = rnd(0.1,0.3);
				p.dr = rnd(0.05,0.10);
			}
		}
	}

	public function flashBang(c:UInt, alpha:Float, fadeS:Float, ?fadeInS=0.) {
		var t = h2d.Tile.fromColor(c,1,1,alpha);
		var bmp = new h2d.Bitmap(t);
		Game.ME.root.addChild(bmp);
		bmp.scaleX = Main.ME.buffer.width;
		bmp.scaleY = Main.ME.buffer.height;
		bmp.blendMode = Add;

		Game.ME.tw.createS(bmp.alpha, 0>1, fadeInS).end( function () {
			Game.ME.tw.createS(bmp.alpha, 0, fadeS).end( bmp.remove );
		});
	}

	public function markerCase(cx:Int, cy:Int) {
		var p = allocMain("fxDot", (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0xB14BB4);
		p.setScale(3);
		p.alpha = 0.5;
		p.lifeS = 3;
	}

	public function mobDeath(x:Float,y:Float, c:UInt) {
		for(i in 0...50) {
			var p = allocNormal("fxDirt", x+rnd(0,6,true), y+rnd(0,6,true));
			p.colorize( Color.brightnessInt(c,rnd(0,0.7)) );
			p.alpha = rnd(0.5,1);
			p.setScale(rnd(0.5,1.3));
			p.moveAng(rnd(0,6.28), rnd(2,8));
			p.frict = rnd(0.6,0.9);
			p.dr = rnd(0,0.03,true);
			p.rotation = rnd(0,1.57);
			p.scaleMul = rnd(0.97,1);
			p.lifeS = rnd(1,2);
			p.onUpdate = _mobDeath;
		}
	}

	public function brokenLadder(e:en.i.Ladder) {
		var c = 0x807924;
		for(i in 0...40) {
			var p = allocNormal("fxDirt", e.sprX+rnd(1,3,true), rnd(e.endY*Const.GRID,e.sprY));
			p.colorize(c);
			p.alpha = rnd(0.5,1);
			p.setScale(rnd(0.5,0.7));
			p.moveAng(rnd(0,6.28), rnd(0.5,1));
			p.frict = rnd(0.85,0.9);
			p.rotation = rnd(0,6.28);
			p.scaleMul = rnd(0.98,1);
			p.lifeS = rnd(1,2);
			p.onUpdate = _mobDeath;
		}
	}

	override public function update() {
		super.update();
		pool.update(dt*2);
		//Game.ME.print( pool.getAllocateds() );
		if( Game.ME.storm )
			snowWind = 4 + Math.cos(ftime*0.003) * 1;
		else
			snowWind = Math.cos(ftime*0.003) * 2;
	}
}