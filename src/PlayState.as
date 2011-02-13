package
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import org.flixel.*;
	import org.flixel.data.FlxAnim;
 
	public class PlayState extends FlxState
	{
		
		
		
		
		private static const BlockSize:uint = 8;
		
		private var GameBoard:Board;
		
		
		private var currentPiece:gotTet;
		private var queue:Array;
		private var queueSprites:Array;
		
		//private var queuedPiece:gotTetPrototype;
		
		//private var queuedSprite:FlxSprite;
		
		private function DrawGrid():void
		{
			var surface:Sprite = new Sprite();
			
			var h:uint = BlockSize * 18 + 4;
			var w:uint = BlockSize * 10 + 4;
			
			surface.graphics.beginFill(0);
			surface.graphics.lineStyle(4, 0xFFFFFFFF, 1);
			surface.graphics.drawRect(0, 0, w, h);
			surface.graphics.endFill();
			
			
			for (var y:uint = 0; y < GameBoard.Height; ++y)
			{
				for (var x:uint = 0; x < GameBoard.Width; ++x)
				{
					if (GameBoard.Grid[x + y * GameBoard.Width] != 0)
					{
						DrawSingleBlock(surface, x, y, GameBoard.Grid[x + y * GameBoard.Width], [2,2]);
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
		
		
		[Embed(source = '../blip.mp3')]
		private var clearSound:Class;
		
		
		public function GetQueued():gotTet
		{
			var p:gotTetPrototype = queue.shift();
			for (var idx:uint = 0; idx < 4; ++idx)
			{
				queueSprites[idx].pixels = queueSprites[idx + 1].pixels;
			}
			queueSprites[4].pixels = new BitmapData(1, 1, true, 0);
			
			return p.Create();
		}
		
		public function AddQueue(proto:gotTetPrototype):void
		{
			if (queue.length < 5)
			{
				queue.push(proto);
				var b:BitmapData = new BitmapData(BlockSize * 4, BlockSize * 4, true, 0);
				b.draw(CreateSprite(proto));
				queueSprites[queue.length-1].pixels = b;
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
			
/*			s.graphics.lineStyle(0);
			s.graphics.beginFill(0xFFFFFFFF);
			s.graphics.drawRect(offset[0] + x * BlockSize + 2, offset[1] + y * BlockSize + 2, 2, 2);
			s.graphics.endFill();
			
			var r:uint = (color >> 16) & 0xFF;
			var g:uint = (color >> 8) & 0xFF;
			var b:uint = color & 0xFF;
			
			s.graphics.beginFill(
				0xFF << 24 |
				uint(r * 0.9) << 16 |
				uint(g * 0.9) << 8 |
				uint(b * 0.9)
				);
			s.graphics.drawRect(offset[0] + x * BlockSize + 4, offset[1] + y * BlockSize + 4, BlockSize - 8, BlockSize - 8);
			s.graphics.endFill();*/
			
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
		
		
		
		private static const GS_Playing:uint = 1;
		private static const GS_Won:uint = 2;
		private static const GS_Gravity:uint = 3;
		
		private var GameState:uint = GS_Playing;
		
		private var Speed:Number = 0.1;
		private var wonIdx:int = 0;
		override public function update():void 
		{
			super.update();
			if (GameState == GS_Won)
			{
				while (wonIdx >= 0 && GameBoard.Grid[wonIdx] == 0) --wonIdx;
				if (wonIdx < 0) return;
				
				GameBoard.Grid[wonIdx] = 0xFF707070;
				--wonIdx;
				DrawGrid();
				return;
			}
			
			timer += FlxG.elapsed;
			while (timer > Speed)
			{
				
				if (GameState == GS_Gravity)
				{
					GameBoard.Gravity();
					GameState = GS_Playing;
					continue;
				}
				
				
				// run one update
				if (currentPiece == null && queue.length > 0)
				{
					currentPiece = GetQueued();
					curPosY = 0;
					curPosX = 3;
					
					if (!GameBoard.IsValid(currentPiece, curPosX, curPosY))
					{
						// you win!
						GameBoard.AddPiece(currentPiece, curPosX, curPosY);
						GameState = GS_Won;
						wonIdx = GameBoard.Width * GameBoard.Height - 1;
					}
					
				}
				
				if (currentPiece != null)
				{
					
					var move:AI_Move = AI_Move.GetMove(GameBoard, currentPiece, curPosX, curPosY);
					
					var oldPiece:gotTet = currentPiece;
					
					switch(move.Action)
					{
						case AI_Move.NoMove:
							break;
						case AI_Move.RotateCW:
							currentPiece = currentPiece.RotateCW();
							if (!GameBoard.IsValid(currentPiece, curPosX, curPosY))
							{
								currentPiece = oldPiece;
							}
							else 
							{
								//FlxG.play(rotateSound);
							}
							break;
						case AI_Move.RotateCCW:
							currentPiece = currentPiece.RotateCCW();
							if (!GameBoard.IsValid(currentPiece, curPosX, curPosY))
							{
								currentPiece = oldPiece;
							}
							else 
							{
								//FlxG.play(rotateSound);
							}
							break;
						case AI_Move.Rotate180:
							currentPiece = currentPiece.Rotate180();
							if (!GameBoard.IsValid(currentPiece, curPosX, curPosY))
							{
								currentPiece = oldPiece;
							}
							else 
							{
								//FlxG.play(rotateSound);
							}
							break;
						case AI_Move.MoveLeft:
							if (GameBoard.CanMoveLeft(currentPiece, curPosX, curPosY))
							{
								curPosX -= 1;
							}
							break;
						case AI_Move.MoveRight:
							if (GameBoard.CanMoveRight(currentPiece, curPosX, curPosY))
							{
								curPosX += 1;
							}
							break;
					}
					
					
					if (!GameBoard.CanMoveDown(currentPiece, curPosX, curPosY)) 
					{
						if (GameBoard.AddPiece(currentPiece, curPosX, curPosY))
						{
							GameState = GS_Gravity;
							FlxG.play(clearSound);
							
						}
						
						currentPiece = null;
					}
					else
					{
						curPosY += 1;
					}
				}
				timer -= Speed;
				DrawGrid();
			}
		}
		
		private var frame:FlxSprite;
		
		override public function create():void
		{
			
			GameBoard = new Board(10, 18);
			
			//add(queuedSprite = new FlxSprite(10, 10).createGraphic(BlockSize * 4, BlockSize * 4, 0));
			queue = [];
			queueSprites = [];
			for (var idx:uint = 0; idx < 5; ++idx)
			{
				add(queueSprites[idx] = new FlxSprite(10 + idx * 40, 10).createGraphic(BlockSize * 4, BlockSize * 4, 0));
			}
			
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
			
			var reset:FlxButton = new FlxButton(80, 220, function():void {
				GameBoard = new Board(10, 18);
				GameState = GS_Playing;
				while (queue.length > 0) GetQueued(); // not efficient, don't care
				currentPiece = null;
				DrawGrid();
			});
			
			reset.loadGraphic(new FlxSprite(0, 0).createGraphic(42, 12, 0), new FlxSprite(0,0).createGraphic(42,12, 0xFF707070));
			reset.loadText(new FlxText(0, 0, 42, "Restart"));
				
			add(reset);
			
			FlxG.mouse.show();
			
		}
	}
}