// ShuffleRock.as
// Copyright (c) 2012 by University of Massachusetts and contributors
// Project information: http://srri.umass.edu/datagames/
// Released under the MIT License http://www.opensource.org/licenses/mit-license.php

package noisy
{
	import flash.display.Sprite;
	
	import mx.controls.Text;
	
	import spark.components.Label;
	import spark.core.SpriteVisualElement;
	
	public class ShuffleRock extends SpriteVisualElement
	{
		public static const COLOR_FLAG:Number			= 0x08;			// Bitflag 1 = Red else Blue.
		public static const PATTERN_FLAG:Number			= 0x04;			// Bitflag 1 = Striped else Solid.
		public static const SHAPE_FLAG:Number			= 0x02;			// Bitflag 1 = Ball else Cube.
		public static const SIZE_FLAG:Number			= 0x01;			// Bitflag 1 = Small else Large.
		
		public static const COLOR_RED:uint				= 0xe02234;		// Color red value.
		public static const COLOR_BLUE:uint				= 0x1a6cc8;		// Color blue value.
		public static const COLOR_RED_PALER:uint		= 0xf4b5bb;		// Color paler red value.
		public static const COLOR_BLUE_PALER:uint		= 0xb4d2f5;		// Color paler blue value.
		public static const COLOR_STRING:String			= "Color";		// Color string.
		public static const PATTERN_STRING:String		= "Pattern";	// Pattern string.
		public static const SHAPE_STRING:String			= "Shape";		// Shape string.
		public static const SIZE_STRING:String			= "Size";		// Size string.
		public static const COLOR_RED_STRING:String		= "Red";		// Color string: Red
		public static const COLOR_BLUE_STRING:String	= "Blue";		// Color string: Blue 
		public static const PATTERN_STRIPED_STRING:String= "Striped";	// Pattern string: Striped
		public static const PATTERN_SOLID_STRING:String	= "Solid";		// Pattern string: Solid
		public static const SHAPE_BALL_STRING:String	= "Ball";		// Shape string: Ball
		public static const SHAPE_CUBE_STRING:String	= "Cube";		// Shape string: Cube
		public static const SIZE_SMALL_STRING:String	= "Small";		// Size string: Small
		public static const SIZE_LARGE_STRING:String	= "Large";		// Size string: Large
		
		public static const RADIUS_SIZE_SMALL:uint		= 5;			// Radius for small rock.
		public static const	RADIUS_SIZE_LARGE:uint		= 7;			// Radius for large rock.
		public static const OUTLINE_THICKNESS:uint 		= 1;			// Thickness of outline around rock.
		
		private var	mAttributeFlags:uint;	// Originally, all flags live here, but added the following to ease sorting.
		public var	mColor:Boolean;			// Color flag: true = Red, false = Blue.
		public var	mPattern:Boolean;		// Pattern flag: true = Striped, false = Solid.
		public var	mShape:Boolean;			// Shape flag: true = Ball, false = Cube.
		public var	mSize:Boolean;			// Size flag: true = Small, false = Large.
		private var	mXPosition:uint;		// Stores X position of rock.
		private var	mYPosition:uint;		// Stores Y position of rock.
		private var	mBody:Sprite;			// Used for drawing the body of the rock.

		// Constructor takes in parameters indicating the attribute flags that control 4 attributes (color, pattern,
		// shape, and size), x position, y position, and status as rock currently being played.
		public function ShuffleRock(iAttributeFlags:Number = 0, iX:uint = 0, iY:uint = 0, iCurrent:Boolean = true)
		{
			super();
			
			// Originally, all flags lived in attributeFlags, but added individual flags to ease sorting.
			mAttributeFlags	= iAttributeFlags;
			mColor			= (iAttributeFlags & COLOR_FLAG) == COLOR_FLAG;
			mPattern		= (iAttributeFlags & PATTERN_FLAG) == PATTERN_FLAG;
			mShape			= (iAttributeFlags & SHAPE_FLAG) == SHAPE_FLAG;
			mSize			= (iAttributeFlags & SIZE_FLAG) == SIZE_FLAG;
			mXPosition		= iX;
			mYPosition		= iY;
			
			mBody			= new Sprite;
			this.hideMe();				// Remain hidden until drawn.
			this.addChild(mBody);	// body must be child of Shufflerock to display.
		}
		
		// getRadius returns the radius of the rock based on it size.
		public function getRadius():uint
		{
			return mSize ? RADIUS_SIZE_SMALL : RADIUS_SIZE_LARGE;
		}
			
		// getRadius returns the radius of the rock based on it size.
		public function getCircumference():uint
		{
			var radius:uint	= mSize ? RADIUS_SIZE_SMALL : RADIUS_SIZE_LARGE;
			
			return 2 * Math.PI * radius;
		}
		
		// setPosition() sets the x and y position of the ShuffleRock.
		public function setPosition(iX:uint, iY:uint):void
		{
			mXPosition = iX;
			mYPosition = iY;
		}
		
		// setPositionX() sets the x position of the ShuffleRock.
		public function setPositionX(iX:uint):void
		{
			mXPosition = iX;
		}
		
		// setPositionY() sets the y position of the ShuffleRock.
		public function setPositionY(iY:uint):void
		{
			mYPosition = iY;
		}
		
		// getPositionX() gets the x position of the ShuffleRock.
		public function getPositionX():uint
		{
			return mXPosition;
		}
		
		// getPositionY() gets the Y position of the ShuffleRock.
		public function getPositionY():uint
		{
			return mYPosition;
		}
		
		// getColor() returns the string describing the rock's color.
		public function getColor():String
		{
			return mColor ? COLOR_RED_STRING : COLOR_BLUE_STRING;
		}
		
		// getPattern() returns the string describing the rock's pattern.
		public function getPattern():String
		{
			return mPattern ? PATTERN_STRIPED_STRING : PATTERN_SOLID_STRING;
		}
		
		// getShape() returns the string describing the rock's shape.
		public function getShape():String
		{
			return mShape ? SHAPE_BALL_STRING : SHAPE_CUBE_STRING;
		}
		
		// getSize() returns the string describing the rock's size.
		public function getSize():String
		{
			return mSize ? SIZE_SMALL_STRING : SIZE_LARGE_STRING;
		}
		
		// setColor sets the rock's color equal to iNewColor.
		public function setColor(iNewColor:Boolean):Boolean
		{
			var oldColor:Boolean	= mColor;
			mColor					= iNewColor;
			return oldColor;
		}
		
		// setPattern sets the rock's pattern equal to iNewPattern.
		public function setPattern(iNewPattern:Boolean):Boolean
		{
			var oldPattern:Boolean	= mPattern;
			mPattern				= iNewPattern;
			return oldPattern;
		}
		
		// setShape sets the rock's shape equal to iNewShape.
		public function setShape(iNewShape:Boolean):Boolean
		{
			var oldShape:Boolean	= mShape;
			mShape					= iNewShape;
			return oldShape;
		}
		
		// setSize sets the rock's size equal to iNewSize.
		public function setSize(iNewSize:Boolean):Boolean
		{
			var oldSize:Boolean		= mSize;
			mSize					= iNewSize;
			return oldSize;
		}
		
		// hideMe() make the rock invisible.
		public function hideMe():void
		{
			this.visible = false;
		}
		
		// showMe() makes the rock visible.
		public function showMe():void
		{
			this.visible = true;
		}
		
		// drawMe() draws the rock using current settings.
		public function drawMe():void	
		{
			var bodyColor:uint	= mColor ? COLOR_RED : COLOR_BLUE;
			var lineColor:uint	= mColor ? COLOR_RED_PALER : COLOR_BLUE_PALER;
			var radius:uint		= mSize ? RADIUS_SIZE_SMALL : RADIUS_SIZE_LARGE;
			var diameter:uint	= radius * 2;

			mBody.graphics.clear();
			mBody.graphics.beginFill(bodyColor);
			
			// Draw circle if shape is a sphere (this.shape == true), else draw square (this.shape == false).
			if (mShape)
				mBody.graphics.drawCircle(mXPosition, mYPosition, radius);
			else
				// Shift starting x and y drawing position so that square is drawn with center at x, y.
				mBody.graphics.drawRect(mXPosition - radius, mYPosition - radius, diameter, diameter);
			
			// Draw stripe if striped rock (this.mPattern == true), nothing for 
			// solid (this.mPattern == false).
			mBody.graphics.beginFill(lineColor);
			if (mPattern)
				mBody.graphics.drawRect(mXPosition - radius, mYPosition - 1, diameter, 2);

			this.showMe();
		}
	}
}