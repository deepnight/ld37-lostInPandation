
class Game extends dn.Process {
	public static var ME : Game;
	var controller : ControllerAccess;
	public var hero : en.Hero;
	public var lMap : LevelMap;
	public var scroller : h2d.Layers;
	public var viewport : Viewport;
	public var fx : Fx;
	public var ui : Ui;
	public var ice : h2d.Bitmap;
	public var storm : Bool;

	public var camp : en.i.Camp;
	public var gen : en.i.Generator;
	public var insideTemp(get,never) : Int;
	public var outsideTemp(get,never) : Int;

	public var debug : h2d.Text;
	var mobSpawns : Array<{cx:Int, cy:Int}> = [];
	public var cm : dn.Cinematic;

	public var realGameStarted(get,never) : Bool;

	public function new(withIntro:Bool) {
		super(Main.ME);
		ME = this;
		storm = false;

		controller = Main.ME.controller.createAccess("game");

		cm = new dn.Cinematic(Const.FPS);
		createRoot(Main.ME.root);
		scroller = new h2d.Layers(root);

		lMap = new LevelMap( Data.level.get(TheRoom) );
		for( m in lMap.lData.markers ) {
			switch( m.markId ) {
				case Item : new en.i.Item(m.x, m.y, m.param);
				case Ladder : new en.i.Ladder(m.x, m.y, m.param=="1");
				case Start : hero = new en.Hero(m.x,m.y, Std.parseInt(m.param));
				case FireCamp : camp = new en.i.Camp(m.x, m.y);
				case Generator : gen = new en.i.Generator(m.x, m.y);
				case Computer : new en.i.Computer(m.x, m.y);
				case Sleep : new en.i.Message(m.x, m.y, Lang.t.untranslated("Your sleeping bag"));
				case Thermometer : new en.i.Thermometer(m.x, m.y);
				case FoodTable: new en.i.FoodTable(m.x, m.y);
				case RopeCrafter : new en.i.RopeCrafter(m.x, m.y);
				case BatterySlot : new en.i.BatterySlot(m.x, m.y);
				case BatteryMaker : new en.i.BatteryMaker(m.x, m.y);
				case LockedPot : new en.i.LockedPot(m.x, m.y);
				case Light : new en.Light(m.x, m.y);
				case Radio : new en.i.Radio(m.x, m.y);
				case EMP : new en.i.MobKiller(m.x, m.y);
				case Help :
					new en.i.Message(m.x, m.y, Lang.t.untranslated("Use ARROWS to move, SPACE to pickup items or interact, DOWN to drop an item. TIPS: take care of your fire, plant as many things as possible, find a way to power up the cable car."));
				case MobSpawn :
					for(x in m.x...m.x+m.width)
						mobSpawns.push( { cx:x, cy:m.y } );
				case Pot:
					var e = new en.i.Pot(m.x, m.y);
					if( m.param!=null )
						e.plant(m.param);
			}
		}
		ui = new Ui();
		viewport = new Viewport();
		viewport.track(hero);
		fx = new Fx();
		new Tutorial();

		ice = new h2d.Bitmap( hxd.Res.ice.toTile() );
		root.addChild(ice);
		ice.alpha = 0;

		debug = new h2d.Text(Assets.font, root);
		#if !debug
		debug.visible = false;
		#end

		#if debug
		withIntro = false;
		#end
		if( withIntro ) {
			dn.Process.resizeAll();
			var w = this.w()/Const.SCALE;
			var h = this.h()/Const.SCALE;
			var mask = new h2d.Bitmap( h2d.Tile.fromColor(0x151220), root );
			mask.scaleX = w;
			mask.scaleY = h;
			mask.alpha = 1;

			var logo = Assets.tiles.h_get("logo",0, 0.5,0.5,root);
			logo.setPosition(w*0.5, h*0.5);
			logo.alpha = 0;

			var sub = Assets.tiles.h_get("logoSub",0, 0.5,0.5,root);
			sub.setPosition(w*0.5, h*0.8);
			sub.alpha = 0;

			hero.lockControlS(999);
			ui.hide();
			viewport.slow = true;
			viewport.x = lMap.wid*0.5 * Const.GRID;
			viewport.y = lMap.hei*Const.GRID;

			cm.create( {
				tw.createMs(mask.alpha, 1>0.8, 1500);
				500;
				tw.createMs(logo.alpha, 0>1, 1000);
				1000;
				tw.createMs(sub.alpha, 0>1, 500);
				1500;
				tw.createMs(logo.alpha, 0, 1000);
				500;
				tw.createMs(sub.alpha, 0, 1000);
				500;
				tw.createMs(mask.alpha, 0, 1000);
				1000;
				mask.remove();
				sub.remove();
				logo.remove();
				hero.unlockControls();
				//ui.show();
				viewport.slow = false;
				explanations();
			});
		}
		else {
			fx.flashBang(0xFFFFFF,1,2);
			explanations();
		}

	}

