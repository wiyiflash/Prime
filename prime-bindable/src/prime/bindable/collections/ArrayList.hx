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
 *  Ruben Weijers	<ruben @ prime.vc>
 */
package prime.bindable.collections;
  using prime.utils.FastArray;
 

/**
 * @creation-date	Jun 29, 2010
 * @author			Ruben Weijers
 */
class ArrayList <T> extends ReadOnlyArrayList <T> implements IEditableList <T>
{
	//public function new( wrapAroundList:FastArray<T> = null ) super(wrapAroundList);	//FIXME: NEEDED FOR HAXE 2.09 (http://code.google.com/p/haxe/issues/detail?id=671)

	override public function dispose ()
	{
		removeAll();
		super.dispose();
	}
	
	
	public function removeAll ()
	{
		if (length > 0)
		{
			var msg = ListChange.reset;
			beforeChange.send( msg );
			list.removeAll();
			change.send( msg );
		}
	}
	
	
	@:keep public #if !noinline inline #end function isEmpty()
	{
		return length == 0;
	}
	
	
	public function add (item:T, pos:Int = -1) : T
	{
		pos = list.validateNewIndex(pos);
		var msg = ListChange.added( item, pos );
		beforeChange.send( msg );
		var p = list.insertAt(item, pos);
#if debug Assert.isEqual( p, pos ); #end
		change.send( msg );
		return item;
	}
	
	
	public function remove (item:T, curPos:Int = -1) : T
	{
		if (curPos == -1)
			curPos = list.indexOf(item);
		
		if (curPos > -1)
		{
			var msg = ListChange.removed( item, curPos );
			beforeChange.send( msg );
			list.removeAt(curPos);
			change.send(msg);
		}
		return item;
	}
	
	
	public function move (item:T, newPos:Int, curPos:Int = -1) : T
	{
		if		(curPos == -1)				curPos = list.indexOf(item);
		if		(newPos > (length - 1))		newPos = length - 1;
		else if (newPos < 0)				newPos = length - newPos;

		if (curPos != newPos) {
			var msg = ListChange.moved( item, newPos, curPos );
			beforeChange.send( msg );
			if (list.move(item, newPos, curPos))
				change.send( msg );
		}
		
		return item;
	}
	
	override public function clone () : IReadOnlyList<T>		return new ArrayList<T>( list.clone() );
	override public function duplicate () : IReadOnlyList<T>	return new ArrayList<T>( list.duplicate() );
}