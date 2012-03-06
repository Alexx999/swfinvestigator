/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package ParamHandlers
{
	import ParamHandlers.AMFGeneric;
	import ParamHandlers.CollectionReturnEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.LocalConnection;
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.HRule;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.DataGridEvent;
	import mx.events.DropdownEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Panel;

	/**
	 * Dispatched when the user clicks Create to save and close the window
	 * 
	 * @eventType ParamHandlers.CollectionReturnEvent.PARAMS_RETURNED
	 */
	[Event(name="paramsReturned", type="CollectionReturnEvent")]
	
	/**
	 * The ObjectCollection control is launched by the ParamCollection Object to collect Object and Class data.
	 * 
	 * This class creates the window for collecting the data, builds the object and returns an event once the
	 * user has completed providing their data.  A slightly different window will be show if the window is to
	 * collect remote class information for an AMF connection. Creating an object that contains an Object is
	 * allowed.
	 */
	public class ObjectCollection extends Sprite
	{	
		//private var win:Window;
		private var win:Panel;    
        
        private var className:TextInput = new TextInput();
        private var varName:TextInput = new TextInput();
        private var varValue:TextInput = new TextInput();
        private var cBox:ComboBox = new ComboBox();
        private var sDGArray:ArrayCollection = new ArrayCollection(new Array());
    	private var topBox:VBox = new VBox();
		private var getClass:Boolean = false;
    	private var objectsArr:Array = new Array();
    	private var objCol:ObjectCollection;
		
		private var objColLC:ObjectCollectionLC;
        
        [Bindable]
        private var varTypes:ArrayCollection = new ArrayCollection(
                [ {label:"String", data:"String"}, 
                  {label:"int", data:"int"},
                  {label:"Array", data:"Array"},
                  {label:"Number", data:"Number"},
                  {label:"uint", data:"uint"},
                  {label:"XML", data:"XML"},
                  {label:"Boolean", data:"Boolean"},
                  {label:"null", data:"null"},
                  {label:"Object", data:"Object"} ]);
        
        public var returnObject:Object;
    	public var returnClass:AMFGeneric;


        /**
		 * @public
		 * Draws the Object Collection interface.
		 * Note to self: While doing this manually is hard core, it is also a bad idea.
		 * 
		 * @param addClass A Boolean for whether this interface should show a class option.
		 */
		public function ObjectCollection(addClass:Boolean = false)
		{
				//Set General Window properties
                //this.win = new Window();
                this.win = new Panel
                this.win.title = "Enter Object Information";
                this.win.width = 400;
                this.win.height = 375;
                this.win.x = 1;
                this.win.y = 1;
                //this.win.alpha = 100;
                //this.win.showStatusBar = false;
                this.win.setStyle("backgroundColor",0xFFFFFF);

				//Add Top Box for Class Name if needed
	            this.topBox.setStyle("backgroundColor",0xFFFFFF);
				if (addClass) {
					this.addClassBox();
				}
				//this.win.addChild(this.topBox);
				this.win.addElement(this.topBox);

				//Build Inner Center Box
			    var vb:VBox = new VBox();
				if (addClass) {
					vb.y = 75;
				}
                vb.percentWidth = 100;
                vb.setStyle("paddingBottom", 5);
                vb.setStyle("paddingLeft", 5);
                vb.setStyle("paddingRight", 5);
                vb.setStyle("paddingTop", 5);
                vb.setStyle("backgroundColor",0xFFFFFF);

                //Set up DataGrid
        		var dGrid:DataGrid;
                dGrid = new DataGrid();
                dGrid.percentWidth = 100;
                dGrid.editable = true;
                dGrid.addEventListener(DataGridEvent.ITEM_EDIT_END,updateFuncDG);
                var colArray:Array = new Array();
                colArray.push(new DataGridColumn("Name"), new DataGridColumn("Value"), new DataGridColumn("Type"));
                dGrid.columns = colArray;
                dGrid.dataProvider = this.sDGArray;
                vb.addChild(dGrid);
                
                //Create HBox for entering in variable Name
                var hbName:HBox = new HBox();
                hbName.percentWidth = 100;
                
                var nameText:Text = new Text();
                nameText.text = "Name: ";
                hbName.addChild(nameText);
                hbName.addChild(this.varName);
                vb.addChild(hbName);

				//Create HBox for entering in variable Value
				var hbValue:HBox = new HBox();
				hbValue.percentWidth = 100;
				
                var valueText:Text = new Text();
                valueText.text = "Value: ";
                hbValue.addChild(valueText);
                hbValue.addChild(this.varValue);
 
                this.cBox.dataProvider = this.varTypes;
                this.cBox.addEventListener(Event.CLOSE,comboSelect);
                hbValue.addChild(this.cBox);
                
                vb.addChild(hbValue);
                
                //Add the Add Parameter Button
                var addField:Button = new Button();
                addField.label = "Add Parameter";
                addField.addEventListener(MouseEvent.CLICK,funcAddParam);
                vb.addChild(addField);
                
                var hRule:HRule = new HRule();
                hRule.percentWidth = 100;
                vb.addChild(hRule);

                //this.win.addChild(vb);
				this.win.addElement(vb);
 
                //Create the HBox for the Create/Cancel Buttons;
                var cb:HBox = new HBox();
				cb.x = 1;
				cb.y = this.win.height - 70;
	            cb.setStyle("backgroundColor",0xFFFFFF);
	            cb.setStyle("paddingBottom", 5);
                cb.setStyle("paddingLeft", 5);
                cb.setStyle("paddingRight", 5);
                cb.setStyle("paddingTop", 5);
	            cb.percentWidth = 100;
 
				/**
                var s:Spacer = new Spacer();
                s.percentWidth = 100;
                cb.addChild(s);
				 */

				var rOE:Button = new Button();
				rOE.label = "OE Retrieve";
				rOE.addEventListener(MouseEvent.CLICK, receiveFromOE);
				cb.addChild(rOE);
				
				var b0:Button = new Button();
				b0.label = "OE Send";
				b0.addEventListener(MouseEvent.CLICK, sendToOE);
				cb.addChild(b0);

				var s:Spacer = new Spacer();
				s.percentWidth = 25;
				cb.addChild(s);
				
                var b1:Button = new Button();
                b1.label = "Create";
                b1.addEventListener(MouseEvent.CLICK, closeAndSave);
                cb.addChild(b1);
                
                var b2:Button = new Button();
                b2.label = "Cancel";
                b2.addEventListener(MouseEvent.CLICK, closePopUp);
                cb.addChild(b2);
                
				//this.win.addChild(cb);
				this.win.addElement(cb);
		}
		
		/**
		 * @private
		 * Adds the text fields for collecting the Remote Class Name for the
		 * object to the window.
		 */ 
		private function addClassBox():void {
			this.win.height = 445;
            this.topBox.percentWidth = 100;
            this.topBox.setStyle("paddingBottom", 5);
            this.topBox.setStyle("paddingLeft", 5);
            this.topBox.setStyle("paddingRight", 5);
            this.topBox.setStyle("paddingTop", 5);
                
			this.getClass = true;
            var label:Label = new Label();
            label.text = "Please enter the Remote Class Name:";   
            this.topBox.addChild(label);
               	
            this.className.percentWidth = 100;
            this.topBox.addChild(this.className);
            
            var hRule:HRule = new HRule();
            hRule.percentWidth = 100;
            this.topBox.addChild(hRule);
		}
		
		/**
		 * Adds the new variable information to the Data Grid Array.
		 * 
		 * @param e The MouseEvent resulting from the user click.
		 */
		private function funcAddParam(e:MouseEvent):void {
			var temp:Object = new Object;
			temp.Name = this.varName.text;
			temp.Type = this.cBox.text;
			if (temp.Type != "null") {
				temp.Value = this.varValue.text;
			} else {
				temp.Value = "*NULL*";
			}
			this.sDGArray.addItem(temp);
		}
		
		/**
		 * Once the user clicks Create, this function will build the object or class
		 * based on the information within the data grid.
		 * 
		 * The information is then assigned to the public variable for the class or array
		 * so that the calling code can retrieve it after the window closes.
		 */
		private function buildObject():void {
			var returnPtr:*;
			if (this.getClass) {
				returnPtr = new AMFGeneric();
				flash.net.registerClassAlias(this.className.text,AMFGeneric);
			} else {
				returnPtr = new Object();
			}
			for (var i:int = 0; i < this.sDGArray.length; i++) {
				var temp:Object = this.sDGArray.getItemAt(i);
				switch (temp.Type) {
					case "int":
						returnPtr[temp.Name] = int(temp.Value);
						break;
					case "String":
						returnPtr[temp.Name] = temp.Value;
						break;
					case "Array":
						returnPtr[temp.Name] = temp.Value.split(",");
						break;
					case "null":
						returnPtr[temp.Name] = null;
						break;
					case "Number":
						returnPtr[temp.Name] = Number(temp.Value);
						break;
					case "XML":
           				returnPtr[temp.Name] = new XML(temp.Value);
						break;
           			case "uint":
           				returnPtr[temp.Name] = uint(Number(temp.Value));
						break;
           			case "Boolean":
           				var b:Boolean = false;
           				if (temp.Value == "true" || temp.Value == "1") {
           					b = true;
           				}
           				returnPtr[temp.Name] = b;
						break;
           			case "Object":
           				returnPtr[temp.Name] = this.objectsArr[int(temp.Value)];
						break;
					default :
           		}
   			}
   			
           	if (this.getClass) {
           		this.returnClass = returnPtr;
           	} else {
           		this.returnObject = returnPtr
           	}
		}
		
		/*
		private function assignClass (className:String):void {
			//flash.net.registerClassAlias("flex.decider.restaurant.Restaurant",AMFGeneric);
		}*/

		/**
		 * Calls buildObject to create the object or class, dispatches the PARAMS_RETURNED event
		 * and closes the window.
		 */
		private function closeAndSave(evt:Event):void {
			if (evt != null) {
				this.buildObject();
			}
			
			var newEvent:CollectionReturnEvent = new CollectionReturnEvent(CollectionReturnEvent.PARAMS_RETURNED, true);
			//newEvent.isEnabled = true;
			dispatchEvent(newEvent);
			//this.win.close();
			PopUpManager.removePopUp(this.win);
		}

		/**
		 * Closes the window.
		 */
		public function closePopUp(evt:Event):void {
			PopUpManager.removePopUp(this.win);
			//this.win.close();
		}

		/**
		 * Opens the new window
		 */
		public function createPopUp(myD:DisplayObject):void {
			PopUpManager.addPopUp(this.win, myD, true);
			//win.open();
        }
        
		/**
		 * @private
		 * Sends the object Data to the Object Editor
		 */
		
		private function sendToOE(e:MouseEvent):void {
			var lConn:LocalConnection = new LocalConnection();
			this.buildObject();
			if (this.getClass) {
				lConn.send("app#FlashAnalyzer:objectEditor","editObject",this.returnClass);
			} else {
				lConn.send("app#FlashAnalyzer:objectEditor","editObject",this.returnObject);
			}
		}
		
		/**
		 * @private
		 * Receive object from Object Editor
		 */
		private function receiveFromOE(e:MouseEvent):void {
			if (this.objColLC == null) {
				this.objColLC = new ObjectCollectionLC();
				this.objColLC.addEventListener(CollectionReturnEvent.PARAMS_RETURNED,lcObjectUpdate);
			}
			this.objColLC.fetchOEValue();
		}
		
		/**
		 * @private
		 * Update object and return
		 */
		private function lcObjectUpdate(e:CollectionReturnEvent):void {
			this.returnObject = this.objColLC.returnedObject;
			this.objColLC.close();
			this.closeAndSave(null);
		}
		
        /**
         * When the user selects an object, a new window is opened to collect the information.
         * This receives the PopUpReturnEvent when they are done and adds the information to the
         * Data Grid Array.
         */ 
       	private function gotObject (e:CollectionReturnEvent):void {
			if (this.objectsArr == null) {
				this.objectsArr = new Array();
			}
				
			this.objectsArr.push(e.currentTarget.returnObject);
			var temp:Object = new Object;
			temp.type = "Object";
			temp.value = this.objectsArr.length - 1;
			this.sDGArray.addItem(temp);
			this.objCol = null;
			this.cBox.selectedIndex = 0;
		}
		
		/**
		 * This is an event listener which checks the combo box to determine whether to open an object window.
		 * 
		 * @param ev The DropdownEvent initiated from the selection of the item in the ComboBox
		 */ 
		private function comboSelect(ev:DropdownEvent):void {
			 if (ComboBox(ev.target).selectedItem.data.indexOf("Object") == 0) {
				this.objCol = new ObjectCollection();
				this.objCol.addEventListener(CollectionReturnEvent.PARAMS_RETURNED,gotObject);
				this.objCol.createPopUp(this);
			}
		}
		
		/**
		 * Listens for edits within the Data Grid to determine whether to remove an item.
		 * If a user deletes the value for the first field, then the item will be removed from the data grid.
		 * 
		 * @param dgEvent The DataGridEvent thrown by Item_Edit_End.
		 */
		private function updateFuncDG(dgEvent:DataGridEvent):void {
			if ((dgEvent.columnIndex == 0 && dgEvent.currentTarget.itemEditorInstance.text == dgEvent.currentTarget.selectedItem.Name) ||
				(dgEvent.columnIndex == 1 && dgEvent.currentTarget.itemEditorInstance.text == dgEvent.currentTarget.selectedItem.Value.toString()) ||
				(dgEvent.columnIndex == 2 && dgEvent.currentTarget.itemEditorInstance.text == dgEvent.currentTarget.selectedItem.Type)) {
				return;
			}
				
			if (dgEvent.reason == mx.events.DataGridEventReason.CANCELLED) {
				return;
			}
				
			if (dgEvent.columnIndex == 0) {
				if (dgEvent.currentTarget.itemEditorInstance.length == 0) {
					this.sDGArray.removeItemAt(dgEvent.rowIndex);
				}
			}
		}

	}
}