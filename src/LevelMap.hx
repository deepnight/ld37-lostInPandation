
class LevelMap extends dn.Process {
	public var lData : Data.Level;
	public var id(get,never): Data.LevelKind; inline function get_id() return lData.id;
	var tgs : Array<h2d.TileGroup>;
	var bg : h2d.Bitmap;
	var bgFog : h2d.Bitmap;
	var colls : Map<Int,Int>;
	public var wid(get,never) : Int; inline function get_wid() return lData.width;
	public var hei(get,never) : Int; inline function get_hei() return lData.height;
	//var markers(get,never) : Array<{ cx:Int, cy:Int, wid:Int, hei:Int }>;

	public function new(d:Data.Level) {
		super(Game.ME);
		this.lData = d;
		colls = new Map();
		tgs = [];

		bg = new h2d.Bitmap( hxd.Res.bg.toTile() );
		Game.ME.scroller.add(bg, Const.DP_BG);

		bgFog = new h2d.Bitmap( hxd.Res.bgFog.toTile() );
		Game.ME.scroller.add(bgFog, Const.DP_BG);
		bgFog.alpha = 0;

		renderLayer(lData.layers[0].data);
		iterateLayer(lData.layers[1].data, function(cx,cy,v) {
			colls.set(coordToInt(cx,cy), v);
		});
	}

	//public function attach() {
		//for(tg in tgs)
			//Game.ME.scroller.add(tg,0);
	//}
//
	//public function detach() {
		//for(tg in tgs)
			//tg.remove();
	//}

	public function getMarkers(cx,cy) : Data.Level_markers {
		for(m in lData.markers)
			if( cx>=m.x && cx<m.x+m.width && cy>=m.y && cy<m.y+m.height )
				return m;
		return null;
	}

	inline function coordToInt(cx,cy) return cx+cy*wid;

	function iterateLayer(layer:cdb.Types.TileLayer, cb:Int->Int->Int->Void) {
		var i = 0;
		for(v in layer.data.decode()) {
			if( v>0 ) {
				var pt = CdbHelper.idxToPt(i, lData.width);
				cb(pt.x, pt.y, v-1);
				//tg.add(pt.x*Const.GRID, pt.y*Const.GRID, CdbHelper.getTile(tg.tile, layer.size, v-1));
			}
			i++;
		}
	}

	function renderLayer(layer:cdb.Types.TileLayer) {
		var tg = new h2d.TileGroup( hxd.Res.load(layer.file).toTile() );
		tgs.push(tg);
		Game.ME.scroller.add(tg,Const.DP_MAIN_BG);

		var i = 0;
		for(v in layer.data.decode()) {
			if( v>0 ) {
				var pt = CdbHelper.idxToPt(i, lData.width);
				tg.add(pt.x*Const.GRID, pt.y*Const.GRID, CdbHelper.getTile(tg.tile, layer.size, v-1));
			}
			i++;
		}
	}

	public inline function isValid(cx,cy) {
		return cx>=0 && cx<wid	&& cy>=0 && cy<hei;
	}

	public inline function hasAnyColl(cx,cy) {
		return colls.exists(coordToInt(cx,cy));
	}
	public inline function hasHardColl(cx,cy) {
		return colls.get(coordToInt(cx,cy)) == 0;
	}
	public inline function canJumpThrough(cx,cy) {
		return isValid(cx,cy) && colls.get(coordToInt(cx,cy)) == 1;
	}

	override public function update() {
		super.update();
		var vp = Game.ME.viewport;
		bg.x = -Game.ME.scroller.x*0.3;
		bgFog.x = bg.x;
		if( Game.ME.storm )
			bgFog.alpha += (0.8 - bgFog.alpha ) * 0.08;
		else
			bgFog.alpha += ( 0 - bgFog.alpha ) * 0.01;
	}
}