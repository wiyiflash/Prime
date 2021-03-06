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
package cases;
 import prime.bindable.collections.ArrayList;
 import prime.bindable.Bindable;
 import prime.gui.components.Button;
 import prime.gui.components.Image;
 import prime.gui.components.Label;
 import prime.gui.components.ListView;
 import prime.gui.components.Slider;
 import prime.gui.core.UIComponent;
 import prime.gui.core.UIContainer;
 import prime.gui.core.UIDataContainer;
 import prime.gui.core.UIWindow;
 import prime.gui.display.Window;
 import prime.layout.LayoutClient;
 import prime.layout.LayoutContainer;
  using prime.utils.Bind;
  using Std;



/**
 * @author Ruben Weijers
 * @creation-date Aug 30, 2010
 */
class AppTest extends UIWindow
{
	public static function main () { Window.startup( AppTest ); }
	
	override private function createChildren ()
	{
		children.add( new EditorView("editorView") );
	}
}


class EditorView extends UIContainer
{
	private var applicationBar	: ApplicationMainBar;
	private var framesToolBar	: FramesToolBar;
	private var spreadEditor	: SpreadEditor;
	
	
	override private function createBehaviours () {}	//remove auto change layout behaviour...
	
	override private function createChildren ()
	{
		children.add( spreadEditor		= new SpreadEditor() );
		children.add( framesToolBar		= new FramesToolBar("framesList") );
		children.add( applicationBar	= new ApplicationMainBar("applicationMainBar") );
		
		layoutContainer.children.add( applicationBar.layout );
		layoutContainer.children.add( framesToolBar.layout );
		layoutContainer.children.add( spreadEditor.layout );
	}
}



class ApplicationMainBar extends UIContainer
{
	private var logo : Image;
	
	
	override private function createChildren ()
	{
		children.add( logo = new Image("logo") );
		layoutContainer.children.add( logo.layout );
	}
}



class FramesToolBar extends ListView < FrameTypesSectionVO >
{
	public function new (id:String = null)
	{
		var frames = new ArrayList<FrameTypeVO>();
		frames.add( new FrameTypeVO( "externalLinkFrame", "Externe Link", null ) );
		frames.add( new FrameTypeVO( "internalLinkFrame", "Interne Link", null ) );
		frames.add( new FrameTypeVO( "webshopFrame", "Webshop Kader", null ) );
		
		var media = new ArrayList<FrameTypeVO>();
		media.add( new FrameTypeVO( "imageFrame", "Afbeeldingen", null ) );
		media.add( new FrameTypeVO( "videoFrame", "Video", null ) );
		media.add( new FrameTypeVO( "flashFrame", "Flash", null ) );
		
		var elements = new ArrayList<FrameTypeVO>();
		elements.add( new FrameTypeVO( "shapeFrame", "Vormen", null ) );
		elements.add( new FrameTypeVO( "textFrame", "Tekst", null ) );
		
		var list = new FrameTypesList();
		list.add( new FrameTypesSectionVO( "linkFrames", "kaders", frames ) );
		list.add( new FrameTypesSectionVO( "mediaFrames", "media", media ) );
		list.add( new FrameTypesSectionVO( "elementFrames", "elementen", elements ) );
		super(id, list);
		
	}
	
	
	private function createItemRenderer (dataItem:FrameTypesSectionVO, pos:Int)
	{
		return cast new FrameTypesBar( dataItem.name+"Bar", dataItem );
	}
}



class FrameTypesBar extends UIDataContainer < FrameTypesSectionVO >
{
	private var titleField	: Label;
	private var framesList	: FrameTypesBarList;
	
	
	override private function createChildren ()
	{
		titleField	= new Label(id+"TitleField");
		framesList	= new FrameTypesBarList(id+"List");
		
		titleField.styleClasses.add("title");
		
		children.add( framesList );
		children.add( titleField );
		layoutContainer.children.add( titleField.layout );
		layoutContainer.children.add( framesList.layout );
	}
	
	
	override private function initData ()
	{
		titleField.data.bind( value.label );
		framesList.value = cast value.frames;
	}
}



