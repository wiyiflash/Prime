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
package prime.utils;
  using prime.utils.NumberUtil;
  using Std;


/**
 * Utility with methods to handle time formatting
 *
 * @author Ruben Weijers
 * @creation-date Jan 13, 2011
 */
#if !js extern #end class DateUtil
{
	public static inline function secondsToTime ( seconds:Int ) : String
	{
		var s	= seconds % 60;
		var m	= ( seconds / 60 ).floorFloat();
		return m.string() + ":" + ((s < 10) ? "0" + s : s.string());
	}


	/**
	 * Method will make a string out of the given date object, formatted as:
	 * 		YearMonthDayHoursMinutesSeconds
	 */
	public static inline function fullDateString (d:Date) : String
	{
		return '' + d.getFullYear() + d.getMonth() + d.getDay() + d.getHours() + d.getMinutes() + d.getSeconds();
	}

	/**
	 * Identical as Date.fromTime
	 */
	public static inline function toDate (milliseconds:Float) : Date
	{
		return Date.fromTime(milliseconds);
	}
}