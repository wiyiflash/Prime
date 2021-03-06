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
 *  Ruben Weijers	<ruben @ rubenw.nl>
 */
package prime.layout;
 import prime.signals.Signal0;
 import prime.types.Number;
  using prime.utils.NumberUtil;


/**
 * The relative layout class describes the wanted settings of a layout client
 * in relation with the layout-parent.
 * 
 * In a relative layout it's possible to set the prop 
 * 		horizontalCenter = 0
 * to make sure the layout is always centered in relation with its layout
 * parent.
 * 
 * The parent can choose to apply or ignore the relative properties depending 
 * on the layout-algorithm that is uses. When the algorithm is positionating 
 * every layout-child next to eachother, the horizontalCenter will be ignored
 * for example.
 * 
 * This class is not meant for standalone use but should always be placed in
 * the LayoutClient.relative property.
 * 
 * @see		prime.layout.LayoutClient
 * 
 * @creation-date	Jun 22, 2010
 * @author			Ruben Weijers
 */
class RelativeLayout 
				implements prime.core.geom.IBox
				implements prime.core.traits.IDisposable	
#if CSSParser	implements prime.tools.generator.ICSSFormattable
				implements prime.tools.generator.ICodeFormattable		#end
{
	
#if CSSParser
	public var _oid					(default, null)	: Int;
#end
	
	/**
	 * Flag indicating if the relative-properties are enabled or disabled.
	 * When the value is false, it will still be possible to change the
	 * values but there won't be fired a change signal to let the layout-
	 * client now that it's changed.
	 * 
	 * @default	true
	 */
	public var enabled				: Bool;
	
	/**
	 * Signal to notify listeners that a property of the relative layout is 
	 * changed.
	 */
	public var change				(default, null) : Signal0;
	
	
	//
	// CENTERING PROPERTIES
	//
	
	/**
	 * Defines at what horizontal-location the center of the layoutclient 
	 * should be placed in the center of the parent-layout.
	 * 
	 * @example
	 * 		layout.relative.hCenter = 10;
	 * 
	 * Will make the center of the layout be placed at 10px right from the 
	 * center of the parent.
	 * 
	 * @default		Number.INT_NOT_SET
	 */
	public var hCenter		(get_hCenter, set_hCenter)	: Int; var _hCenter : Int;
	
	/**
	 * Defines at what vertical-location the center of the layoutclient 
	 * should be placed in the center of the parent-layout.
	 * 
	 * @example
	 * 		layout.relative.vCenter = 10;
	 * 
	 * Will make the center of the layout be placed at 10px below the 
	 * center of the parent.
	 * 
	 * @default		Number.INT_NOT_SET
	 */
	public var vCenter		(get_vCenter, set_vCenter)	: Int; var _vCenter : Int;
	
	
	
	
	//
	// BOX PROPERTIES
	//
	
	/**
	 * Property defines the relative left position in relation with the parent.
	 * @example		
	 * 		client.relative.left = 10;	//left side of client will be 10px from the left side of the parent
	 * @default		Number.INT_NOT_SET
	 */
	public var left   (get_left, set_left)     : Int; var _left : Int;
	/**
	 * Property defines the relative right position in relation with the parent.
	 * @see			prime.layout.RelativeLayout#left
	 * @default		Number.INT_NOT_SET
	 */
	public var right  (get_right, set_right)   : Int; var _right : Int;
	/**
	 * Property defines the relative top position in relation with the parent.
	 * @see			prime.layout.RelativeLayout#left
	 * @default		Number.INT_NOT_SET
	 */
	public var top    (get_top, set_top)       : Int; var _top : Int;
	/**
	 * Property defines the relative bottom position in relation with the parent.
	 * @see			prime.layout.RelativeLayout#left
	 * @default		Number.INT_NOT_SET
	 */
	public var bottom (get_bottom, set_bottom) : Int; var _bottom : Int;
	
	
	public function new ( top:Int = Number.INT_NOT_SET, right:Int = Number.INT_NOT_SET, bottom:Int = Number.INT_NOT_SET, left:Int = Number.INT_NOT_SET, hCenter:Int = Number.INT_NOT_SET, vCenter:Int = Number.INT_NOT_SET )
	{
#if CSSParser
		this._oid		= prime.utils.ID.getNext();
#end
		this.enabled	= true;
		this.change		= new Signal0();
		this.hCenter	= hCenter;
		this.vCenter	= vCenter;
		this.top		= top;
		this.right		= right;
		this.bottom		= bottom;
		this.left		= left;
	}
	
	
	public function dispose ()
	{
			change.dispose();
			change = null;
#if CSSParser
			_oid = 0;
#end
	}
	
	
	public #if !noinline inline #end function clone () : prime.core.geom.IBox
	{
		return new RelativeLayout( top, right, bottom, left, hCenter, vCenter );
	}


	public #if !noinline inline #end function center () : RelativeLayout
	{
		hCenter = vCenter = 0;
		return this;
	}
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	
	private inline function get_hCenter () { return _hCenter; }
	private inline function get_vCenter () { return _vCenter; }
	private inline function get_left    () { return _left;    }
	private inline function get_right   () { return _right;   }
	private inline function get_top     () { return _top;     }
	private inline function get_bottom  () { return _bottom;  }
	
	
	
	private function set_hCenter (v:Int) {
		//unset left and right
		if (v.isSet())
			_left = _right = Number.INT_NOT_SET;
		
		if (v != hCenter) {
			_hCenter = v;
			if (enabled)
				change.send();
		}
		return v;
	}
	
	private function set_vCenter (v:Int) {
		//unset top and bottom
		if (v.isSet())
			_top = _bottom = Number.INT_NOT_SET;
		
		if (v != vCenter) {
			_vCenter = v;
			if (enabled)
				change.send();
		}
		return v;
	}
	
	
	
	private inline function set_left (v:Int) {
		if (v.isSet())
			hCenter = Number.INT_NOT_SET;
		
		if (v != left) {
			_left = v;
			if (enabled)
				change.send();
		}
		return v;
	}
	
	private inline function set_right (v:Int) {
		if (v.isSet())
			hCenter = Number.INT_NOT_SET;
		
		if (v != right) {
			_right = v;
			if (enabled)
				change.send();
		}
		return v;
	}
	
	private inline function set_top (v:Int) {
		if (v.isSet())
			vCenter = Number.INT_NOT_SET;
		
		if (v != top) {
			_top = v;
			if (enabled)
				change.send();
		}
		return v;
	}
	
	private inline function set_bottom (v:Int) {
		if (v.isSet())
			vCenter = Number.INT_NOT_SET;
		
		if (v != bottom) {
			_bottom = v;
			if (enabled)
				change.send();
		}
		return v;
	}
	
	
#if debug
	public function toString () {
		return "RelativeLayout - t: "+top+"; r: "+right+"; b: "+bottom+"; l: "+left+"; hCenter: "+hCenter+"; vCenter: "+vCenter;
	}
#end
	

#if (CSSParser || debug)
	public function toCSS (prefix:String = "") : String
	{
		var css = [];
		var str = "";
		
		if (top.isSet())	css.push( top + "px" );
		else				css.push( "none" );
		if (right.isSet())	css.push( right + "px" );
		else				css.push( "none" );
		if (bottom.isSet())	css.push( bottom + "px" );
		else				css.push( "none" );
		if (left.isSet())	css.push( left + "px" );
		else				css.push( "none" );
		
		str = css.join(" ");
		css = [];
		
		if (hCenter.isSet())	css.push( hCenter + "px")
		else					css.push( "none");
		if (vCenter.isSet())	css.push( vCenter + "px")
		else					css.push( "none");
		
		if (str != "")
			str += ", ";
		
		str += css.join(" ");
		
		return str;
	}
	

	public function isEmpty () : Bool
	{
		return	top.notSet()
			&&	right.notSet()
			&&	bottom.notSet()
			&&	left.notSet()
			&&	hCenter.notSet()
			&&	vCenter.notSet();
	}
#end
#if CSSParser
	public function cleanUp () : Void {}
	
	public function toCode (code:prime.tools.generator.ICodeGenerator)
	{
		if (!isEmpty())
		{
			code.construct( this, [ top, right, bottom, left, hCenter, vCenter ] );
			if (!enabled)
				code.setProp( this, "enabled", enabled );
		}
	}
#end
}