class FrameTypesBarList extends ListView < FrameTypeVO >
{
	override private function createItemRenderer (dataItem:FrameTypeVO, pos:Int)
	{
		var button = new FrameButton( dataItem );
		if (pos == 0)					button.styleClasses.add("first");
		if (pos == (value.length - 1))	button.styleClasses.add("last");
		return cast button;
	}
}



class FrameButton extends Button
{
	public var vo : FrameTypeVO;
	
	
	public function new (vo:FrameTypeVO)
	{
		super(vo.name+"Button");
		data.bind( vo.label );
		this.vo = vo;
	}
	
	
	override public function dispose ()
	{
		vo = null;
		super.dispose();
	}
}



class SpreadEditor extends UIContainer
{
	private var spreadStage	: SpreadStage;
	private var toolBar		: SpreadToolBar;
	
	override private function createChildren ()
	{
		children.add( spreadStage	= new SpreadStage() );
		children.add( toolBar		= new SpreadToolBar() );
		layoutContainer.children.add( spreadStage.layout );
		layoutContainer.children.add( toolBar.layout );
		
		updatePageZoom.on( toolBar.zoomSlider.data.change, this );
	}
	
	
	private function updatePageZoom ()
	{
		spreadStage.spread.scale( toolBar.zoomSlider.value, toolBar.zoomSlider.value );
	}
}


class SpreadStage extends UIContainer
{	
	public var spread	: SpreadView;
	
	
	override private function createChildren ()
	{
		children.add( spread = new SpreadView() );
		layoutContainer.children.add( spread.layout );
	}
}


class SpreadView extends UIComponent
{
	private var content : UIContainer;
	
	
	override private function createChildren ()
	{
		content = new UIContainer();
		addChild( content );
	}
	
	
	override private function createBehaviours ()
	{
		haxe.Log.clear.on( userEvents.mouse.click, this );
	}
	
	
	
	override public function scale (sx:Float, sy:Float)
	{
		Assert.isNotNull( content );
		resetLayoutScale();
		content.scaleX = sx;
		content.scaleY = sy;
		updateLayoutScale();
	}
	
	
	private inline function resetLayoutScale ()
	{
		layout.width	= (layout.width / content.scaleX).int();
		layout.height	= (layout.height / content.scaleY).int();
	}
	
	
	private inline function updateLayoutScale ()
	{
		layout.width	= (layout.width * content.scaleX).int();
		layout.height	= (layout.height * content.scaleY).int();
	}
}


class SpreadToolBar extends UIContainer
{
	public var undoBtn		(default, null)	: Button;
	public var redoBtn		(default, null)	: Button;
	public var zoomSlider	(default, null)	: Slider;
	
	
	override private function createChildren ()
	{
		children.add( undoBtn = new Button("undoBtn", "Undo") );
		children.add( redoBtn = new Button("redoBtn", "Redo") );
		children.add( zoomSlider = new Slider("zoomSlider", 1, 0.4, 3) );
		layoutContainer.children.add( undoBtn.layout );
		layoutContainer.children.add( redoBtn.layout );
		layoutContainer.children.add( zoomSlider.layout );
		
		undoBtn.styleClasses.add( "toolBtn" );
		redoBtn.styleClasses.add( "toolBtn" );
	}
}




/**
 * Data classes
 */

typedef FrameTypesList		= ArrayList < FrameTypesSectionVO >;


class FrameTypesSectionVO
{
	public var name		: String;
	public var frames	: ArrayList < FrameTypeVO >;
	public var label	: Bindable < String >;
	
	
	public function new (name:String, label:String, frames:ArrayList < FrameTypeVO > )
	{
		this.name	= name;
		this.label	= new Bindable<String>(label);
		this.frames	= frames;
	}
}


class FrameTypeVO
{
	/**
	 * Property is used as ID for the itemViewer
	 */
	public var name			: String;
	public var label		: Bindable < String >;
	public var frameClass	: Class < Dynamic >;
	
	
	public function new (name:String, label:String, frameClass:Class < Dynamic >)
	{
		this.name		= name;
		this.label		= new Bindable<String>(label);
		this.frameClass	= frameClass;
	}
}

