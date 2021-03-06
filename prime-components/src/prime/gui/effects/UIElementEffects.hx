

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
package prime.gui.effects;
 import prime.gui.core.IUIElement;
 import prime.gui.effects.effectInstances.IEffectInstance;
// import prime.types.Number;
  using prime.utils.Bind;
  using prime.utils.BitUtil;
  using prime.utils.IfUtil;
  using prime.fsm.SimpleStateMachine;


private typedef EffectInstanceType 	= IEffectInstance < Dynamic, Dynamic >;
private typedef Flags 				= prime.gui.effects.EffectFlags;


/**
 * Container with empty slots for effects that will be bound to events that
 * happen in an IUIElement.
 * 
 * @author Ruben Weijers
 * @creation-date Sep 01, 2010
 */
class UIElementEffects implements prime.core.traits.IDisposable
{
	public  var target		(default, null)			: IUIElement;
	/**
	 * Flags of all effects that are set
	 */
	private var props 		: Int;
	/**
	 * Enable/disable all effects for the current target
	 * @default true
	 */
	public  var enabled 	: Bool;

	
	//
	// SLOTS
	//
	
	/**
	 * Effect that is performed when the coordinates of the targets 
	 * layoutobject have changed.
	 */
	public var move			(default, set_move)			: EffectInstanceType;
	
	/**
	 * Effect that is performed when the size of targets layoutobject is 
	 * changed.
	 */
	public var resize		(default, set_resize)		: EffectInstanceType;
	
	/**
	 * Effect that is performed when the 'rotate' method of the target is called.
	 */
	public var rotate		(default, set_rotate)		: EffectInstanceType;
	
	/**
	 * Effect that is performed when the 'scale' method of the target is called.
	 */
	public var scale		(default, set_scale)		: EffectInstanceType;
	
	/**
	 * Effect that is performed when the 'show' method of the target is called.
	 * This effect will stop the 'hide' effect if it's playing.
	 */
	public var show			(default, set_show)			: EffectInstanceType;
	/**
	 * Effect that is performed when the 'hide' method of the target is called.
	 * This effect will stop the 'show' effect if it's playing.
	 */
	public var hide			(default, set_hide)			: EffectInstanceType;
	
	
	public function new ( target:IUIElement )
	{
		this.target = target;
		enabled 	= true;
		props 		= 0;
	}
	
	
	public function dispose ()
	{
		target	= null;
		props 	= 0;

		if (move  .notNull())	{ move 	.dispose();	move 	= null; }
		if (resize.notNull())	{ resize.dispose(); resize 	= null; }
		if (rotate.notNull())	{ rotate.dispose(); rotate 	= null; }
		if (scale .notNull())	{ scale .dispose();	scale 	= null; }
		if (show  .notNull())	{ show  .dispose();	show 	= null; }
		if (hide  .notNull())	{ hide  .dispose();	hide 	= null; }
	}


	//
	// FLAG METHODS
	//

	private inline function mark (prop:Int, isSet:Bool)	: Void	{ props = isSet ? props.set( prop ) : props.unset( prop ); }
	public  inline function has  (prop:Int)				: Bool	{ return  enabled && props.has(prop); }
	public  inline function doesntHave (prop:Int)		: Bool	{ return !enabled || props.hasNone( prop ); }

