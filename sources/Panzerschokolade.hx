@:keep
@:expose
class Panzerschokolade {
	public static var COLORS = [
		'#388250', '#362214', '#C8452E', '#B0072A', '#C40131', '#CFB009', '#D7C902', '#FB0F94', '#0A9FDF', '#89B194'
	];

	public static var TITLE = 'Ӎ¥§ŁƎȐӋ ѺӺ ӍɅͶԞіŋÐ';

	public static var QUOTES = [
		"language of love", "mystery of mankind", "werden sie reicher als reich", "gewinnen sie eine traumreise mit dem romantik panzer",
		"a loving friendship of heavenly angels from galactic confederation of planets with earthmen in a spaceship", "gott will es",
		"zart schmelzende schokokugeln aus feinem kokos", "mehr grünflächen für alle", "ich war – ich bin – ich werde sein",
		"es gibt kein richtiges leben im falschen", "sign out - turn off - restart", "was nichts kostet ist nichts wert",
		"wer nicht arbeitet soll nicht essen", "interkultureller austausch zwischen mensch und maschine", "das tut mir mehr weh wie dir",
		"the only winning move is not to play", "it's not enough to win, everyone else must also lose", "der feind sieht dein licht", "zeit ist geld",
		"ewige blumenkraft", "we weep for a bird's cry, but are blind for a fish's tears", "blessed are those who have a voice",
		"laugh, and the world will laugh with you. cry, and you will cry alone", "die freiheit ist nur einen handgriff entfernt",
		"was zusammen gehört – es wächst zusammen", "in der liebe und der kunst ist alles erlaubt", "music is the weapon of the future", "fick dich",
		"mutig voran, den Blick auf die Sonne, der Urquell des lebens", "by entering the portal … you agree to get sprayed with pheromonies",
		"niemand ist ein panzer"
	];

	public static function getRandomQuote() {
		return QUOTES[Std.int((QUOTES.length - 1) * Math.random())];
	}
}
