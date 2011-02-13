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
		
		public static const HasEmpty:uint = 0;
		public static const HasWall:uint = 1;
		public static const HasBlock:uint = 2;
		public static const HasFloor:uint = 3;
		
		public function BlockAt(x:int, y:int):uint
		{

			if (x < 0 || x >= Width) return HasWall;
			if (y < 0) return HasWall;
			if (y >= Height)
				return HasFloor;
				
			if (Grid[x + y * Width] == 0) return HasEmpty;
			return HasBlock;
		}
		
		// is this valid without moving at all
		public function IsValid(piece:gotTet, x:int, y:int):Boolean
		{
			var collide:Boolean = false;
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				var res:uint = BlockAt(x + e[0], y + e[1]);
				switch(res)
				{
					case HasWall:
					case HasBlock:
					case HasFloor:
						collide = true;
						break;
					case HasEmpty:
						break;
				}
			});
			
			return !collide;
		}
		public function CanMoveLeft(piece:gotTet, x:int, y:int):Boolean
		{
			var collide:Boolean = false;
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				var res:uint = BlockAt(x + e[0] - 1, y + e[1]);
				switch(res)
				{
					case HasWall:
					case HasBlock:
					case HasFloor:
						collide = true;
						break;
					case HasEmpty:
						break;
				}
			});
			
			return !collide;
		}
		
		public function CanMoveRight(piece:gotTet, x:int, y:int):Boolean
		{
			var collide:Boolean = false;
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				var res:uint = BlockAt(x + e[0] + 1, y + e[1]);
				switch(res)
				{
					case HasWall:
					case HasBlock:
					case HasFloor:
						collide = true;
						break;
					case HasEmpty:
						break;
				}
			});
			
			return !collide;
		}
		
		public function CanMoveDown(piece:gotTet, x:int, y:int):Boolean
		{
			
			var collide:Boolean = false;
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				var res:uint = BlockAt(x + e[0], y + e[1] + 1);
				switch(res)
				{
					case HasBlock:
					case HasFloor:
						collide = true;
						break;
					case HasWall:
					case HasEmpty:
						break;
				}
			});
			
			return !collide;
		}
		
		
		
		public function AddPiece(piece:gotTet, x:int, y:int):Boolean
		{
			piece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
			{
				Grid[x + e[0] + (y + e[1]) * Width] = 0xFF707070; // piece.color;
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