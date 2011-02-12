package  
{
	import adobe.utils.CustomActions;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Quin
	 */
	public class gotTet
	{
		public var squares:Array;
		public var color:uint;
				
		public function gotTet(arr:Array, c:uint)
		{
			squares = arr;
			color = c;
		}
		
		private static var MatrixCCW:Matrix = new Matrix(0, -1, 1, 0);
		private static var MatrixCW:Matrix = new Matrix(0, 1, -1, 0);
		private static var Matrix180:Matrix = new Matrix( -1, 0, 0, -1);
		
		public function RotateCW():gotTet
		{

			return new gotTet(squares.map(function(e:Array, idx:uint, arr:Array):Array
				{
					var res:Point = MatrixCW.transformPoint(new Point(e[0]-2, e[1]-2));
					return [res.x+2, res.y+2];
				}), color);
		}
		
		public function RotateCCW():gotTet
		{
			return new gotTet(squares.map(function(e:Array, idx:uint, arr:Array):Array
				{
					var res:Point = MatrixCCW.transformPoint(new Point(e[0] - 2, e[1] - 2));
					return [res.x+2, res.y+2];
				}), color);
		}
		
		public function Rotate180():gotTet
		{
			return new gotTet(squares.map(function(e:Array, idx:uint, arr:Array):Array
				{
					var res:Point = Matrix180.transformPoint(new Point(e[0]-2, e[1]-2));
					return [res.x+2, res.y+2];
				}), color);
		}
	}

}