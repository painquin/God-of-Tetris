package  
{
	/**
	 * ...
	 * @author Quin
	 */
	public class Board
	{
		public var Grid:Array;
		public var Width:uint;
		public var Height:uint;
		
		public function Board(w:uint, h:uint, src:Array = null ) 
		{
			Width = w;
			Height = h;
			Grid = [];
			for (var y:uint = 0; y < h; ++ y)
			{
				for (var x:uint = 0; x < w; ++x)
				{
					if (src == null)
					{
						Grid[x + y * w] = 0;
					}
					else
					{
						Grid[x + y * w] = src[x + y * w];
					}
				}
			}
		}
		
		public function Copy():Board
		{
			return new Board(Width, Height, Grid);
		}
		
		
		
		// todo: moving sideways into existing blocks shouldn't end your move
		
		// returns 0 if there is no reason that you can't put a block at this spot
		// returns 1 if there is another block in the way or you hit the bottom - this ends your move, probably incorrectly.
		// returns 2 if there is a wall in the way - this keeps you from using the spot, but that's all
		public function CanHas(x:uint, y:uint):uint
		{
			if (x < 0 || x >= Width) return 2;
			if (y < 0) return 2;
			
			if (y > Height) return 1;
			
			if (Grid[x + y * Width] != 0) return 1;
			
			return 0;
		}
		
		public function CheckCollision(piece:gotTet, x:uint, y:uint):uint
		{
			
			var collide:uint = 0;
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				var res:uint = CanHas(x + e[0], y + e[1]);
				if (res != 0)
				{
					collide = res;
				}
			});
			
			return collide;
		}
		
		public function AddPiece(piece:gotTet, x:int, y:int):Boolean
		{
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				Grid[x + e[0] + (y + e[1]) * Width] = piece.color;
			});
			var any:Boolean = false;
			
			for (var clearY:int = 0; clearY < Height; ++clearY)
			{
				var missing:Boolean = false;
				for (var clearX:uint = 0; clearX < Width; ++clearX)
				{
					if (Grid[clearX + clearY * Width] == 0) {
						missing = true;
						break;
					}
				}
				
				if (!missing)
				{

					any = true;
					
					for (clearX = 0; clearX < Width; ++clearX)
					{
						Grid[clearX + clearY * Width] = 0
					}
				}
				
			}
			
			return any;
			
		}
		
		public function Gravity():void
		{
			var destY:int = Height - 1;
			var x:uint;
			for (var srcY:int = Height - 1; srcY >= 0; --srcY)
			{
				var any:Boolean = false;
				for (var clearX:uint = 0; clearX < Width; ++clearX)
				{
					if (Grid[clearX + srcY * Width] != 0) {
						any = true;
						break;
					}
				}
				
				if (!any)
				{
					continue;
				}
				
				if (srcY != destY) 
				{
					for (x = 0; x < Width; ++x)
					{
						Grid[x + destY * Width] = Grid[x + srcY * Width];
					}
				}
				
				
				--destY;
			}
			
			while (destY >= 0)
			{
				for (x = 0; x < Width; ++x)
				{
					Grid[x + destY * Width] = 0;
				}
				--destY;
			}
		}
	}

}