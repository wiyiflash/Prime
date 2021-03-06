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
 *  Danny Wilson    <danny @ onlinetouch.nl>
 */
package prime.tools.valueobjects;


/**
 * @author Danny Wilson
 * @creation-date Dec 03, 2010
 */
class PropertyValueChangeVO extends PropertyChangeVO
{
    public static #if !noinline inline #end function make(propertyID, oldValue, newValue)
    {
        var p = new PropertyValueChangeVO(); // Could come from freelist if profiling tells us to
        p.propertyID = propertyID;
        p.oldValue   = oldValue;
        p.newValue   = newValue;
        return p;
    }
    
    
    public var oldValue     (default, null) : Dynamic;
    public var newValue     (default, null) : Dynamic;
    
    private function new() {}
    
    
    override public function dispose()
    {
        propertyID = -1;
        this.oldValue = this.newValue = null;
        super.dispose();
    }
    
#if debug
    public function toString ()
    {
        return oldValue + " -> " + newValue;
    }
#end
}
