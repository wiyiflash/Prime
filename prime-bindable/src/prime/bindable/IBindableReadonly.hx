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
 *  Danny Wilson	<danny @ prime.vc>
 */
package prime.bindable;
 import prime.signals.Signal2;


typedef OldValue <V> = V;


/**
 * Read-only interface for 'data-binding'.
 * 
 * @see Bindable
 * @author Danny Wilson
 * @creation-date Jun 25, 2010
 */
//#if flash9 @:generic #end
interface IBindableReadonly<T>
					extends prime.core.traits.IDisposable
#if prime_data 		extends prime.core.traits.IValueObject #end
{
	/** 
	 * Dispatched just before "value" is set to a new value.
	 * Signal arguments: new-value, old-value
	 */
	public var change	(default, null)	: Signal2<T, OldValue<T>>;
	public var value	(default, null)	: T;
	
	/**
	 * Remove any connections between this IChangeNotifier and 'otherBindable'
	 * 
	 * @return true when a connection was removed
	 */
	public function unbind (otherBindable:IBindableReadonly<T>) : Bool;
	
	/**
	 * Makes sure otherBindable.value is (and remains) equal
	 * to this.value
	 *
	 * In other words:
	 * - sets otherBindable.value to this.value
	 * - updates otherBindable.value when this.value changes
	 */
	private function keepUpdated (otherBindable:IBindable<T>) : Void;
}
