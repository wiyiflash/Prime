﻿/*
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
package primevc.gui.layout;
 import primevc.core.collections.ArrayList;
 import primevc.core.collections.IEditableList;
 import primevc.core.collections.ListChange;
 import primevc.core.geom.BindablePoint;
 import primevc.core.geom.Box;
 import primevc.core.geom.IntPoint;
 import primevc.core.traits.IInvalidatable;
 import primevc.core.validators.PercentIntRangeValidator;
 import primevc.gui.layout.algorithms.ILayoutAlgorithm;
 import primevc.gui.states.ValidateStates;
 import primevc.types.Number;
 import primevc.utils.FastArray;
 import primevc.utils.NumberUtil;
  using primevc.utils.Bind;
  using primevc.utils.BitUtil;
  using primevc.utils.NumberUtil;
  using primevc.utils.TypeUtil;


private typedef Flags = LayoutFlags;


/**
 * @since	Mar 20, 2010
 * @author	Ruben Weijers
 */
class LayoutContainer extends AdvancedLayoutClient, implements ILayoutContainer, implements IScrollableLayout
{
	public static inline var EMPTY_BOX : Box = new Box(0,0);
	
	
	public var algorithm			(default, setAlgorithm)			: ILayoutAlgorithm;
	public var children				(default, null)					: IEditableList<LayoutClient>;
	
	public var childWidth			(default, setChildWidth)		: Int;
	public var childHeight			(default, setChildHeight)		: Int;
	
	public var scrollPos			(default, null)					: BindablePoint;
	public var scrollableWidth		(getScrollableWidth, never)		: Int;
	public var scrollableHeight		(getScrollableHeight, never)	: Int;
	public var minScrollXPos		(default, setMinScrollXPos)		: Int;
	public var minScrollYPos		(default, setMinScrollYPos)		: Int;
	
	
	
	
	public function new (newWidth = primevc.types.Number.INT_NOT_SET, newHeight = primevc.types.Number.INT_NOT_SET)
	{
		super(newWidth, newHeight);
		
		(untyped this).padding		= EMPTY_BOX;
		(untyped this).margin		= EMPTY_BOX;
		(untyped this).childWidth	= Number.INT_NOT_SET;
		(untyped this).childHeight	= Number.INT_NOT_SET;
		
		children		= new ArrayList<LayoutClient>();
		scrollPos		= new BindablePoint();
		minScrollXPos	= minScrollYPos = 0;
		
		childrenChangeHandler.on( children.change, this );
	}
	
	
	override public function dispose ()
	{
		super.dispose();
		if (algorithm != null) {
			algorithm.dispose();
			(untyped this).algorithm = null;
		}
		scrollPos.dispose();
		children.dispose();
		children	= null;
		scrollPos	= null;
	}
	
	
	public inline function attach (target:LayoutClient, depth:Int = -1) : LayoutContainer
	{
		children.add( target, depth );
		return this;
	}
	
	
	
	//
	// LAYOUT METHODS
	//
	
	override public function invalidateCall ( childChanges:Int, sender:IInvalidatable ) : Void
	{
		if (!sender.is(LayoutClient))
			return super.invalidateCall( childChanges, sender );
		
		var isInvalid = false;
		if (isInvalid = childChanges.has(Flags.INCLUDE))
			invalidate( Flags.LIST );
		
		if (isInvalid || algorithm == null || algorithm.isInvalid(childChanges))
		{
			var child = sender.as(LayoutClient);
			invalidate( Flags.CHILDREN_INVALIDATED );
			
			if (!child.isValidating())
				child.state.current = ValidateStates.parent_invalidated;
		}
		return;
	}
	
	
	
	private inline function checkIfChildGetsPercentageWidth (child:LayoutClient, widthToUse:Int) : Bool
	{
		return (
					changes.has( Flags.WIDTH | Flags.LIST ) || child.changes.has( Flags.PERCENT_WIDTH ) //|| child.width.notSet()
					||	( child.is(IAdvancedLayoutClient) && child.as(IAdvancedLayoutClient).explicitWidth.notSet() )
				)
				&& child.percentWidth.isSet()
				&& child.percentWidth > 0
				&& widthToUse > 0;
	}
	
	
	private inline function checkIfChildGetsPercentageHeight (child:LayoutClient, heightToUse:Int) : Bool
	{
		return (
						changes.has( Flags.HEIGHT | Flags.LIST ) || child.changes.has( Flags.PERCENT_HEIGHT ) //|| child.height.notSet()
						||	( child.is(IAdvancedLayoutClient) && child.as(IAdvancedLayoutClient).explicitHeight.notSet() )
				)
				&& child.percentHeight.isSet()
				&& child.percentHeight > 0
				&& heightToUse > 0;
	}
	
	
	