	function explanations() {
		message(Lang.t._("You are a iPanda, a next-gen personal assistant, trapped in an apartment after some sort of apocalypse... Survive to the frost and find a way to escape!"));
	}

	public function end() {
		clearMessages();
		var w = this.w()/Const.SCALE;
		var h = this.h()/Const.SCALE;

		var mask2 = new h2d.Bitmap( h2d.Tile.fromColor(0x0A0E1F), root );
		mask2.scaleX = w;
		mask2.scaleY = h;
		mask2.visible = false;

		var logo = Assets.tiles.h_get("logo",0, 0.5,0.5,root);
		logo.setPosition(w*0.5, h*0.25);
		logo.alpha = 0;

		var mask = new h2d.Bitmap( h2d.Tile.fromColor(0xFFFFFF), root );
		mask.scaleX = w;
		mask.scaleY = h;
		mask.alpha = 0;

		hero.lockControlS(99999);
		@:privateAccess hero.hasGravity = false;
		cm.create( {
			tw.createMs(mask.alpha, 0>1, 1000);
			1000;
			mask2.visible = true;
			tw.createMs(mask.alpha, 0, 1500);
			1500;
			tw.createMs(logo.alpha, 0>1, 2000);
			2500;
			endMsg(Lang.t._("Wow! You managed to survive to this hell!"));
			1500;
			emptyLine();
			endMsg(Lang.t._("Thank you for playing!"));
			500;
			endMsg(Lang.t._("...And sorry for the shitty ending, not enough time ^_^"));
			2500;
			emptyLine();
			endMsg(Lang.t._("A 72h game by Sébastien Bénard"));
			500;
			endMsg(Lang.t._("[ deepnight.net ]"), 0x5B70CC);
			1500;
			emptyLine();
			endMsg(Lang.t._("Music by Volkor X"));
			500;
			endMsg(Lang.t._("[ volkorx.bandcamp.com ]"), 0x5B70CC);
			99999;
		});
	}

	var msgCpt = 0;
	function emptyLine() {
		msgCpt++;
	}
	function endMsg(txt:String, ?c=0x9CA8E0) {
		var tf = new h2d.Text(Assets.font, root);
		tf.text = txt;

		tf.setPosition(this.w()/Const.SCALE*0.5 - tf.textWidth*0.5, this.h()/Const.SCALE*0.4 + msgCpt*12);
		tw.createMs(tf.alpha, 0>1, 1000);
		tf.textColor = c;
		msgCpt++;

	}

	inline function get_realGameStarted() return cd.has("realGameDone");

	public function beginRealGame() {
		if( cd.has("realGameDone") )
			return;

		cd.setS("realGameDone",99999);
		initStormLoop(true);
		initMobLoop();
	}

	public function initStormLoop(quick:Bool) {
		delayer.cancelById("start");
		delayer.cancelById("stop");
		var t = quick ? rnd(5,10) : rnd(35,50);
		delayer.addS( "start", startStorm, t );
		delayer.addS( "stop", stopStorm, t+rnd(22,35) );
	}

