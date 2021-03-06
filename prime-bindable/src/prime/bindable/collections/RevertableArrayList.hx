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
 import prime.utils.FastArray;
  using prime.utils.FastArray;
  using prime.utils.BitUtil;
  using prime.bindable.collections.ListChange;


private typedef Flags = prime.bindable.RevertableBindableFlags;

#if !noinline extern #end class RevertableArrayListFlags
{
	static public inline var REMEMBER_CHANGES = 32768;	// 0b_1000 0000 0000 0000
}

/**
 * @author Ruben Weijers
 * @creation-date Nov 19, 2010
 */
class RevertableArrayList<T> extends ReadOnlyArrayList<T> implements IRevertableList<T>
{
	/**
	 * Keeps track of settings.
	 */
	public var flags : Int;
	
	/**
	 * List with all the changes that are made when the list is in editing mode.
	 */
	public var changes (default,null) : FastArray<ListChange<T>>;
	
	
	public function new( wrapAroundList:FastArray<T> = null )
	{
		super(wrapAroundList);
		flags = RevertableArrayListFlags.REMEMBER_CHANGES;
	}
	
	
	override public function clone ()
	{
		return untyped new RevertableArrayList<T>( list.clone() );
	}
	
	
	override public function duplicate ()
	{
		return untyped new RevertableArrayList<T>( list.duplicate() );
	}
	
	
	public #if !noinline inline #end function rememberChanges (enabled:Bool = true)				{ flags = enabled ? flags.set(RevertableArrayListFlags.REMEMBER_CHANGES) : flags.unset(RevertableArrayListFlags.REMEMBER_CHANGES); }
	public #if !noinline inline #end function dispatchChangesBeforeCommit (enabled:Bool = true)	{ flags = enabled ? flags.set(Flags.DISPATCH_CHANGES_BEFORE_COMMIT) : flags.unset(Flags.DISPATCH_CHANGES_BEFORE_COMMIT); }
	
	
	//
	// EDITABLE VALUE-OBJECT METHODS
	//
	
	public #if !noinline inline #end function isEmpty()
	{
		return this.length == 0;
	}
	
	
	public #if !noinline inline #end function beginEdit ()
	{
		if (flags.hasNone( Flags.IN_EDITMODE ))
		{
			flags = flags.set( Flags.IN_EDITMODE );
			if (flags.has(RevertableArrayListFlags.REMEMBER_CHANGES))
				changes = FastArrayUtil.create();
		}
	}
	
	
	public /*inline*/ function commitEdit ()
	{
		// Check if REMEMBER_CHANGES is not set (value changed) and any dispatch flag is set.
		if (changes != null && flags.has(RevertableArrayListFlags.REMEMBER_CHANGES) && flags.hasNone( Flags.DISPATCH_CHANGES_BEFORE_COMMIT ))
			while (changes.length > 0) {
				var listChange = changes.shift();
				Assert.isNotNull( listChange );
				change.send( listChange );
			}
		
		stopEdit();
	}
	
	
	public #if !noinline inline #end function cancelEdit ()
	{
		if (changes != null && flags.hasAll( Flags.IN_EDITMODE | RevertableArrayListFlags.REMEMBER_CHANGES))
		{
			var f = flags;
			flags = flags.unset( RevertableArrayListFlags.REMEMBER_CHANGES );
			while (changes.length > 0)
				this.undoListChange( changes.pop() );
			
			flags = f;
		}
		
		stopEdit();
	}
	
	
	private inline function stopEdit ()
	{
		if (changes != null) {
			changes.removeAll();
			changes = null;
		}
		flags = flags.unset(Flags.IN_EDITMODE);
	}


	public #if !noinline inline #end function isEditable ()
	{
		return flags.has( Flags.IN_EDITMODE );
	}
	
	
	
	//
	// IBINDABLE LIST METHODS
	//
	
	
	private inline function addChange (listChange:ListChange<T>)
	{
		if (flags.has( RevertableArrayListFlags.REMEMBER_CHANGES ))		changes.push( listChange );
		if (flags.has( Flags.DISPATCH_CHANGES_BEFORE_COMMIT ))			change.send( listChange );
	}
	
	
	public function removeAll ()
	{
		var f = flags;
		Assert.that( f.has(Flags.IN_EDITMODE) );
		flags = f.unset(Flags.DISPATCH_CHANGES_BEFORE_COMMIT);
		
		while (length > 0)
			remove(list[length - 1]);
		
		flags = f;
		if (f.has(Flags.DISPATCH_CHANGES_BEFORE_COMMIT))
			change.send( ListChange.reset );
	}
	
	
	public function add (item:T, pos:Int = -1) : T
	{
		var f = flags;
		Assert.that( f.has(Flags.IN_EDITMODE), this+" doesn't have EDITMODE. ");
		pos = list.insertAt(item, pos);
		addChange( ListChange.added( item, pos ) );
		return item;
	}
	
	
	public function remove (item:T, oldPos:Int = -1) : T
	{
		var f = flags;
		Assert.that( f.has(Flags.IN_EDITMODE) );
		if (oldPos == -1)							oldPos = list.indexOf(item);
		if (oldPos > -1 && list.removeAt(oldPos))	addChange( ListChange.removed( item, oldPos ) );
		return item;
	}
	
	
	public function move (item:T, newPos:Int, curPos:Int = -1) : T
	{
		var f = flags;
		Assert.that( f.has(Flags.IN_EDITMODE) );
		if		(curPos == -1)				curPos = list.indexOf(item);
		if		(newPos > (length - 1))		newPos = length - 1;
		else if (newPos < 0)				newPos = length - newPos;
		
		if (curPos != newPos && list.move(item, newPos, curPos))
			addChange( ListChange.moved( item, newPos, curPos ) );
		
		return item;
	}


#if debug
	public #if !noinline inline #end function readFlags ()
		return Flags.readProperties(flags);
#end
}