package
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import org.flixel.*;
 
	public class PlayState extends FlxState
	{
		
		public static const NoMove:uint = 0;
		public static const RotateCW:uint = 1;
		public static const RotateCCW:uint = 2;
		public static const Rotate180:uint = 3;
		public static const MoveLeft:uint = 4;
		public static const MoveRight:uint = 5;
		
		
		private static const GridWidth:uint = 10;
		private static const GridHeight:uint = 18;
		
		private static const BlockSize:uint = 8;
		
		private var GameGrid:Array;
		
		
		private var currentPiece:gotTet;
		private var queuedPiece:gotTetPrototype;
		
		private var queuedSprite:FlxSprite;
		
		private function DrawGrid():void
		{
			var surface:Sprite = new Sprite();
			
			var h:uint = BlockSize * 18 + 4;
			var w:uint = BlockSize * 10 + 4;
			
			surface.graphics.beginFill(0);
			surface.graphics.lineStyle(4, 0xFFFFFFFF, 1);
			surface.graphics.drawRect(0, 0, w, h);
			surface.graphics.endFill();
			
			
			for (var y:uint = 0; y < GridHeight; ++y)
			{
				for (var x:uint = 0; x < GridWidth; ++x)
				{
					if (GameGrid[x + y * GridWidth] != 0)
					{
						DrawSingleBlock(surface, x, y, GameGrid[x + y * GridWidth], [2,2]);
					}
				}
			}
			
			if (currentPiece != null) 
			{
				currentPiece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
				{
					DrawSingleBlock(surface, curPosX + e[0], curPosY +  e[1], currentPiece.color, [2, 2]); 
				});
			}
			
			var b:BitmapData = new BitmapData(w, h, true, 0xFF000000);
			b.draw(surface);
			
			frame.pixels = b;
		}
		
		public function ClearQueue():void
		{
			queuedPiece = null;
			queuedSprite.pixels = new BitmapData(1, 1, true, 0);
		}
		
		public function AddQueue(proto:gotTetPrototype):void
		{
			if (queuedPiece == null)
			{
				queuedPiece = proto;
				var b:BitmapData = new BitmapData(BlockSize * 4, BlockSize * 4, true, 0);
				b.draw(CreateSprite(queuedPiece));
				queuedSprite.pixels = b;
				return;
			}
		}

		
		private function DrawSingleBlock(s:Sprite, x:uint, y:uint, color:uint, offset:Array = null):Sprite
		{
			if (offset == null) offset = [0, 0];
			// todo: PRETTIER
			s.graphics.beginFill(color);
			s.graphics.lineStyle(1, 0xFFF0F0F0, 1);
			s.graphics.drawRect(offset[0] + x * BlockSize + 1, offset[1] + y * BlockSize + 1, BlockSize-2, BlockSize-2);
			s.graphics.endFill();
			
			return s;
		}
		
		private function CreateSprite(proto:gotTetPrototype):Sprite
		{
			var s:Sprite = new Sprite();

			s.height = BlockSize * 4;
			s.width = BlockSize * 4;
			
			proto.squares.forEach(function(e:Array, index:int, arr:Array):void
			{
				DrawSingleBlock(s, e[0], e[1], proto.color);
			});
			
			return s;
		}
		
		private function CreateButton(proto:gotTetPrototype, x:uint, y:uint):FlxButton
		{
			var s:Sprite = CreateSprite(proto);
			
			var f:FlxSprite = new FlxSprite(0, 0);
			var f2:FlxSprite = new FlxSprite(0, 0);
			var b:BitmapData = new BitmapData(BlockSize * 4, BlockSize * 4, true, 0xFF000000);
			var b2:BitmapData = new BitmapData(BlockSize * 4, BlockSize * 4, true, 0xFF707070);
			
			b.draw(s);
			b2.draw(s);
			
			f.pixels = b;
			f2.pixels = b2;
			
			return new FlxButton(x, y, function():void { AddQueue(proto); } ).loadGraphic(f, f2);
		}
		
		public var timer:Number = 0.5;
		
		public var curPosX:int;
		public var curPosY:int;
		
		
		// returns 0 if there is no reason that you can't put a block at this spot
		// returns 1 if there is another block in the way or you hit the bottom
		// returns 2 if there is a wall in the way
		
		private function CanHas(x:uint, y:uint):uint
		{
			if (x < 0 || x >= GridWidth) return 2;
			if (y < 0) return 2;
			
			if (y > GridHeight) return 1;
			
			if (GameGrid[x + y * GridWidth] != 0) return 1;
			
			return 0;
		}
		
		private function CheckCollision(piece:gotTet, x:uint, y:uint):uint
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
		
		private static var Neighbors:Array = [ [ -1, 0], [1, 0], [0, -1], [0, 1] ];
		
		private function AI_ScoreForDrop(piece:gotTet, x:uint):uint
		{
			for (var drop:uint = curPosY; drop < GridHeight; ++drop)
			{
				if (CheckCollision(piece, x, drop)) break;
			}
			
			// should have "piece" at the end now
			var score:Number = 0;
			for (var idx:uint = 0; idx < 4; ++idx)
			{
				// bounds
				if (piece.squares[idx][0] + x < 0) return 0;
				if (piece.squares[idx][0] + x > GridWidth) return 0;
				if (piece.squares[idx][1] + drop > GridHeight) return 0;
				
				for (var idx2:uint = 0; idx2 < 4; ++idx2)
				{
					var xpos:uint = piece.squares[idx][0] + Neighbors[idx2][0] + x;
					var ypos:uint = piece.squares[idx][1] + Neighbors[idx2][1] + drop;
					
					if (xpos < 0 || xpos >= GridWidth) score += 1;
					else if (ypos < 0 || ypos >= GridHeight) score += 1;
					else if (GameGrid[xpos + ypos * GridWidth] != 0) score += 1;
				}
			}
			
			return score;
			
		}
		
		private function AI_GetBestMoveForPiece(piece:gotTet, action:uint):AI_Move
		{
			var bestX:int = 0;
			var bestScore:uint = 0;
			
			for (var x:int = -3; x < GridWidth + 3; ++x)
			{
				var t:uint = AI_ScoreForDrop(piece, x);
				if (t > bestScore)
				{
					bestX = x;
					bestScore = t;
				}
			}
			
			return new AI_Move(bestScore, bestX, action);
		}
		
		
		private function AI_GetMove():uint
		{
			var bestMove:AI_Move = AI_GetBestMoveForPiece(currentPiece, NoMove);
			
			var contenderMove:AI_Move = AI_GetBestMoveForPiece(currentPiece.RotateCW(), RotateCW);
			
			if (contenderMove.Score > bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			contenderMove = AI_GetBestMoveForPiece(currentPiece.RotateCCW(), RotateCCW);
			
			if (contenderMove.Score > bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			contenderMove = AI_GetBestMoveForPiece(currentPiece.Rotate180(), Rotate180);
			
			if (contenderMove.Score > bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			if (bestMove.Action == NoMove)
			{
				if (bestMove.XPos < curPosX)
				{
					return MoveLeft;
				}
				if (bestMove.XPos > curPosX)
				{
					return NoMove;
				}
				
				return NoMove;
			}
			
			return bestMove.Action;
			
		}
		
		
		private static const GS_Playing:uint = 1;
		private static const GS_Won:uint = 2;
		private static const GS_Gravity:uint = 3;
		
		private var GameState:uint = GS_Playing;
		
		private var Speed:Number = 0.25;
		
		private var linesCleared:Array = [];
		
		private function Player_GetMove():uint
		{
			if (FlxG.keys.LEFT) return MoveLeft;
			if (FlxG.keys.RIGHT) return MoveRight;
			if (FlxG.keys.ENTER) return RotateCW;
			if (FlxG.keys.CONTROL) return RotateCCW;
			
			return NoMove;
		}
		
		override public function update():void 
		{
			super.update();
			if (GameState == GS_Won)
			{
				return;
			}
			
			timer += FlxG.elapsed;
			while (timer > Speed)
			{
				
				if (GameState == GS_Gravity)
				{
					var destY:int = GridHeight - 1;
					var x:uint;
					for (var srcY:int = GridHeight - 1; srcY >= 0; --srcY)
					{
						if (linesCleared.indexOf(srcY) != -1)
						{
							continue;
						}
						
						if (srcY != destY) 
						{
							for (x = 0; x < GridWidth; ++x)
							{
								GameGrid[x + destY * GridWidth] = GameGrid[x + srcY * GridWidth];
							}
						}
						
						
						--destY;
					}
					
					while (destY >= 0)
					{
						for (x = 0; x < GridWidth; ++x)
						{
							GameGrid[x + destY * GridWidth] = 0;
						}
						--destY;
					}
					
					linesCleared = [];
					GameState = GS_Playing;
					continue;
				}
				
				
				// run one update
				if (currentPiece == null && queuedPiece != null)
				{
					currentPiece = queuedPiece.Create();
					ClearQueue();
					curPosY = 0;
					curPosX = 3;
					
					if (CheckCollision(currentPiece, curPosX, curPosY))
					{
						// you win!
						GameState = GS_Won;
						
					}
					
				}
				
				if (currentPiece != null)
				{
					
					var move:uint = AI_GetMove();
					
					//var move:uint = Player_GetMove();
					
					var oldPiece:gotTet = currentPiece;
					var oldX:int = curPosX;
					var oldY:int = curPosY;
					
					switch(move)
					{
						case NoMove:
							curPosY += 1;
							break;
						case RotateCW:
							currentPiece = currentPiece.RotateCW();
							break;
						case RotateCCW:
							currentPiece = currentPiece.RotateCCW();
							break;
						case Rotate180:
							currentPiece = currentPiece.Rotate180();
							break;
						case MoveLeft:
							curPosX -= 1;
							curPosY += 1;
							break;
						case MoveRight:
							curPosX += 1;
							curPosY += 1;
							break;
					}
					
					// now check for collision
					var reason:uint = CheckCollision(currentPiece, curPosX, curPosY)
					if (reason) 
					{
						currentPiece = oldPiece;
						curPosX = oldX;
						curPosY = oldY;
						
						if (reason == 1)
						{
							currentPiece.squares.forEach(function(e:Array, idx:uint, arr:Array):void
							{
								GameGrid[curPosX + e[0] + (curPosY + e[1]) * GridWidth] = currentPiece.color;
							});
							
							currentPiece = null;
							
							// check clear
							
							for (var clearY:int = 0; clearY < GridHeight; ++clearY)
							{
								var missing:Boolean = false;
								for (var clearX:uint = 0; clearX < GridWidth; ++clearX)
								{
									if (GameGrid[clearX + clearY * GridWidth] == 0) {
										missing = true;
										break;
									}
								}
								
								if (!missing)
								{
									linesCleared.push(clearY);
									
									for (clearX = 0; clearX < GridWidth; ++clearX)
									{
										GameGrid[clearX + clearY * GridWidth] = 0
									}
								}
								
							}
							
							if (linesCleared.length > 0)
							{
								GameState = GS_Gravity;
							}
							
						}
					}
				}
				timer -= Speed;
				DrawGrid();
			}
		}
		
		private var frame:FlxSprite;
		
		override public function create():void
		{
			
			GameGrid = [];
			for (var idx:uint; idx < GridWidth * GridHeight; ++idx)
			{
				//if (idx % 10 == 0 || idx / 10 < 12)
				//{
					GameGrid[idx] = 0;
				//} else {
				//	GameGrid[idx] = 0xFF00FFFF;
				//}
			}
			
			add(queuedSprite = new FlxSprite(10, 10).createGraphic(BlockSize * 4, BlockSize * 4, 0));
			
			add(frame = new FlxSprite(8, 48).createGraphic(1, 1, 0));
			
			DrawGrid();
			
			add(CreateButton(new gotTetPrototype([
				[1, 0],
				[1, 1],
				[1, 2],
				[1, 3]
				], 0xFFA6AFFF), 110, 50));
			
			add(CreateButton(new gotTetPrototype([
				[1, 1],
				[2, 1],
				[1, 2],
				[2, 2]
				], 0xFFFFFF00), 150, 50));
			
			add(CreateButton(new gotTetPrototype([
				[1, 0],
				[1, 1],
				[1, 2],
				[2, 2]
				], 0xFFFF6600), 110, 90));
				
			add(CreateButton(new gotTetPrototype([
				[2, 0],
				[2, 1],
				[2, 2],
				[1, 2]
				], 0xFF0000FF), 150, 90));
				
			add(CreateButton(new gotTetPrototype([
				[2, 0],
				[1, 1],
				[2, 1],
				[1, 2]
				], 0xFFFF0000), 110, 130));
				
			add(CreateButton(new gotTetPrototype([
				[1, 0],
				[1, 1],
				[2, 1],
				[2, 2]
				], 0xFF00FF00), 150, 130));
				
			add(CreateButton(new gotTetPrototype([
				[1, 0],
				[1, 1],
				[2, 1],
				[1, 2]
				], 0xFFFF00FF), 130, 170));
			
			FlxG.mouse.show();
			
		}
	}
}