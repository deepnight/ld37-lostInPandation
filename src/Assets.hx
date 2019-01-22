//import mt.flash.Sfx;
import mt.deepnight.Sfx;

class Assets {
	public static var SBANK = Sfx.importDirectory("sfx");
	public static var font : h2d.Font;
	public static var smallest : h2d.Font;
	public static var bg : h2d.Tile;
	public static var tiles : mt.heaps.slib.SpriteLib;

	public static function init() {
		smallest = hxd.Res.smallest.toFont();
		font = hxd.Res.minecraftiaOutline.toFont();
		bg = hxd.Res.bg.toTile();

		tiles = mt.heaps.slib.assets.Atlas.load("tiles.atlas");
		tiles.generateAnim("heroIdle", "0(60), 1(3), 2(40), 1(3)");
		tiles.generateAnim("heroScratch", "0(3), 1(3), 2(20), 3(9), 2(9), 3(9), 2(9), 3(15), 1(6), 0(6)");
		tiles.generateAnim("heroCheck", "0(3), 1(3), 2(40), 3(5), 4(10), 5(10), 4(20), 5(10), 4(5), 3(5), 1(5), 0(5)");
		tiles.generateAnim("heroWalk", "0(1), 1(2), 2(1), 3(1), 4(1)");
		tiles.generateAnim("heroDeath", "0(2), 1(2), 2(1), 3(2), 4(1), 5(2), 6(1), 7(1), 8(2)");

		Sfx.setGroupVolume(0, 1.0);
		Sfx.setGroupVolume(1, 0.5);
		// Sfx.setChannelVolume(0,1);
		// Sfx.setChannelVolume(1,0.5);
		//Sfx.muteChannel(0); // NO SOUND
	}
}
