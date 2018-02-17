class CdbHelper {
	public static inline function getTile(source:h2d.Tile, tileSize:Int, idx:Int) : h2d.Tile {
		var line = Std.int(source.width/tileSize);
		var y = Std.int(idx/line);
		return source.sub((idx-y*line)*tileSize, y*tileSize, tileSize, tileSize);
	}


	public static inline function getObjectTile(source:h2d.Tile, tileSize:Int, props:cdb.Data.TilesetProps, idx:Int) {
		var flip = false;
		if( idx&0x8000!=0 ) {
			idx-=0x8000;
			flip = true;
		}

		var line = Std.int(source.width/tileSize);
		var y = Std.int(idx/line);
		var x = (idx-y*line);

		var t = source.sub(x*tileSize, y*tileSize, tileSize,tileSize);

		// Apply object size
		for(s in props.sets)
			if( s.x==x && s.y==y ) {
				t.setSize(s.w*tileSize, s.h*tileSize);
				break;
			}

		if( flip ) {
			t.flipX();
			t.dx += t.width;
		}

		return t;
	}


	public static inline function idxToPt(id:Int, wid:Int) return {
		x : idxToX(id,wid),
		y : idxToY(id,wid),
	}
	public static inline function idxToX(id:Int, wid:Int) return id - idxToY(id,wid)*wid;
	public static inline function idxToY(id:Int, wid:Int) return Std.int(id/wid);

}