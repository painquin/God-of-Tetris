package  
{
	/**
	 * ...
	 * @author Quin
	 */
	public class AI_Move
	{
		public var Score:uint;
		public var XPos:uint;
		public var Action:uint;
		
		public function AI_Move(score:uint, xpos:uint, action:uint) 
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
		
		private static function ScoreForDrop(board:Board, piece:gotTet, x:int, y:int):uint
		{
			for (var drop:uint = y; drop < board.Height; ++drop)
			{
				if (board.CheckCollision(piece, x, drop)) break;
			}
			
			var count:uint = 0;
			
			// should have "piece" at the end now
			var score:uint = 0;
			for (var idx:uint = 0; idx < board.Width * board.Height; ++idx)
			{
				
			}
			
			return score;
			
		}
		
		private static function GetBestMoveForPiece(board:Board, piece:gotTet, action:uint, y:int):AI_Move
		{
			var bestX:int = 0;
			var bestScore:uint = 0;
			
			for (var x:int = -3; x < board.Width + 3; ++x)
			{
				var t:uint = ScoreForDrop(board, piece, x, y);
				if (t > bestScore)
				{
					bestX = x;
					bestScore = t;
				}
			}
			
			return new AI_Move(bestScore, bestX, action);
		}
		
		
		public static function GetMove(board:Board, piece:gotTet, y:int):AI_Move
		{
			var bestMove:AI_Move = GetBestMoveForPiece(board, piece, NoMove, y);
			
			var contenderMove:AI_Move = GetBestMoveForPiece(board, piece.RotateCW(), RotateCW, y);
			
			if (contenderMove.Score > bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			contenderMove = GetBestMoveForPiece(board, piece.RotateCCW(), RotateCCW, y);
			
			if (contenderMove.Score > bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			contenderMove = GetBestMoveForPiece(board, piece.Rotate180(), RotateCCW, y);
			
			if (contenderMove.Score > bestMove.Score)
			{
				bestMove = contenderMove;
			}
			
			
			return bestMove;
			
			/*
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
			
			return bestMove.Action;*/
			
		}
	}

}