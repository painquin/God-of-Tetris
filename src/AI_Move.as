package  
{
	/**
	 * ...
	 * @author Quin
	 */
	public class AI_Move
	{
		public var Score:Number;
		public var XPos:uint;
		public var Action:uint;
		
		public function AI_Move(score:Number, xpos:uint, action:uint) 
		{
			Score = score;
			XPos = xpos;
			Action = action;
		}
		
		public static const NoMove:uint = 0;
		public static const RotateCW:uint = 1;
		public static const RotateCCW:uint = 2;
		public static const Rotate180:uint = 3;
		public static const MoveLeft:uint = 4;
		public static const MoveRight:uint = 5;
		
		private static var Neighbors:Array = [ [ -1, 0], [1, 0], [0, -1], [0, 1] ];
		
		private static function ScoreForDrop(board:Board, piece:gotTet, x:int, y:int):Number
		{
			
			for (var idx:int = 0; idx < 4; ++idx)
			{
				if (board.BlockAt(x + piece.squares[idx][0], y + piece.squares[idx][1]) != Board.HasEmpty)
				{
					return Number.MAX_VALUE;
				}
			}
			
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
			var bestScore:Number = 1000;
			for (var x:int = -3; x < board.Width + 3; ++x)
			{
				var t:Number = ScoreForDrop(board, piece, x, y);
				if (t < bestScore)
				{
					bestX = x;
					bestScore = t;
				}
			}
			trace("> ", bestScore)
			return new AI_Move(bestScore, bestX, action);
		}
		
		
		public static function GetMove(board:Board, piece:gotTet, y:int):AI_Move
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
			

			return bestMove;
		}
	}

}