	public function startStorm() {
		storm = true;
		var ladders = en.Interactive.ALL.filter( function(e) return e.is(en.i.Ladder) && Std.instance(e,en.i.Ladder).active );
		dn.Lib.shuffleArray(ladders, Std.random);

		var n = 1;
		for(e in ladders) {
			var e = Std.instance(e,en.i.Ladder);
			e.setFragile();
			n--;
			if( n<=0 )
				break;
		}
	}

	public function stopStorm() {
		storm = false;
		initStormLoop(false);
	}


	public function initMobLoop() {
		delayer.cancelById("mob");
		var t = rnd(85,95);
		delayer.addS( "mob", addMob, t );
	}

	var doubleMob = false;
	public function addMob() {
		for(i in 0...(doubleMob ? 2 : 1)) {
			var dh = new DecisionHelper(mobSpawns);
			dh.score( function(pt) {
				for(e in en.Mob.ALL)
					if( M.dist(pt.cx, pt.cy, e.cx, e.cy)<=10 )
						return 0;
				return 1;
			} );
			dh.score( function(pt) return M.dist(pt.cx, pt.cy, hero.cx, hero.cy)<=6 ? 0 : 1 );
			var pt = dh.getBest();
			new en.Mob(pt.cx, pt.cy);
		}
		//doubleMob = !doubleMob;
		initMobLoop();
	}


	public function isLastItem(id:String) {
		for(e in Entity.ALL) {
			if( e.is(en.i.Item) && Std.instance(e,en.i.Item).id==id )
				return false;
			if( e.is(en.i.Pot) && Std.instance(e,en.i.Pot).output==id )
				return false;
		}

		return true;
	}

	var messages : Array<dn.Process> = [];
	public var messageCount = 0;

	public function clearMessages() {
		for(p in messages)
			p.destroy();
	}

	public function message(m:LocaleString, ?c=0x132648, ?perma=false) {
		clearMessages();

		var cx = hero.cx;
		var cy = hero.cy;
		var wr = new h2d.Object();
		var bg = new h2d.Graphics(wr);

		var p = 5;
		var tf = new h2d.Text(Assets.font, wr);
		tf.text = m;
		tf.setPosition(p,p);
		tf.textColor = 0xffffff;
		tf.maxWidth = Const.GRID*18;

		var w = tf.textWidth+p*2;
		var h = tf.textHeight+p*2;
		bg.beginFill(dn.Color.brightnessInt(c,-0.5));
		bg.drawRect(-1,-1,w+2,1);
		bg.drawRect(-1,h,w+2,1);
		bg.drawRect(-1,-1,1,h+2);
		bg.drawRect(w,-1,1,h+2);
		bg.beginFill(c,0.92);
		bg.drawRect(0,0,w,h);

		bg.beginFill(dn.Color.brightnessInt(c,0.1));
		bg.drawRect(0,0,w,1);

		if( cy<=21 || cy>=34 ) {
			// Above
			wr.setPosition((cx+0.5)*Const.GRID - w*0.5, cy*Const.GRID - h - Const.GRID*4);
		}
		else {
			// Below
			wr.setPosition((cx+0.5)*Const.GRID - w*0.5, (cy+1.5)*Const.GRID);
		}
		wr.x = Std.int(wr.x);
		wr.y = Std.int(wr.y);
		tw.createS(wr.alpha, 0>1, 0.15);

		scroller.add(wr, Const.DP_UI);

		messageCount++;
		messages.push( createChildProcess( function(p) {
			if( !perma && dn.M.dist(hero.cx, hero.cy, cx,cy)>=3 )
				p.destroy();
		}, function(p) {
			messages.remove(p);
			messageCount--;
			tw.createS(wr.alpha, 0, 0.2).end( wr.remove );
		}) );
	}

