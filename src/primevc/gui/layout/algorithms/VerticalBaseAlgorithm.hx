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
 *  Ruben Weijers	<ruben @ onlinetouch.nl>
 */
package primevc.gui.layout.algorithms;
#if neko
 import primevc.tools.generator.ICodeGenerator;
#end
 import primevc.core.geom.space.Horizontal;
 import primevc.core.geom.space.Vertical;
 import primevc.gui.layout.algorithms.LayoutAlgorithmBase;
 import primevc.gui.layout.AdvancedLayoutClient;
 import primevc.gui.layout.LayoutFlags;
 import primevc.utils.IntMath;
  using primevc.utils.BitUtil;
  using primevc.utils.NumberUtil;
  using primevc.utils.TypeUtil;
  using Std;



/**
 * Base class for vertical layout algorithms
 * 
 * @author Ruben Weijers
 * @creation-date Sep 03, 2010
 */
class VerticalBaseAlgorithm extends LayoutAlgorithmBase
{
	public var direction			(default, setDirection)		: Vertical;
	
	/**
	 * Property indicating if and how the children of the group should be 
	 * positioned horizontally.
	 * The algorithm won't touch the x position of the children when this 
	 * property is null.
	 * 
	 * @default null
	 */
	public var horizontal			(default, setHorizontal)	: Horizontal;
	
	
	public function new ( ?direction:Vertical, ?horizontal:Horizontal = null )
	{
		super();
		this.direction	= direction == null ? Vertical.top : direction;
		this.horizontal	= horizontal;
	}
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	/**
	 * Setter for direction property. Method will change the apply method based
	 * on the given direction. After that it will dispatch a 'directionChanged'
	 * signal.
	 */
	private inline function setDirection (v:Vertical) : Vertical
	{
		if (v != direction) {
			direction = v;
			algorithmChanged.send();
		}
		return v;
	}


	private inline function setHorizontal (v:Horizontal) : Horizontal
	{
		if (v != horizontal) {
			horizontal = v;
			algorithmChanged.send();
		}
		return v;
	}
	
	
	
	//
	// LAYOUT
	//

	/**
	 * Method indicating if the size is invalidated or not.
	 */
	public inline function isInvalid (changes:Int)	: Bool
	{
		return (changes.has( LayoutFlags.HEIGHT ) && group.childHeight.notSet()) || ( horizontal != null && changes.has( LayoutFlags.WIDTH ) );
	}


	public inline function validateHorizontal ()
	{
		var width:Int = group.childWidth;

		if (group.childWidth.notSet())
		{
			width = 0;
			for (child in group.children)
				if (child.includeInLayout && child.bounds.width > width)
					width = child.bounds.width;
		}
		setGroupWidth(width);
	}


	public function apply ()
	{
		switch (horizontal) {
			case Horizontal.left:	applyHorizontalLeft();
			case Horizontal.center:	applyHorizontalCenter();
			case Horizontal.right:	applyHorizontalRight();
		}
		validatePrepared = false;
	}
	


	private inline function applyHorizontalLeft ()
	{
		if (group.children.length > 0)
		{
			for (child in group.children) {
				if (!child.includeInLayout)
					continue;

				child.bounds.left = 0;
			}
		}
	}
	
	
	private inline function applyHorizontalCenter ()
	{
		if (group.children.length > 0)
		{
			if (group.childWidth.notSet())
			{	
				for (child in group.children) {
					if (!child.includeInLayout)
						continue;
					
					child.bounds.left = ( (group.bounds.width - child.bounds.width) * .5 ).int();
				}
			}
			else
			{
				var childX = ( (group.bounds.width - group.childWidth) * .5 ).int();
				for (child in group.children)
					if (child.includeInLayout)
						child.bounds.left = childX;
			}
		}
	}
	
	
	private inline function applyHorizontalRight ()
	{
		if (group.children.length > 0)
		{
			if (group.childWidth.notSet())
			{	
				for (child in group.children) {
					if (!child.includeInLayout)
						continue;
					
					child.bounds.left = group.bounds.width - child.bounds.width;
				}
			}
			else
			{
				var childX = group.bounds.width - group.childWidth;
				for (child in group.children)
					if (child.includeInLayout)
						child.bounds.left = childX;
			}
		}
	}




	//
	// START VALUES
	//

	private inline function getTopStartValue ()		: Int
	{
		var top:Int = 0;
		if (group.padding != null)
			top = group.padding.top;

		return top;
	}


	private inline function getBottomStartValue ()	: Int	{
		var h:Int = group.height;
		if (group.is(AdvancedLayoutClient))
			h = IntMath.max(group.as(AdvancedLayoutClient).measuredHeight, h);

		if (group.padding != null)
			h += group.padding.top; // + group.padding.bottom;

		return h;
	}
	
	
#if neko
	override public function toCode (code:ICodeGenerator)
	{
		code.construct( this, [ direction, horizontal ] );
	}
#end
}