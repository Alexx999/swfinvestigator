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

package decompiler.swfdump.tags
{
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	
	public class ProductInfo extends Tag
	{
		private var build:Number;
		private var product:int;
		private var majorVersion:uint;
		private var minorVersion:uint;
		private var edition:int;
		private var compileDate:Number;
		
		public static const UNKNOWN:int = 0;
		public static const J2EE_PRODUCT:int = 1;
		public static const NET_PRODUCT:int = 2;
		public static const ABOBE_FLEX_PRODUCT:int = 3;
		
		protected static const products:Array = new Array(
				"unknown", // 0
				"Macromedia Flex for J2EE",
				"Macromedia Flex for .NET",    
				"Adobe Flex"
			);
		
		protected static const DEVELOPER_EDITION:int = 0;
		protected static const FULL_COMMERCIAL_EDITION:int = 1;
		protected static const NON_COMMERCIAL_EDITION:int = 2;
		protected static const EDUCATIONAL_EDITION:int = 3;
		protected static const NFR_EDITION:int = 4;
		protected static const TRIAL_EDITION:int = 5;
		protected static const NO_EDITION:int = 6;      // not part of any edition scheme      
		
		public static const editions:Array = new Array(
				"Developer Edition", // 0       
				"Full Commercial Edition", // 1 
				"Non-Commercial Edition", // 2
				"Educational Edition", // 3
				"NFR Edition", // 4
				"Trial Edition", // 5
				""      // 6 no edition
			);
		
		public function ProductInfo(product:int=0, edition:int=0, majorVersion:uint=0, minorVersion:uint=0, build:Number=0, compileDate:Number = 0)
		{
			super(stagProductInfo);
			this.product = product;
			this.edition = edition;
			this.majorVersion = majorVersion;
			this.minorVersion = minorVersion;
			this.build = build;
			this.compileDate = compileDate;
		}
		
		public function getBuild():Number
		{
			return build;
		}
		
		public function getCompileDate():Number
		{
			return compileDate;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is ProductInfo))
			{
				var productInfo:ProductInfo = object as ProductInfo;
				
				if (product == productInfo.product &&
					edition == productInfo.edition &&
					majorVersion == productInfo.majorVersion &&
					minorVersion == productInfo.minorVersion &&
					build == productInfo.build &&
					compileDate == productInfo.compileDate)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function getEdition():int
		{
			return edition;
		}
		
		public function setEdition(edition:int):void
		{
			this.edition = edition;
		}
		
		public function getEditionString():String
		{
			return editions[edition];
		}
		
		public function getProduct():int
		{
			return product;
		}
		
		public function getProductString():String
		{
			return products[product];
		}
		
		public function getMajorVersion():uint
		{
			return majorVersion;
		}
		
		public function getMinorVersion():uint
		{
			return minorVersion;
		}
		
		public override function visit(tagHandler:TagHandler):void
		{
			tagHandler.productInfo(this);
		}
	}
}