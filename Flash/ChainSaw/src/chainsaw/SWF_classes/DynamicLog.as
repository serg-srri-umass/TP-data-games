package {
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.display.MovieClip;
	import flash.filters.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.GradientType;
	
	public class DynamicLog extends MovieClip {
		
		public var myShadow = new DropShadowFilter(10,75,0x4A3200,.5,8,10,1,3);
		public var myShadow2 = new DropShadowFilter(3,90,0x000000,.5,2,2,1,3);
		public var LogNumber:int;
		public var Listener:MovieClip;
		public var LtoRCut:int = 0;
		public var LastCutX:int = 0;
		public var LogLength:int;				// length of current log
		public var LogPtsTop:Vector.<Point > ;
		public var LogPtsBtm:Vector.<Point > ;
		public var StartCut:Boolean = false;
		public var baseX;						//
		public var baseY;						//
		public var StartCutPt:Point;
		public var EndCutPt:Point;
		public var BezierPt:Point;
		public var numSegments:int = 16;
		public var segPercentDrawn:Number = 0;
		public var LogWidthLabel:String = "thin";
		public var cutFromTop:Boolean;
		
		public var curSegment:Segment;
		public var partialSegment:Segment;

		public function DynamicLog() {
			// constructor code
			Mouse.cursor = "arrow";
			this.filters = [myShadow,myShadow2];
			drawNewLog(337);
			resizeLogFront(35,12);
		}
		
		public function init(CutDirection:int, Lstnr:MovieClip = null):void
		{
			Listener = Lstnr;
			LtoRCut = CutDirection;
			if (LtoRCut == -1)
			{
				LastCutX = LogLength;
			}
			else
			{
				LastCutX = 0;
			}
		}
		
		public function reset():void
		{
			StartCut = false;
			if (LtoRCut == -1)
			{
				LastCutX = LogLength;
			}
			else
			{
				LastCutX = 0;
			}
		}
		public function getLogWidthLabel():String{
			return LogWidthLabel;
		}
		public function setLogWidthLabel(lbl:String):void{
			LogWidthLabel = lbl;
		}
		public function getNextLog():MovieClip
		{
			return Listener;
		}
		public function setLogNum(num:int):void
		{
			trace(num);
			LogNumber = num;
		}
		public function getLogNum():int
		{
			return LogNumber;
		}
		public function setCutDirection(num:int):void
		{
			LtoRCut = num;
		}
		public function getCutDirection():int
		{
			return LtoRCut;
		}
		public function isTopToBottomCut():Boolean
		{
			return cutFromTop;
		}
		
		//Ryan - Convienience method that simply determines if the given x position is on the side of the log that you can cut
		public function canCutAt(x_position:int):Boolean
		{
			return x_position*LtoRCut >= LastCutX*LtoRCut;
		}
		
		public function drawNewLog(lngth:int):void
		{
			LogLength = lngth; //save the length
		
			graphics.clear();
			LogPtsTop = new Vector.<Point >   ;
			LogPtsBtm = new Vector.<Point >   ;
		
			
			//generate point lists for top and bottom edges of logs
			var segments:int = Math.floor(Math.random()*(4)+4);
			baseX = LogFront.x;
			baseY = LogFront.y;
			var bottomOffset = LogFront.height - 1;
			var avgLength = LogLength / segments;
			LogPtsTop.push(new Point(baseX,baseY));
			LogPtsBtm.push(new Point(baseX,baseY+bottomOffset));
			for (var i:int = 0; i<segments; i++)
			{
				LogPtsTop.push(new Point(baseX + avgLength*(i+1)+(Math.random()*10-20), baseY+(Math.random()*5-2.5)));
				LogPtsBtm.push(new Point(baseX + avgLength*(i+1)+(Math.random()*10-20), baseY+bottomOffset+(Math.random()*5-2.5)));
			}
			//last point
			LogPtsTop.push(new Point(baseX + LogLength, baseY));
			LogPtsBtm.push(new Point(baseX + LogLength, baseY+bottomOffset));
		
			
			//draw the log;
			graphics.lineStyle(2, 0x704A00);
			var colors:Array = [0xBFA681,0x794F00,0xBFA681];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,255,0];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(LogLength, bottomOffset-baseY, Math.PI/2, 0, 0);
			var log:Shape = new Shape  ;
			graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			graphics.moveTo(LogPtsTop[0].x, LogPtsTop[0].y);
			//for(var item in LogPtsTop){;
			for (i=1; i<LogPtsTop.length; i++)
			{
				graphics.lineTo(LogPtsTop[i].x, (Point)(LogPtsTop[i]).y);
			}
			graphics.curveTo(LogPtsTop[LogPtsTop.length-1].x+LogFront.width/2,(bottomOffset+baseY)/2, LogPtsBtm[LogPtsBtm.length-1].x, LogPtsBtm[LogPtsBtm.length-1].y);
			for (i=LogPtsBtm.length-1; i>-1; i--)
			{
				graphics.lineTo(LogPtsBtm[i].x, LogPtsBtm[i].y);
			}
			
			// Moved reset(); to end of method to make sure new length is used. ~Ryan
			reset();
		}
		
		public function resizeLogFront(h:Number, w:Number):void
		{
			LogFront.height = h;
			LogFront.width = w;
			if (LogLength != 0)
			{
				drawNewLog(LogLength);
			}
		}
		
		public function cutLog(X:Number):void
		{
			//Log has been fully cut, update display, set last cut value
			displayLogSegment(1);
			cutCompleted();
			LastCutX = X;
		}
		
		
		
		public function pointOnLinesBtwnPts(X:Number, vec:Vector.<Point>):Point
		{
			for (var Index:int = 0; Index < vec.length; Index++)
			{
				if (X < vec[Index].x)
				{
					break;
				}
			}
			if (Index>=vec.length)
			{
				Index = vec.length - 1;
			}
			else if (Index < 0)
			{
				Index = 0;
			}
			var LowX,HighX,LowY,HighY;
			//if cut is left of start of log (not possible but just in case), start at log base
			LowX = vec[Math.max(Index-1,0)].x;
			LowY = vec[Math.max(Index-1,0)].y;
			HighX = vec[Index].x;
			HighY = vec[Index].y;
			var topY = (HighY - LowY) / (HighX - LowX) * (X - LowX) + LowY;
			return new Point(X, topY);
		}
		public function logUp(e:MouseEvent):void
		{
			StartCut = false;
		}
		public function logInMod(X:Number, Y:Number):void
		{
			/*
			//Debug traces ~Ryan
			trace("  LastX: "+LastCutX + "	dir: "+LtoRCut + "	log length: "+LogLength);
			trace("      X: "+X);
			*/
			
			if (canCutAt(X))
			{
				StartCut = true;
				segPercentDrawn = 0;
				if (Y + LogFront.height/2 < LogFront.y+LogFront.height)
				{
					cutFromTop = true;
					StartCutPt = pointOnLinesBtwnPts(X,LogPtsTop);
					EndCutPt = pointOnLinesBtwnPts(X,LogPtsBtm);
				}
				else
				{
					cutFromTop = false;
					StartCutPt = pointOnLinesBtwnPts(X,LogPtsBtm);
					EndCutPt = pointOnLinesBtwnPts(X,LogPtsTop);
				}
				BezierPt = new Point(StartCutPt.x+LogFront.width/2, (StartCutPt.y+EndCutPt.y)/2);
				curSegment = new Segment(StartCutPt,EndCutPt,BezierPt);
			}
		}
		public function logOutMod(X:Number, Y:Number):Boolean
		{
			if (StartCut && Math.abs(Y-StartCutPt.y) > LogFront.height/2)
			{
				cutLog(StartCutPt.x);
				StartCut = false;
				return true;
			}
			return false;
		}
		public function midLogMod(X:Number, Y:Number):void
		{
			if (StartCut)
			{
				var d = Math.abs(StartCutPt.y - Y);
				var segmentsPercent:Number = d / LogFront.height;
				segmentsPercent = Math.min(1.0,segmentsPercent);
				if (segmentsPercent > segPercentDrawn)
				{
					displayLogSegment(segmentsPercent);
					segPercentDrawn = segmentsPercent;
				}
			}
		}
		
		//percent: [0-1]
		public function displayLogSegment(percent:Number):void
		{
			partialSegment = curSegment.subdivide(percent);
			graphics.lineStyle(1, 0x704A00, .6);
			graphics.beginFill(0x111111, .6);
			//graphics.beginFill(0x888888, .6);
			graphics.moveTo(partialSegment.start.x, partialSegment.start.y);
			graphics.curveTo(partialSegment.control.x, partialSegment.control.y, partialSegment.end.x, partialSegment.end.y);
			graphics.lineTo(partialSegment.end.x-2, partialSegment.end.y);
			graphics.curveTo(partialSegment.control.x, partialSegment.control.y, partialSegment.start.x-2, partialSegment.start.y);
			
			//if(percent > .85) cutCompleted();
		}
		
		/**
		Called when the cut is complete
		Use this to highlight/bold/etc the line to indicate that the cut completed
		-Ryan
		*/
		public function cutCompleted()
		{
			//TODO: highlight line in yellow, fade to brown
			partialSegment = curSegment.subdivide(1);
			//graphics.lineStyle(1, 0xd8d808, .6);
			
			graphics.lineStyle(3, 0x704A00, .6);
			graphics.beginFill(0xFFFFFF, .6);
			//graphics.beginFill(0x111111, .6);
			graphics.moveTo(partialSegment.start.x, partialSegment.start.y);
			graphics.curveTo(partialSegment.control.x, partialSegment.control.y, partialSegment.end.x, partialSegment.end.y);
			graphics.lineTo(partialSegment.end.x-2, partialSegment.end.y);
			graphics.curveTo(partialSegment.control.x, partialSegment.control.y, partialSegment.start.x-2, partialSegment.start.y);
			
		}
	}
}
