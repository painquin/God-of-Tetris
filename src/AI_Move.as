package  
{
	/**
	 * ...
	 * @author Quin
	 */
	public class AI_Move
	{
		public var Score:Number;
		public var Action:uint;
		public var XPos:int;
		public var Next:AI_Move;
		
		public function AI_Move(score:Number, action:uint, xpos:int, next:AI_Move = null) 
		{
			Score = score;
			Action = action;
			XPos = xpos;
			Next = next;
		}
		
		public static const NoMove:uint = 0;
		public static const RotateCW:uint = 1;
		public static const RotateCCW:uint = 2;
		public static const MoveLeft:uint = 3;
		public static const MoveRight:uint = 4;
		
		public static var MoveNames:Array = [ "No Move   ", "Rotate CW ", "Rotate CCW", "Move Left ", "Move Right" ];
		
		public static const Rotate180:uint = 6;
		
		/*private static function ScoreForDrop(board:Board):Number
		{
			var score:Number = 0;

			for (var scanx:int = 0; scanx < board.Width; ++scanx)
			{
				for (var scany:int = 0; scany < board.Height + 1; ++scany)
				{
					var v:uint = board.BlockAt(scanx, scany);
					if (v != Board.HasEmpty)
					{
						score += ((board.Height - scany) * (board.Height - scany));
						break;
					}
				}
			}
			
			return score;
		}

		public static function GetMove(board:Board, piece:gotTet, x:int, y:int):AI_Move
		{
			var BestMove:AI_Move = new AI_Move(Number.MAX_VALUE, NoMove, null);
			
			for (var action:uint = NoMove; action <= MoveRight; ++action)
			{
				var myX:int = x;
				var myY:int = y;
				var myPiece:gotTet = piece;
				var myMove:AI_Move;
				
				switch(action)
				{
					case NoMove:
					default:
						break;
					case RotateCW:
						myPiece = piece.RotateCW();
						break;
					case RotateCCW:
						myPiece = piece.RotateCCW();
						break;
					case MoveLeft:
						myX -= 1;
						break;
					case MoveRight:
						myX += 1;
						break;
				}
				
				if (!board.IsValid(myPiece, myX, myY)) 
				{
					continue;
				}
				
				if (board.CanMoveDown(myPiece, myX, myY))
				{
					
					var t:AI_Move = GetMove(board, myPiece, myX, myY+1);
					myMove = new AI_Move(t.Score, action, t);
				}
				else
				{
					
					var myBoard:Board = board.Copy();
					myBoard.AddPiece(piece, myX, myY);
					myBoard.Gravity();
					myMove = new AI_Move(ScoreForDrop(myBoard), action, null);
				}
				
				if (myMove.Score < BestMove.Score)
				{
					BestMove = myMove;
				}
			}
			return BestMove;
		}*/
		
		private static function ScoreForDrop(board:Board, piece:gotTet, x:int, y:int):Number
		{
			var newBoard:Board = board.Copy();

			var drop:int = y;
			while (newBoard.CanMoveDown(piece, x, drop))
			{
				++drop;
			}

			newBoard.AddPiece(piece, x, drop);
			newBoard.Gravity();

			var score:Number = 0;

			for (var scanx:int = 0; scanx < newBoard.Width; ++scanx)
			{
				for (var scany:int = 0; scany < newBoard.Height + 1; ++scany)
				{
					var v:uint = newBoard.BlockAt(scanx, scany);
					if (v != Board.HasEmpty)
					{
						score += ((newBoard.Height - scany) * (newBoard.Height - scany));
						break;
					}
				}
			}

			return score;
		}

		private static function GetBestMoveForPiece(board:Board, piece:gotTet, action:uint, y:int):AI_Move
		{
			var bestX:int = 0;
			var bestScore:Number = Number.MAX_VALUE;
			for (var x:int = -3; x < board.Width + 3; ++x)
			{
				if (!board.IsValid(piece, x, y)) continue;
				
				var t:Number = ScoreForDrop(board, piece, x, y);
				if (t < bestScore)
				{
					bestX = x;
					bestScore = t;
				}
			}
			
			return new AI_Move(bestScore, action, bestX);
		}


		public static function GetMove(board:Board, piece:gotTet, x:int, y:int):AI_Move
		{
			var bestMove:AI_Move = GetBestMoveForPiece(board, piece, NoMove, y);

			var contenderMove:AI_Move = GetBestMoveForPiece(board, piece.RotateCW(), RotateCW, y);

			if (contenderMove.Score < bestMove.Score)
			{
				bestMove = contenderMove;
			}

			contenderMove = GetBestMoveForPiece(board, piece.RotateCCW(), RotateCCW, y);

			if (contenderMove.Score < bestMove.Score)
			{
				bestMove = contenderMove;
			}

			contenderMove = GetBestMoveForPiece(board, piece.Rotate180(), RotateCCW, y);

			if (contenderMove.Score < bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			if (bestMove.Action == NoMove)
			{
				if (bestMove.XPos < x)
				{
					bestMove.Action = MoveLeft;
				}
				else if (bestMove.XPos > x)
				{
					bestMove.Action = MoveRight;
				}
			}


			return bestMove;
		}
	}

}