	public function notify(m:LocaleString, ?c=0x234685) {
		var wr = new h2d.Object();
		var bg = new h2d.Graphics(wr);

		var p = 5;
		var tf = new h2d.Text(Assets.font, wr);
		tf.text = m;
		tf.setPosition(p,p);
		tf.textColor = 0xffffff;
		tf.maxWidth = Const.GRID*18;

		var w = tf.textWidth+p*2;
		var h = tf.textHeight+p*2;
		bg.beginFill(dn.Color.brightnessInt(c,-0.5));
		bg.drawRect(-1,-1,w+2,1);
		bg.drawRect(-1,h,w+2,1);
		bg.drawRect(-1,-1,1,h+2);
		bg.drawRect(w,-1,1,h+2);
		bg.beginFill(c,0.92);
		bg.drawRect(0,0,w,h);

		bg.beginFill(dn.Color.brightnessInt(c,0.1));
		bg.drawRect(0,0,w,1);

		wr.x = Std.int(this.w()/Const.SCALE*0.5 - w*0.5 );

		tw.createS(wr.y, -50>10, 0.35);
		tw.createS(wr.alpha, 0>1, 0.15);
		root.add(wr, Const.DP_UI);
		delayer.addS( function() {
			tw.createS(wr.y, -50, 0.5).end( function() wr.remove() );
		}, 3);
	}


	override public function onResize() {
		super.onResize();
		ice.scaleX = w()/Const.SCALE / ice.tile.width;
		ice.scaleY = h()/Const.SCALE / ice.tile.height;
	}

	function get_outsideTemp() {
		return storm ? -3 : -1;
	}

	function get_insideTemp() {
		return Game.ME.camp.power + outsideTemp;
	}

	public function restart() {
		destroy();
		Main.ME.delayer.addS( function() {
			new Game(false);
		}, 0.1);
	}

	override public function onDispose() {
		super.onDispose();

		for(e in Entity.ALL)
			e.destroy();
		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	public inline function print(v:Dynamic) {
		#if debug
		debug.text = Std.string(v);
		#end
	}

	override public function postUpdate() {
		super.postUpdate();
		if( hero.bodyTemp>0 )
			ice.alpha += (0-ice.alpha)*0.06;
		else {
			var ta = 0.3 + 0.6 * M.fclamp((1+M.fabs(hero.bodyTemp))/4, 0, 1);
			ice.alpha += (ta-ice.alpha)*0.09;
		}
	}

	public function getMouse() {
		var gx = hxd.Window.getInstance().mouseX;
		var gy = hxd.Window.getInstance().mouseY;
		var sx = Std.int( (gx/Const.SCALE-scroller.x) );
		var sy = Std.int( (gy/Const.SCALE-scroller.y) );
		return {
			gx : gx,
			gy : gy,

			sx : sx,
			sy : sy,

			cx : Std.int( sx/Const.GRID ),
			cy : Std.int( sy/Const.GRID ),
		}
	}

	override public function update() {
		super.update();
		cm.update(dt);
		#if debug
		var m = getMouse();
		print(
			"fps="+pretty(hxd.Timer.fps(),0) +
			" fx="+@:privateAccess fx.pool.getAllocateds()+
			" m="+m.sx+","+m.sy+" / "+m.cx+","+m.cy+
			" inside="+insideTemp+"° outside="+outsideTemp+"° body="+hero.bodyTemp+"°"+
			" msg="+messageCount
		);
		#end

		for(e in Entity.ALL) {
			e.preUpdate(dt);
			e.update();
		}

		for(e in Entity.ALL)
			e.postUpdate();

		if( Entity.GC.length>0 ) {
			for(e in Entity.GC)
				e.dispose();
			Entity.GC = [];
		}

		if( hero.cx<=46 )
			ui.show();

		#if hl
		if( controller.isKeyboardPressed(Key.ESCAPE) ) {
			if( !cd.hasSetS("quitConfirm", 3) )
				notify(Lang.t._("Press ESCAPE again to exit."));
			else
				hxd.System.exit();
		}
		#end

		//Assets.tiles.updateChildren(dt*2);
		if( storm )
			fx.storm();
		else
			fx.snow();
	}
}