	override public function validateHorizontal ()
	{
		super.validateHorizontal();
		if (changes.hasNone( Flags.HORIZONTAL_INVALID ))
			return;
		
		var fillingChildren	= FastArrayUtil.create();
		var childrenWidth	= 0;
		
		if (algorithm != null)
			algorithm.prepareValidate();
		
		var childrenLength = children.length;
		for (i in 0...childrenLength)
		{
			Assert.equal(childrenLength, children.length); // Can the length of the children change during the loop?
			
			var child = children.getItemAt(i);
			if (!child.includeInLayout)
				continue;
			
			if (changes.has(Flags.WIDTH | Flags.LIST) && child.widthValidator != null && child.widthValidator.is( PercentIntRangeValidator ) && width.isSet())
				child.widthValidator.as( PercentIntRangeValidator ).calculateValues( width );
			
			if (child.percentWidth == Flags.FILL)
			{
				fillingChildren.push( child );
				child.width = Number.INT_NOT_SET;
			}
			
			//measure children with explicitWidth and no percentage size
			else if (checkIfChildGetsPercentageWidth(child, width)) {
				child.outerBounds.width = (width * child.percentWidth).roundFloat();
#if debug		Assert.that( (width * child.percentWidth) > 0, "invalid width: "+(width * child.percentWidth)+"; groupWidth: "+width+"; child.percentWidth: "+child.percentWidth ); #end
			}
			
			
			//measure children
			if (child.percentWidth != Flags.FILL)
			{
				child.validateHorizontal();
				childrenWidth += child.outerBounds.width;
			}
		}
		
		if (width.isSet() && fillingChildren.length > 0 && (width - childrenWidth) > 0)
		{
			var sizePerChild = ( width - childrenWidth ).divFloor( fillingChildren.length );
			
			for (i in 0...fillingChildren.length)
			{
				var child = fillingChildren[ i ];
				child.outerBounds.width = sizePerChild;
				child.validateHorizontal();
			}
		}
		
		if (algorithm != null)
			algorithm.validateHorizontal();
		
		super.validateHorizontal();
	}
	
	
	
	
	override public function validateVertical ()
	{
		super.validateVertical();
		if (changes.hasNone( Flags.VERTICAL_INVALID ))
			return;
		
		var fillingChildren	= FastArrayUtil.create();
		var childrenHeight	= 0;
		
		if (algorithm != null)
			algorithm.prepareValidate();
		
		
		for (i in 0...children.length)
		{
			var child = children.getItemAt(i);
			if (!child.includeInLayout)
				continue;
			
			if (changes.has(Flags.HEIGHT | Flags.LIST) && child.heightValidator != null && child.heightValidator.is( PercentIntRangeValidator ) && height.isSet())
				child.heightValidator.as( PercentIntRangeValidator ).calculateValues( height );
			
			if (child.percentHeight == Flags.FILL)
			{
				fillingChildren.push( child );
				child.height = Number.INT_NOT_SET;
			}
			
			else if (checkIfChildGetsPercentageHeight(child, height)) {
				child.outerBounds.height = (height * child.percentHeight).roundFloat();
#if debug		Assert.that( child.outerBounds.height > 0, "invalid height: "+child.outerBounds.height+"; groupHeight: "+height+"; child.percentHeight: "+child.percentHeight ); #end
			}
			
			//measure children
			if (child.percentHeight != Flags.FILL) {
				if (child.changes > 0)
					child.validateVertical();
				
				childrenHeight += child.outerBounds.height;
			}
		}
		
		
		
		if (height.isSet() && fillingChildren.length > 0 && (height - childrenHeight) > 0)
		{
			var sizePerChild = ( height - childrenHeight ).divFloor( fillingChildren.length );
			for (i in 0...fillingChildren.length)
			{
				var child = fillingChildren[ i ];
				child.outerBounds.height = sizePerChild;
				child.validateVertical();
			}
		}
		
		
		if (algorithm != null)
			algorithm.validateVertical();
		
		super.validateVertical();
	}
	
	
	
	
	override public function validated ()
	{
		if (changes == 0 || !isValidating())
			return;
		
		if (!isVisible())
			return super.validated();
		
		if (isInvalidated())
			validate();
		
		if (changes.has( Flags.SIZE_PROPERTIES ))
			validateScrollPosition( scrollPos );
		
		if (algorithm != null) {
			algorithm.prepareValidate();
			
			if (height.isSet() && width.isSet())
				algorithm.apply();
		}
		
		var i = 0;
		while (i < children.length)		// use while loop instead of for loop since children can be removed during validation (== errors with a for loop)
		{
			var child = children.getItemAt(i);
			if (child.includeInLayout)
				child.validated();
			
			i++;
		}
		
		// It's important that super.validated get's called after the children are validated.
		// The process of validating children could otherwise invalidate the object again
		// since the x&y of the children can change when they are validated.
		return super.validated();
	}
	
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	
	private inline function setAlgorithm (v:ILayoutAlgorithm)
	{
		if (v != algorithm)
		{
			if (algorithm != null) {
				if (algorithm.group == this)
					algorithm.group = null;
				
				algorithm.algorithmChanged.unbind(this);
			}
			
			algorithm = v;
			
			if (algorithm != null) {
				algorithm.group = this;
				algorithmChangedHandler.on( algorithm.algorithmChanged, this );
			}
			
			invalidate( Flags.ALGORITHM );
		}
		return v;
	}


