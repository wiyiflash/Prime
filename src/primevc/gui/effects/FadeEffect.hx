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
package primevc.gui.effects;
 import primevc.gui.display.IDisplayObject;	
 import primevc.types.Number;
  using primevc.utils.NumberUtil;
#if CSSParser
  using primevc.types.Reference;
#end


/**
 * Effect to fade a DisplayObject from one alpha value to another.
 * 
 * @author Ruben Weijers
 * @creation-date Aug 31, 2010
 */
class FadeEffect extends Effect < IDisplayObject, FadeEffect >
{
	/**
	 * Explicit start alpha value. If this value is not set, the effect will 
	 * use the current alpha of the displayobject.
	 * @default		Number.FLOAT_NOT_SET
	 */
	public var startValue	: Float;
	/**
	 * Explicit alpha value of the animation at the end.
	 * @default		Number.FLOAT_NOT_SET
	 */
	public var endValue		: Float;
	
	
	public function new( duration:Int = 350, delay:Int = 0, easing:Easing = null, startValue:Float = Number.INT_NOT_SET, endValue:Float = Number.INT_NOT_SET )
	{
		super( duration, delay, easing );
		autoHideFilters	= false;
		this.startValue	= startValue == Number.INT_NOT_SET ? Number.FLOAT_NOT_SET : startValue;
		this.endValue	= endValue == Number.INT_NOT_SET ? Number.FLOAT_NOT_SET : endValue;
	}
	
	
	override public function clone ()
	{
		return cast new FadeEffect( duration, duration, easing, startValue, endValue );
	}
	
	
#if !CSSParser
	override public function createEffectInstance (target)
	{
		return cast new primevc.gui.effects.effectInstances.FadeEffectInstance(target, this);
	}
#end


	override public function setValues ( v:EffectProperties ) 
	{
		switch (v)
		{
			case alpha(from, to):
				startValue	= from;
				endValue	= to;
			default:
				return;
		}
	}
	
	
#if CSSParser
	override public function toCSS (prefix:String = "") : String
	{
		var props = [];
		
		if (duration.isSet())		props.push( duration + "ms" );
		if (delay.isSet())			props.push( delay + "ms" );
		if (easing != null)			props.push( easing.toCSS() );
		if (startValue.isSet())		props.push( (startValue * 100) + "%" );
		if (endValue.isSet())		props.push( (endValue * 100) + "%" );
		
		return "fade " + props.join(" ");
	}
	
	
	override public function toCode (code:primevc.tools.generator.ICodeGenerator) : Void
	{
		if (!isEmpty())
			code.construct( this, [ duration, delay, easing, startValue, endValue ] );
	}
#end
}