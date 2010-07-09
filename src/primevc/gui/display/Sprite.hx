/*
 * Copyright (c) 2010, The PrimeVC Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PRIMEVC PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE PRIMVC PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 *
 * Authors:
 *  Danny Wilson	<danny @ onlinetouch.nl>
 */
package primevc.gui.display;

// ----------------------------------
// Actual Sprite layer implementation
// ----------------------------------

typedef Sprite = 
	#if		flash9	primevc.avm2.Sprite;
	#elseif	flash8	primevc.avm1.Sprite;
	#elseif	js		primevc.js  .Sprite;
	#else			SpriteImpl

import primevc.gui.events.DisplayEvents;
import primevc.gui.events.IUserEvents;
import primevc.core.geom.Matrix2D;
import primevc.core.geom.Rectangle;
import primevc.gui.events.UserEvents;

/**
 * Mock implementation of Sprite
 * 
 * @author			Danny Wilson
 * @creation-date	unknown
 */
class SpriteImpl implements ISprite
{
	public var userEvents	(default, null)					: IUserEvents;
	public var displayEvents (default, null)				: DisplayEvents;
	
	public var dropTarget	(default, null)					: IDisplayObject;
	public var parent		(default, null)					: ISprite;
	
	public var transform	(default,null)					: Matrix2D;
	public var visible		(getVisibility, setVisibility)	: Bool;
	public var numChildren	(getNumChildren, never)			: Int;
	
	public var mouseEnabled	(getEnabled, setEnabled)		: Bool;
		private inline function getEnabled ()				{ return mouseEnabled; }
		private inline function setEnabled (v:Bool)			{ return mouseEnabled = v; }
	
	public var alpha		(default, setAlpha)				: Float;
		private inline function setAlpha(a:Float)			{ return alpha = a; }	
	
	public var x			(getX,			setX)			: Float;
	public var y			(getY,			setY)			: Float;
	public var width		(getWidth,		setWidth)		: Float;
	public var height		(getHeight,		setHeight)		: Float;
	
	private var _visible:Bool;
	private var children:Array < ISprite >;
	
	
	
	public function new()
	{
		children = [];
		userEvents		= new UserEvents();
		displayEvents	= new DisplayEvents();
	}
	
	public inline function addChild(child:ISprite)
	{
		child.parent = this;
		children.push(child);
	}
	
	
	public inline function addChildAt(child:ISprite, depth:Int)
	{
		child.parent = this;
		
		var a = children.slice(0, depth);
		a.push(child);
		a.concat(children.slice(depth));
		children = a;
	}
	
	
	public inline function getChildIndex(child:ISprite)
	{
		var idx = -1;
		for (i in 0 ... children.length) if (children[i] == child) {
			idx = i;
			break;
		}
		Assert.that(idx != -1, "argument not a child of this sprite");
		return idx;
	}
	
	
	public inline function swapChildren(a:Sprite, b:Sprite) : Void
	{
		var ai = getChildIndex(a);
		var bi = getChildIndex(b);
		children[ai] = b;
		children[bi] = a;
	}
	
	
	public inline function dispose() : Void
	{
		parent = null;
		children = null;
	}
	
	
	public function startDrag(?lockCenter:Bool, ?bounds:Rectangle) : Void;
	public function stopDrag () : Void;
	
	private inline function getX ()					{ return x; }
	private inline function getY ()					{ return y; }
	private inline function getWidth ()				{ return width; }
	private inline function getHeight ()			{ return height; }
	private inline function setX (v)				{ return x = v; }
	private inline function setY (v)				{ return y = v; }
	private inline function setWidth (v)			{ return width = v; }
	private inline function setHeight (v)			{ return height = v; }
	
	private inline function getVisibility()			{ return _visible; }
	private inline function setVisibility(v:Bool)	{ return _visible = v; }
	private inline function getNumChildren()		{ return children.length; }
}
#end