	public  inline function enable () 							{ enabled = true; }
	public  inline function disable () 							{ enabled = false; }
	
	
	
	
	//
	// EFFECT HANDLERS
	//
	
	
	public function playMove ()
	{
#if !CSSParser
		
		if (enabled && move.notNull())
		{
		//	move.setValues( EffectProperties.position( Number.INT_NOT_SET, Number.INT_NOT_SET, newX, newY ) );
			move.play();
		}
		else
		{
			var newX = target.layout.getHorPosition();
			var newY = target.layout.getVerPosition();
			target.x = newX;
			target.y = newY;
			target.rect.move( newX, newY );
		}
#end
	}
	
	
	public function playResize ()
	{
#if !CSSParser
		var bounds = target.layout.innerBounds;
		
		if (enabled && resize.notNull())
		{
			resize.setValues( EffectProperties.size( target.rect.width, target.rect.height, bounds.width, bounds.height ) );
			resize.play();
		}
		else
			target.rect.resize( bounds.width, bounds.height );
#end
	}
	
	
	public #if !noinline inline #end function playRotate ( endV:Float )
	{
#if !CSSParser
		if (enabled && rotate.notNull())
		{
			rotate.setValues( EffectProperties.rotation( target.rotation, endV ) );
			rotate.play();
		}
		else
		{
			target.rotation = endV;
		}
#end
	}
	
	
	public #if !noinline inline #end function playScale ( endSx:Float, endSy:Float )
	{
#if !CSSParser
		if (enabled && scale.notNull())
		{
			scale.setValues( EffectProperties.scale( target.scaleX, target.scaleY, endSx, endSy ) );
			scale.play();
		}
		else
		{
			target.scaleX = endSx;
			target.scaleY = endSy;
		}
#end
	}
	
	
	public function playShow ()
	{
#if !CSSParser
		if (enabled && show.notNull())
		{
			if (hide.notNull()) {
				hide.ended.unbind(target);
				if 		(hide.isWaiting())	hide.stop();
				else if (hide.isPlaying())	hide.stop();
				else						target.visible = false;
				
				if (show == hide)			show.isReverted = show.effect.isReverted;
			}
			else							target.visible = false;
			
			if (target.layout.isInvalidated())
				show.play.bind().onceOnEntering( target.layout.state, validated, this );
			else
				show.play();
		} else {
			target.visible = true;
		}
#end
	}
	
	
	public function playHide ()
	{
#if !CSSParser
		if (enabled && hide.notNull())
		{
			if (show.notNull()) {
				if 		(show.isWaiting())	show.stop();
				else if (show.isPlaying())	show.stop();
				else						target.layout.state.change.unbind(this);

				if (show == hide)			hide.isReverted = !hide.effect.isReverted;
			}
			hide.play();
		} else {
			target.visible = false;
		}
#end
	}
	
	
	public #if !noinline inline #end function isPlayingHide ()	{ return hide.notNull() && (hide.isPlaying() || hide.isWaiting()) && (show != hide || hide.isReverted != hide.effect.isReverted); }
	public #if !noinline inline #end function isPlayingShow ()	{ return show.notNull() && (show.isPlaying() || show.isWaiting()) && (show != hide || show.isReverted == show.effect.isReverted); }
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	
	private function set_move (v)
	{
		if (v != move)
		{
			if (move.notNull())
				move.dispose();
			
			move = v;
			mark(Flags.MOVE, v.notNull());
			
		//	if (move.notNull())
		//		playMove.on( target.layout.events.posChanged, this );
		}
		return v;
	}
	
	
	private function set_resize (v)
	{
		if (v != resize)
		{
			if (resize.notNull())
				resize.dispose();
			
			resize = v;
			mark(Flags.RESIZE, v.notNull());
		//	if (resize.notNull())
		//		playResize.on( target.layout.events.sizeChanged, this );
		}
		return v;
	}
	
	
	private function set_rotate (v)
	{
		if (v != rotate)
		{
			if (rotate.notNull())
				rotate.dispose();
			
			rotate = v;
			mark(Flags.ROTATE, v.notNull());
		}
		return v;
	}
	
	
	private function set_scale (v)
	{
		if (v != scale)
		{
			if (scale.notNull())
				scale.dispose();
			
			scale = v;
			mark(Flags.SCALE, v.notNull());
		}
		return v;
	}
	
	
	private function set_show (v)
	{
		if (v != show)
		{
			if (show.notNull())
				show.dispose();
			
			show = v;
			mark(Flags.SHOW, v.notNull());
		}
		return v;
	}
	
	
	private function set_hide (v)
	{
		if (v != hide)
		{
			if (hide.notNull())
				hide.dispose();
			
			hide = v;
			mark(Flags.HIDE, v.notNull());
		}
		return v;
	}
}