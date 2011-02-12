package  
{
	import adobe.utils.CustomActions;
	/**
	 * ...
	 * @author Quin
	 */
	public class gotTetPrototype
	{
		
		public var squares:Array;
		public var color:uint;
		
		public function gotTetPrototype(s:Array, c:uint = 0xFFFFFFFF)
		{
			squares = s;
			color = c;
		}
		
		public function Create():gotTet
		{
			return new gotTet(squares, color);
		}
	}

}