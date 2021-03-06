

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
package prime.gui.behaviours.drag;
 import prime.signals.Wire;
 import prime.core.geom.Point;
 import prime.gui.core.IUIElement;
 import prime.gui.display.IDisplayObject;
 import prime.gui.events.MouseEvents;
 import prime.gui.traits.IDataDropTarget;
 import prime.gui.traits.IDropTarget;
  using prime.gui.utils.UIElementActions;
  using prime.utils.Bind;
  using prime.utils.IfUtil;
  using prime.utils.NumberUtil;
  using prime.utils.TypeUtil;
 

/**
 * Behaviour which will add drag-and-drop functionality to an object.
 * The given target object needs to implement the interface IDraggable.
 * 
 * To drop an item in a sprite, this sprite needs to implement the interface
 * IDropTarget.
 * 
 * @creation-date	Jul 8, 2010
 * @author			Ruben Weijers
 */
#if !dragEnabled

class DragDropBehaviour extends DragBehaviourBase
{}

#else

class DragDropBehaviour extends DragBehaviourBase
{
//	private var copyTarget			: Bool;
	private var moveBinding			: Wire < Dynamic >;
	private var effectsEnabledValue	: Bool;
	
	
/*	public function new (target, ?dragBounds, ?copyTarget = false)
	{
		super(target, dragBounds);
		this.copyTarget = copyTarget;
	}*/
	
	
	override private function init () : Void
	{
		super.init();
		moveBinding	= checkDropTarget.on( target.window.mouse.events.move, this );
		moveBinding.disable();
	}
	
	
	override private function reset () : Void
	{
		super.reset();
		if (moveBinding.notNull())
		{
			moveBinding.dispose();
			moveBinding	= null;
		}
	}
	
	
	override private function startDrag (mouseObj:MouseState) : Void
	{
		if (dragInfo.notNull())
		{
			cancelDrag(mouseObj);
			stopDrag(mouseObj);
		}
		
		if (target.window.isNull())
			return;
		
		dragInfo = target.createDragInfo();
		if (dragInfo.isNull())
			return;
		
		// disable effects
		if (target.is(IUIElement)) {
			var t = target.as(IUIElement);
			if (t.effects.notNull()) {
				effectsEnabledValue = t.effects.enabled;	//store original value to resore after the drop
				t.effects.enabled 	= false;
			}
		}

		var pos 		= dragInfo.displayCursor.position;
#if (flash9 || nme)
		pos				= target.container.as(IDisplayObject).localToGlobal( pos );
#end
		var item		= dragInfo.dragRenderer;
		item.visible 	= false;
		target.window.children.add(item);
	//	target.window.children.add( cast item );
		
		//start dragging and fire events
		super.startDrag(mouseObj);

		//move item to mouse location
		item.x = pos.x;
		item.y = pos.y;
		
		if (item.is(IUIElement))
			item.as(IUIElement).doMove(pos.x, pos.y);
		
		item.visible	= true;
		
		moveBinding.enable();
	}
	
	
	override private function stopDrag (mouseObj:MouseState) : Void
	{	
		stopDragging();
		var item = dragInfo.dragRenderer;
		
		//remove dragrenderer from displaylist
		item.container.children.remove(item);
		
		if (dragInfo.dropTarget.notNull())
		{
#if (flash9 || nme)
			var b = dragInfo.dropBounds = dragInfo.dragRectangle;		//dragInfo.layout.outerBounds;
			
			//adjust dropped x&y to the droptarget
			var pos	= new Point( item.x, item.y );
			pos		= dragInfo.dropTarget.globalToLocal(pos);
			b.left	= pos.x.roundFloat();
			b.top	= pos.y.roundFloat();
#end
		//	dragInfo.dropBounds = dragInfo.dragRectangle;
			//notify the dragged item that the drag-operation is completed
			target.userEvents.drag.complete.send(dragInfo);
			
			//notify the dragInfo that an item is dropped
			dragInfo.dropTarget.dragEvents.drop.send(dragInfo);
		}
		else
		{
			//restore to old location
			dragInfo.restore();
			
			//notifiy the dragged item that the drag-operation is canceled
			target.userEvents.drag.cancel.send( dragInfo );
			disposeDragInfo();
		}

		// re-enable effects
		if (effectsEnabledValue && target.is(IUIElement))
			target.as(IUIElement).effects.enable.onceOn( target.displayEvents.enterFrame, target );	// re-enable after it's layout is validated
		
		moveBinding.disable();
		dragInfo = null;
	}
	
	
	
	
	override private function cancelDrag (mouseObj:MouseState) : Void
	{
	//	trace(target+".cancelDrag \n");
		dragInfo.dropTarget = null;
	//	stopDrag(mouseObj);		<-- this is done by the draghelper
	}
	
	
	
	
	private function checkDropTarget () : Void
	{
		var item = dragInfo.dragRenderer;
		
		if (item.dropTarget.isNull() || !item.dropTarget.is(IDropTarget))
		{
			//if the dragged item is not on any dropTarget, stop checking
			if (dragInfo.dropTarget.isNull() || !item.isObjectOn( dragInfo.dropTarget ))
				dragInfo.dropTarget = null;
			return;
		}
		
		var curDropTarget = item.dropTarget.as(IDropTarget);
		
		//make sure the new droptarget isn't the same as the previous droptarget
		if (curDropTarget == dragInfo.dropTarget || curDropTarget.isNull())
			return;
		
		//check if the drag is allowed over the current dropTarget
		if (curDropTarget.is(IDataDropTarget) && dragInfo.dataCursor.notNull())
		{
			var dataTarget = curDropTarget.as(IDataDropTarget);
			if (dataTarget.isDataDropAllowed( cast dragInfo.dataCursor ))
				dragInfo.dropTarget = dataTarget;
		}
		else if (curDropTarget.isDisplayDropAllowed( dragInfo.displayCursor ))
			dragInfo.dropTarget = curDropTarget;
	}
}
#end