	private inline function setChildWidth (v)
	{
		if (v != childWidth)
		{
			childWidth = v;
			invalidate( Flags.CHILD_WIDTH | Flags.CHILDREN_INVALIDATED );
		}
		return v;
	}


	private inline function setChildHeight (v)
	{
		if (v != childHeight)
		{
			childHeight = v;
			invalidate( Flags.CHILD_HEIGHT | Flags.CHILDREN_INVALIDATED );
		}
		return v;
	}
	
	
	override private function setPadding (v:Box)
	{	
		if (v == null)
			v = EMPTY_BOX;
		
		return super.setPadding(v);
	}
	
	
	override private function setMargin (v:Box)
	{	
		if (v == null)
			v = EMPTY_BOX;
		
		return super.setMargin(v);
	}
	
	
	
	//
	// ISCROLLABLE LAYOUT IMPLEMENTATION
	//
	
	public inline function horScrollable ()							{ return width.isSet()  && measuredWidth.isSet()  && measuredWidth  > width; }
	public inline function verScrollable ()							{ return height.isSet() && measuredHeight.isSet() && measuredHeight > height; }
	public inline function getScrollableWidth ()					{ return measuredWidth  - width; }
	public inline function getScrollableHeight ()					{ return measuredHeight - height; }
	
	private inline function setMinScrollXPos (v:Int)				{ return minScrollXPos = v <= 0 ? v : 0; }
	private inline function setMinScrollYPos (v:Int)				{ return minScrollYPos = v <= 0 ? v : 0; }
	
	public inline function validateScrollPosition (pos:IntPoint)
	{
		pos.x = horScrollable() ? pos.x.within( 0, scrollableWidth ) : 0;
		pos.y = verScrollable() ? pos.y.within( 0, scrollableHeight ) : 0;
		return pos;
	}
	
	
	public function scrollTo (child:ILayoutClient)
	{
		var c = child.outerBounds;
		if (horScrollable())
		{
			var left	= scrollPos.x;
			var right	= left + width;
			
			if		(c.left < left)			scrollPos.x = c.left;
			else if (c.right > right)		scrollPos.x = c.right - width;
		}
		if (verScrollable())
		{
			var top		= scrollPos.y;
			var bottom	= top + height;
			
			if		(c.top < top)			scrollPos.y = c.top;
			else if (c.bottom > bottom)		scrollPos.y = c.bottom - height;
			
		}
	}
	
	
	
	//
	// EVENT HANDLERS
	//
	
	private function childrenChangeHandler ( change:ListChange <LayoutClient> ) : Void
	{
	//	trace(this+".childrenChangeHandler "+change);
		var shouldInvalidate = true;
		
		switch (change)
		{
			case added( child, newPos ):
				child.parent = this;
				//check first if the bound properties are zero. If they are not, they can have been set by a tile-container
				if (child.outerBounds.left == 0)	child.outerBounds.left	= padding.left;
				if (child.outerBounds.top == 0)		child.outerBounds.top	= padding.top;
				child.listeners.add(this);
				shouldInvalidate = child.includeInLayout;
			
			
			case removed( child, oldPos ):
				child.parent = null;
				child.listeners.remove(this);
				shouldInvalidate = child.includeInLayout;
				
				//reset boundary properties without validating
				child.outerBounds.left	= 0;
				child.outerBounds.top	= 0;
				child.changes			= 0;
			
			default:
		}
		
		if (shouldInvalidate)
			invalidate( Flags.LIST );
	}
	
	
	private function algorithmChangedHandler ()	{ invalidate( Flags.ALGORITHM ); }
}