class Lang {
	public static var t : dn.data.GetText;

	public static function init(lang:String) {
		t = new dn.data.GetText();
		//parse("src", "res/texts.pot");

		t.readMo( hxd.Res.load(lang+".mo").entry.getBytes() );
	}
}