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
package primevc.gui.components;
 import primevc.core.collections.IEditableList;
 import primevc.core.collections.ListChange;
 import primevc.gui.behaviours.layout.AutoChangeLayoutChildlistBehaviour;
 import primevc.gui.core.IUIDataComponent;
 import primevc.gui.core.UIDataContainer;
 import primevc.gui.display.IDisplayObject;
  using primevc.utils.Bind;
  using primevc.utils.TypeUtil;


private typedef ItemRenderer < T > = IUIDataComponent < T >;
private typedef ItemRendererType <T> = Class < ItemRenderer < T > >;


/**
 * Class to visually represent data in a list.
 * 
 * @author Ruben Weijers
 * @creation-date Oct 26, 2010
 */
class ListView < ListDataType > extends UIDataContainer < IEditableList < ListDataType > >, implements IListView < ListDataType >
{
	override private function createBehaviours ()
	{
		behaviours.add( new AutoChangeLayoutChildlistBehaviour(this) );
	}
	
	
	override private function initData ()
	{
		//listen for vo changes
		voChangeHandler.on( vo.change, this );
		voChangeHandler( vo.value, null );
	}
	
	
	//
	// DATA RENDERER METHODS
	//
	
	private function createItemRenderer ( item:ListDataType, pos:Int ) : IDisplayObject
	{
		Assert.abstract();
		return null;
	}
	
	
	private function addItemRenderer( item:ListDataType, newPos:Int = -1 )
	{
		if (newPos == -1)
			newPos = vo.value.indexOf( item );
		
		children.add( createItemRenderer( item, newPos ), newPos );
	}
	
	
	private function removeItemRenderer( item:ListDataType, oldPos:Int = -1 )
	{
		var renderer = getItemRendererFor( item );
		if (renderer != null) {
			children.remove( renderer );
			renderer.dispose();
		}
	}
	
	
	private function getItemRendererFor ( item:ListDataType )
	{
		for (child in children) {
			if (child.is( ItemRenderer ))
			{
				if (item == cast child.as( ItemRenderer ).data )
					return child;
			}
		}
		
		return null;
	}
	
	
	private function moveItemRenderer ( item:ListDataType, newPos:Int, oldPos:Int )
	{
		var renderer = getItemRendererFor( item );
		if (renderer != null)
			children.move( renderer, newPos, oldPos );
#if debug
		else
			trace("no itemrenderer found to move for vo-item "+item+"; move: "+oldPos+" => "+newPos);
#end
	}
	
	
	
	//
	// EVENT HANDLERS
	//
	
	private function voChangeHandler (newVal:IEditableList< ListDataType >, oldVal:IEditableList< ListDataType > ) : Void
	{
		if (oldVal == newVal)
			return;
		
		if (oldVal != null)
		{
			for (item in oldVal)
				removeItemRenderer( item );
			
			oldVal.change.unbind(this);
		}
		
		if (newVal != null)
		{
			listChangeHandler.on( newVal.change, this );
			
			//add itemrenders for new list
			for (item in newVal)
				addItemRenderer( item );
		}
	}
	
	
	
	private function listChangeHandler ( change:ListChange < ListDataType > ) : Void
	{
		switch (change)
		{
			case added( item, newPos):			addItemRenderer( item, newPos );
			case removed (item, oldPos):		removeItemRenderer( item, oldPos );
			case moved (item, newPos, oldPos):	moveItemRenderer( item, newPos, oldPos );
			default:
		}
	}
}