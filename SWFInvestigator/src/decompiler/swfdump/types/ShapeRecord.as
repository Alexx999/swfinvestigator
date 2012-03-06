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
	import decompiler.swfdump.TagHandler;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * Defines the API for shape records.
	 *
	 * @author Clement Wong
	 */
	//Was Java abstract?
	public class ShapeRecord
	{
		public function visitDependents(h:TagHandler):void
		{
		}
		
		//list was List<Tag> list
		public function getReferenceList( list:Vector.<Tag> ):void
		{
		}
		
		public function equals( o:* ):Boolean
		{
			return (o is ShapeRecord);
		}
		
		//Was Java Abstract
		public function addToDelta(xTwips:int, yTwips:int):void{};
	}

}