////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.types
{
	/**
	 * A common base class for edge record data and logic.
	 *
	 * @author Clement Wong
	 */
	//Was Java abstract?
	public class EdgeRecord extends ShapeRecord
	{
		/**
		 * The maximum value that an EdgeRecord delta can take in SWF.
		 * <p>
		 * This limit arises due to the SWF encoding format of a Shape's EdgeRecord.
		 * A delta is encoded using a specified bit length, however, the number
		 * of bits used to record this bitlength (minus 2) is restricted to 4 bits,
		 * which is 15 + 2 = 17 bits for unsigned, or 16 bits for signed.
		 * <p>
		 * This restricts the signed delta values to 65535 twips, i.e. (2 pow 16) - 1.
		 *
		 */
		public static const  MAX_DELTA_IN_TWIPS:int = 65535;
		
		public override function equals( o:* ):Boolean
		{
			return (super.equals( o ) && (o is EdgeRecord));
		}
	}

}