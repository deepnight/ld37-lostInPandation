class Lang {
	public static var t : mt.data.GetText;

	public static function init(lang:String) {
		t = new mt.data.GetText();
		//mt.data.GetText.parse("src", "res/texts.pot");

		t.readMo( hxd.Res.load(lang+".mo").entry.getBytes() );
	}
}