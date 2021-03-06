

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
package prime.gui.managers;
 import prime.signals.Wire;
 import prime.bindable.Bindable;
 import prime.gui.components.Label;
 import prime.gui.core.UIComponent;
 import prime.gui.core.UIWindow;
  using prime.utils.Bind;
  using Std;


/**
 * Class for centralizing the use of tooltips.
 * 
 * @author Ruben Weijers
 * @creation-date Jan 24, 2011
 */
class ToolTipManager implements prime.core.traits.IDisposable
{
	private var toolTip 	: Label;
	private var window		: UIWindow;
	
	private var lastLabel	: Bindable<String>;
	private var lastObj		: UIComponent;
	
	private var mouseMove	: Wire<Dynamic>;
	
	
	public function new (window:UIWindow)
	{
		toolTip		= new Label("toolTip");
		this.window	= window;
		
		mouseMove	= updatePosition.on( window.mouse.events.move, this );
		mouseMove.disable();
		
		toolTip.enabled.value = false;
	}
	
	
	public function dispose ()
	{
		hide();
		removeListeners();
		mouseMove.dispose();
		toolTip.dispose();
		
		mouseMove	= null;
		toolTip		= null;
		window		= null;
	}
	
	
	/**
	 * Method will enable the tooltip for the given obj with the given label.
	 * When the tooltip is enabled, it will also start following the mouse.
	 */
	public function show (obj:UIComponent, label:Bindable<String>)
	{
		removeListeners();

#if debug
		Assert.isNotNull(obj, "Target object can't be null with label "+label);
		Assert.isNotNull(label, "Tooltip-label can't be null for object "+obj);
#end
		
		if (isLabelEmpty(label.value))
		{
			hide();
			showAfterChange.onceOn( label.change, this );
		}
		else
		{
			//enable mouse-follower
			mouseMove.enable();
		
			//give label the correct text
		//	toolTip.data.bind( label );		//don't bind.. if the change event is dispatched manually (without calling Bindable.setValue), the tooltip won't update	
			toolTip.data.value = label.value;
			updateToolTip.on( label.change, this );
			
			//move tooltip to right position
			if (!isVisible())
				toolTip.attachDisplayTo(window);

			updatePosition();
		}
		
		lastObj		= obj;
		lastLabel	= label;
		targetRemovedHandler.on( obj.displayEvents.removedFromStage, this );
	}
	
	
	
	/**
	 * method will hide the tooltip. If 'obj' is given, the method will only
	 * hide the tooltip if 'obj' is the current hovered object.
	 */
	public function hide (?obj:UIComponent)
	{
		if (obj != null && obj != lastObj)
			return;
		
		removeListeners();
		mouseMove.disable();
		
		lastObj		= null;
		lastLabel	= null;
		
		if (isVisible())
			toolTip.detachDisplay();
	}
	
	
	private inline function isLabelEmpty (label:String)
	{
		return label == "" || label == null;
	}
	
	
	/**
	 * Method is called when the tooltip of the lastObj is changed and the 
	 * previous value of the tooltip was empty
	 */
	private function showAfterChange ()
	{
		show(lastObj, lastLabel);
	}
	
	
	private inline function removeListeners ()
	{
		if (lastObj != null)
			lastObj.displayEvents.removedFromStage.unbind( this );
		
		if (lastLabel != null) {
		//	toolTip.data.unbind( lastLabel );
			lastLabel.change.unbind(this);
		}
	}
	
	
	
	public #if !noinline inline #end function isVisible ()
	{
		return toolTip.window != null;
	}
	
	
	//
	// EVENTHANDLERS
	//
	
	private function updatePosition ()
	{
		// The first time the Label is initialized,
		//  text height is calculated, but graphics is not drawn yet:
		//  toolTip height and width are just the size of the textfield.

		// Use layout outerBounds for correct dimensions:
		var toolTip = this.toolTip;
		Assert.that(toolTip.field.isOnStage());
		Assert.that(toolTip.field.text != "");
		Assert.that(toolTip.field.textStyle != null);
		Assert.that(toolTip.field.height > 0);

		var width   = toolTip.layout.outerBounds.width;
		var height  = toolTip.layout.outerBounds.height;
		var newX	= window.mouse.x + 5;
		var newY	= window.mouse.y - 5 + height;
		var bounds	= window.layout.innerBounds;
		
		if      ( newX < bounds.left)             newX = 0;
		else if ((newX + width)  > bounds.right)  newX = bounds.right - width;
		if      ( newY < bounds.top)              newY = 0;
		else if ((newY + height) > bounds.bottom) newY = bounds.bottom - height;
		
		toolTip.x = newX;
		toolTip.y = newY; // - toolTip.height - 5;
		toolTip.layout.x = toolTip.x.int();
		toolTip.layout.y = toolTip.y.int(); // - toolTip.height - 5;
	}
	
	
	private function targetRemovedHandler ()
	{
		hide(lastObj);
		toolTip.x = toolTip.y = -400;
	}
	
	
	private function updateToolTip (newVal:String, oldVal:String)
	{
		toolTip.data.value = newVal;
	}
}