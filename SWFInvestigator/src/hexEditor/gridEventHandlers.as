/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

/**
 * This is currently designed to be an include file for files that have a hex grid
 * It assumes the relevant data grid is called hvDataGrid
 * It assumes the HexViewer object is called HV
 * Ideally I would make the data grid and these functions a component
 * In the meantime, I am just making it an include file for the ABCEditor, Editor Tab and Binary Editor.
 */

import flash.desktop.Clipboard;
import flash.events.Event;
import flash.utils.ByteArray;

import osUtils.DragAndDropManager;

import spark.components.gridClasses.CellPosition;
import spark.events.GridItemEditorEvent;

private var dragManager:DragAndDropManager;


/**
 * @private
 * Updates the string column in the grid after an edit
 */
private function updateString(e:GridItemEditorEvent):void {
	this.HV.resetString(e.rowIndex);
}


/**
 * @private
 * This is registered by initializeDG() to handle the Event.COPY event
 * It will copy the hex from the DataGrid to the clipboard as a comma-delimited string.
 * The string and offset data is not copied.
 * 
 * @param e An ActionScript Event.COPY call
 */
private function handleCopy(e:Event):void {
	if (e != null) {
		e.preventDefault();
	}
	
	// Using a Vector for performance
	var dataVector:Vector.<String> = new Vector.<String>;
	var startCell:CellPosition = this.hvDataGrid.selectedCells[0];
	var endCell:CellPosition = this.hvDataGrid.selectedCells[this.hvDataGrid.selectedCells.length - 1];
	
	var row:uint = startCell.rowIndex;
	var colIndex:uint = startCell.columnIndex;
	var data:Object;
	var i:uint;
	
	if (colIndex < 2) {colIndex=2;}
	
	while (row < endCell.rowIndex) {
		data = this.hvDataGrid.dataProvider[row];
		while (colIndex < 18) {
			dataVector.push (data["col" + (colIndex - 2)]);
			colIndex++;
		}
		colIndex = 2;
		row++;
	}
	
	if (startCell.rowIndex == endCell.rowIndex) {
		i = startCell.columnIndex - 2;
	} else {
		i = 0;
	}
	
	data = this.hvDataGrid.dataProvider[row];
	colIndex = endCell.columnIndex;
	if (colIndex > 17) {
		colIndex = 17;
		while (data["col" + (colIndex-2)] == null) {
			colIndex--;
		}
	}
	
	while (i + 2 <= colIndex) {
		dataVector.push(data["col" + i]);
		i++;
	}
	
	// Write dataString to the clipboard.
	Clipboard.generalClipboard.clear();
	System.setClipboard(dataVector.toString());
	
	dataVector = null;
}

/**
 * @private
 * This is registered by initializeDG() to handle the Event.CUT event
 * It will copy the hex from the DataGrid to the clipboard as a comma-delimited string.
 * It will also remove the relevant bytes from the data grid.
 * The string and offset data is not copied.
 * 
 * @param e An ActionScript Event.CUT call
 */
private function handleCut(e:Event):void {
	e.preventDefault();
	
	handleCopy(null);
	
	var startCell:CellPosition = this.hvDataGrid.selectedCells[0];
	var endCell:CellPosition = this.hvDataGrid.selectedCells[this.hvDataGrid.selectedCells.length - 1];
	
	var n:int = this.hvDataGrid.selectedCells.length;
	
	if (n <= 0) {return;}
	
	var start:uint;
	if (startCell.columnIndex > 1) {
		start = (startCell.rowIndex * 16) + startCell.columnIndex - 2;
	} else {
		start = startCell.rowIndex * 16;
	}
	
	var end:uint = (endCell.rowIndex * 16) + endCell.columnIndex - 2;
	if (end > this.HV.swfBytes.length) {
		end = this.HV.swfBytes.length - 1;
	}
	
	this.HV.deleteData(start,end);
	this.HV.updateHexArray();
	this.hvDataGrid.ensureCellIsVisible(startCell.rowIndex,startCell.columnIndex);
	this.hvDataGrid.setSelectedCell(startCell.rowIndex, startCell.columnIndex);
}


/**
 * @private
 * This is registered by initializeDG() to handle the Event.PASTE event
 * This will copy the comma-delimited hex from the clipboard to the DataGrid.
 * The string and offset data should not be included in the paste.
 * 
 * @param e An ActionScript Event.COPY call
 */
private function handlePaste(e:Event):void {
	e.preventDefault();
	
	if (this.hvDataGrid.selectedCells.length != 1) {
		if (this.HV.swfBytes != null && this.HV.swfBytes.length > 0) {
			return;
		} else if (this.HV.swfBytes == null) {
			this.HV.initViewer(new ByteArray());
		}
	}
	
	var pasteData:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
	var bytes:Array = pasteData.split(",");
	var pasteArray:ByteArray = new ByteArray();
	for (var i:int = 0; i < bytes.length; i++) {
		pasteArray.writeByte(int("0x" + bytes[i]));
	}
	pasteArray.position = 0;
	
	var cell:CellPosition = this.hvDataGrid.selectedCell;
	
	var pos:uint;
	
	if (cell != null) {
		pos = (cell.rowIndex * 16) + cell.columnIndex - 2;
	} else {
		cell = new CellPosition(0,0);
		pos = 0;
	}
	
	this.HV.insertData(pos,pasteArray);
	this.HV.updateHexArray();
	this.hvDataGrid.ensureCellIsVisible(cell.rowIndex,cell.columnIndex);
	this.hvDataGrid.setSelectedCell(cell.rowIndex,cell.columnIndex);
}

/**
 * @private
 * Check the bytes of the file
 * 
 * @param data The ByteArray from the drag
 */
private function dndValidation(data:ByteArray, fName:String, url:String):void {
	if (data.length > 0) {
		this.HV.initViewer(data);
		this.HV.updateHexArray();
	}
}


/**
 * @private
 * Registers the handlers for cut, copy and paste commands
 */
private function initializeDG():void {
	this.hvDataGrid.addEventListener(Event.COPY, handleCopy);
	this.hvDataGrid.addEventListener(Event.CUT, handleCut);
	this.hvDataGrid.addEventListener(Event.PASTE, handlePaste);
	
	if (DragAndDropManager.isSupported() && this.HV.dndSupported) {
		this.dragManager = new DragAndDropManager(this.hvDataGrid, dndValidation);
	}
}