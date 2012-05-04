package  
{
	import com.adobe.serialization.json.JSON;
	import cepa.utils.ToolTip;
	import fl.motion.Motion;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	/**
	 * ...
	 * @author Luciano
	 */
	public class Main extends MovieClip
	{
		public var movimentos:int = 0;
		public var acertos:int = 0;
		private var dragging:MovieClip;
		private var startX:Number;
		private var startY:Number;
		private var dict:Dictionary;
		//private var wrongAnswerSound:WrongAnswerSound = new WrongAnswerSound();
		private var tweenX:Tween;
		private var tweenY:Tween;
		private var tweenX2:Tween;
		private var tweenY2:Tween;
		private const GLOW_FILTER:GlowFilter = new GlowFilter(0xFF0000, 1, 5, 5, 2, 2);
		private var alvo:MovieClip;
		private var imagePositions:Array = new Array();
		private var dictImage:Dictionary;
		private var dictCaixa:Dictionary;
		private var thumbnailDict:Dictionary;
		private var imageDict:Dictionary;
		private var caixasGruposDict:Dictionary;
		private var images:Array = [];
		private var lastWidth:Number;
		private var lastHeight:Number;
		private var alvosUsados:Array = new Array();
		//private var grupoSelected = false;
		private var lastGrupo:Number = 0;
		private var lastCaixa1;
		private var lastCaixa2;
		private var lastCaixa3;
		private var lastCaixa4;
		private var grupoAtual:int = 1;
		private var dictRespostas:Dictionary;
		private var tempGrupo:int;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.scrollRect = new Rectangle(0, 0, 700, 669);
			menu.resetBtn.addEventListener(MouseEvent.CLICK, reset);
			feedbackCerto.botaoOK.addEventListener(MouseEvent.CLICK, function () { feedbackCerto.visible = false; } );
			feedbackErrado.botaoOK.addEventListener(MouseEvent.CLICK, function () { feedbackErrado.visible = false; } );
			menu.instructionsBtn.addEventListener(MouseEvent.CLICK, function () { infoScreen.visible = true; setChildIndex(infoScreen, numChildren - 1); } );
			infoScreen.addEventListener(MouseEvent.CLICK, function () { infoScreen.visible = false; } );
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent) { if (KeyboardEvent(e).keyCode == Keyboard.ESCAPE) infoScreen.visible = false;} );
			menu.creditosBtn.addEventListener(MouseEvent.CLICK, function () { aboutScreen.visible = true; setChildIndex(aboutScreen, numChildren - 1); } );
			aboutScreen.addEventListener(MouseEvent.CLICK, function () { aboutScreen.visible = false; } );
			
			makeoverOut(feedbackCerto.botaoOK);
			makeoverOut(feedbackErrado.botaoOK);
			makeoverOut(menu.tutorialBtn);
			makeoverOut(menu.instructionsBtn);
			makeoverOut(menu.creditosBtn);
			makeoverOut(menu.resetBtn);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent) { if (KeyboardEvent(e).keyCode == Keyboard.ESCAPE) aboutScreen.visible = false;} );
			
			menu.tutorialBtn.buttonMode = true;
			menu.instructionsBtn.buttonMode = true;
			menu.resetBtn.buttonMode = true;
			menu.creditosBtn.buttonMode = true;
			
			var ttinfo:ToolTip = new ToolTip(menu.instructionsBtn, "Orientações", 11, 0.8, 200, 0.6, 0.1);
			addChild(ttinfo);
			var ttreset:ToolTip = new ToolTip(menu.resetBtn, "Nova tentativa", 11, 0.8, 200, 0.6, 0.1);
			addChild(ttreset);
			var ttcc:ToolTip = new ToolTip(menu.creditosBtn, "Créditos", 11, 0.8, 200, 0.6, 0.1);
			addChild(ttcc);
			
			feedbackCerto.botaoOK.buttonMode = true;
			feedbackErrado.botaoOK.buttonMode = true;
			
			infoScreen.visible = false;
			aboutScreen.visible = false;
			feedbackCerto.visible = false;
			feedbackErrado.visible = false;
			grupo.visible = false;
			
			finaliza.alpha = 0.5;
			
			background.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			for (var i:int = 1; i <= 18; i++ ) {
				this["thumbnail" + String(i)].addEventListener(MouseEvent.MOUSE_DOWN, drag);
				this["imagem" + String(i)].addEventListener(MouseEvent.MOUSE_DOWN, drag);
				this["thumbnail" + String(i)].buttonMode = true;
				this["thumbnail" + String(i)].mouseChildren = false;
				this["imagem" + String(i)].buttonMode = true;
				this["imagem" + String(i)].mouseChildren = false;
				imagePositions[i] = new Point(this["thumbnail" + String(i)].x, this["thumbnail" + String(i)].y);
				images[i] = this["thumbnail" + String(i)];
				//this["caixa" + String(i)].texto.text = String(i);
			}
			
			for (i = 1; i <= 8; i++ ) {
				this["grupo" + String(i)].buttonMode = true;
				this["grupo" + String(i)].addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				this["grupo" + String(i)].addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
				this["grupo" + String(i)].addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			}
			
			for (i = 1; i <= 32; i++ ) {
				this["caixa" + String(i)].visible = false;
				setChildIndex(this["caixa" + String(i)], 2);
			}
			
			criaDict();
			
			setChildIndex(legenda, 1);
			setChildIndex(grupo, 1);
			setChildIndex(background, 0);
			
			if (ExternalInterface.available) {
				initLMSConnection();
				if (mementoSerialized != null) {
					if(mementoSerialized != "" && mementoSerialized != "null") restoreAIStatus(null);
				}
			}
		}
		
		private function mouseOver(e:MouseEvent):void 
		{
			grupoAtual = int(e.target.name.slice(5, 6));
			
			if (grupoAtual == 0) grupoAtual = int(e.target.parent.name.slice(5, 6));
			
			grupo.visible = true;
			grupo.gotoAndStop(grupoAtual);
			
			for (var i:int = 1; i <= 8; i++) this["grupo" + String(i)].barra.filters = [];
			this["grupo" + String(grupoAtual)].barra.filters = [GLOW_FILTER];
			
			for (i = 1; i <= 32; i++) this["caixa" + String(i)].visible = false;
			
			if (lastGrupo != 0) {
				if (thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][0]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][0]]].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][1]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][1]]].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][2]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][2]]].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][3]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[lastGrupo][3]]].visible = false;
			}
			
			if (caixasGruposDict[grupoAtual][0] != null) {
				caixasGruposDict[grupoAtual][0].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]].visible = true;
			}
			if (caixasGruposDict[grupoAtual][1] != null) {
				caixasGruposDict[grupoAtual][1].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]].visible = true;
			}
			if (caixasGruposDict[grupoAtual][2] != null) {
				caixasGruposDict[grupoAtual][2].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]].visible = true;
			}
			if (caixasGruposDict[grupoAtual][3] != null) {
				caixasGruposDict[grupoAtual][3].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]].visible = true;
			}
		}
		
		private function mouseOut(e:MouseEvent):void 
		{
			if (lastGrupo != grupoAtual) this["grupo" + String(grupoAtual)].barra.filters = [];
			
			if (lastGrupo != 0) this["grupo" + String(lastGrupo)].barra.filters = [GLOW_FILTER];
			
			for (var i:int = 1; i <= 32; i++) this["caixa" + String(i)].visible = false;
			if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]].visible = false;
			if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]].visible = false;
			if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]].visible = false;
			if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]].visible = false;
			
			if (lastCaixa1 != null) {
				lastCaixa1.visible = true;
				if (thumbnailDict[dictCaixa[lastCaixa1]] != null) thumbnailDict[dictCaixa[lastCaixa1]].visible = true;
			}
			if (lastCaixa2 != null) {
				lastCaixa2.visible = true;
				if (thumbnailDict[dictCaixa[lastCaixa2]] != null) thumbnailDict[dictCaixa[lastCaixa2]].visible = true;
			}
			if (lastCaixa3 != null) {
				lastCaixa3.visible = true;
				if (thumbnailDict[dictCaixa[lastCaixa3]] != null) thumbnailDict[dictCaixa[lastCaixa3]].visible = true;
			}
			if (lastCaixa4 != null) {
				lastCaixa4.visible = true;
				if (thumbnailDict[dictCaixa[lastCaixa4]] != null) thumbnailDict[dictCaixa[lastCaixa4]].visible = true;
			}
			
			if (lastGrupo == 0) {  // Esconde o grupo só se não houver nenhum selecionado
				grupo.visible = false;
			} else { 
				grupo.gotoAndStop(lastGrupo);
				
			}
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			tempGrupo = int(e.target.name.slice(5, 6));
			if (tempGrupo == 0) tempGrupo = int(e.target.parent.name.slice(5, 6));
			
			if (tempGrupo == lastGrupo || e.target is Background) {  // Deselecionando o grupo
				grupo.visible = false;
				lastGrupo = 0;
				lastCaixa1 = null;
				lastCaixa2 = null;
				lastCaixa3 = null;
				lastCaixa4 = null;
				for (var i:int = 1; i <= 32; i++) this["caixa" + String(i)].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]].visible = false;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]].visible = false;
				for (i = 1; i <= 8; i++) this["grupo" + String(i)].barra.filters = [];
			} else {  // Selecionando o grupo
				lastGrupo = int(e.target.name.slice(5, 6));
				if (lastGrupo == 0) lastGrupo = int(e.target.parent.name.slice(5, 6));
				lastCaixa1 = caixasGruposDict[lastGrupo][0];
				lastCaixa2 = caixasGruposDict[lastGrupo][1];
				lastCaixa3 = caixasGruposDict[lastGrupo][2];
				lastCaixa4 = caixasGruposDict[lastGrupo][3];
				grupo.visible = true;
				grupo.gotoAndStop(lastGrupo);
				if (lastCaixa1 != null) lastCaixa1.visible = true;
				if (lastCaixa2 != null) lastCaixa2.visible = true;
				if (lastCaixa3 != null) lastCaixa3.visible = true;
				if (lastCaixa4 != null) lastCaixa4.visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][0]]].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][1]]].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][2]]].visible = true;
				if (thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]] != null) thumbnailDict[dictCaixa[caixasGruposDict[grupoAtual][3]]].visible = true;
				for (i = 1; i <= 8; i++) this["grupo" + String(i)].barra.filters = [];
				this["grupo" + String(grupoAtual)].barra.filters = [GLOW_FILTER];
			}
		}
		
		private function makeoverOut(btn:MovieClip):void
		{
			btn.mouseChildren = false;
			btn.addEventListener(MouseEvent.MOUSE_OVER, over);
			btn.addEventListener(MouseEvent.MOUSE_OUT, out);
		}
		
		private function over(e:MouseEvent):void
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.gotoAndStop(2);
		}
		
		private function out(e:MouseEvent):void
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.gotoAndStop(1);
		}
		
		function criaDict() :void {
			dict = new Dictionary();
			dict[thumbnail1] = caixa1;
			dict[thumbnail2] = caixa2;
			dict[thumbnail3] = caixa3;
			dict[thumbnail4] = caixa4;
			dict[thumbnail5] = caixa5;
			dict[thumbnail6] = caixa6;
			dict[thumbnail7] = caixa7;
			dict[thumbnail8] = caixa8;
			dict[thumbnail9] = caixa9;
			dict[thumbnail10] = caixa10;
			dict[thumbnail11] = caixa11;
			dict[thumbnail12] = caixa12;
			dict[thumbnail13] = caixa13;
			dict[thumbnail14] = caixa14;
			dict[thumbnail15] = caixa15;
			dict[thumbnail16] = caixa16;
			dict[thumbnail17] = caixa17;
			dict[thumbnail18] = caixa18;
			
			thumbnailDict = new Dictionary();
			thumbnailDict[thumbnail1] = imagem1;
			thumbnailDict[thumbnail2] = imagem2;
			thumbnailDict[thumbnail3] = imagem3;
			thumbnailDict[thumbnail4] = imagem4;
			thumbnailDict[thumbnail5] = imagem5;
			thumbnailDict[thumbnail6] = imagem6;
			thumbnailDict[thumbnail7] = imagem7;
			thumbnailDict[thumbnail8] = imagem8;
			thumbnailDict[thumbnail9] = imagem9;
			thumbnailDict[thumbnail10] = imagem10;
			thumbnailDict[thumbnail11] = imagem11;
			thumbnailDict[thumbnail12] = imagem12;
			thumbnailDict[thumbnail13] = imagem13;
			thumbnailDict[thumbnail14] = imagem14;
			thumbnailDict[thumbnail15] = imagem15;
			thumbnailDict[thumbnail16] = imagem16;
			thumbnailDict[thumbnail17] = imagem17;
			thumbnailDict[thumbnail18] = imagem18;
			
			caixas = [caixa1, caixa2, caixa3, caixa4, caixa5, caixa6, caixa7, caixa8, caixa9];
			
			imageDict = new Dictionary();
			imageDict[imagem1] = thumbnail1;
			imageDict[imagem2] = thumbnail2;
			imageDict[imagem3] = thumbnail3;
			imageDict[imagem4] = thumbnail4;
			imageDict[imagem5] = thumbnail5;
			imageDict[imagem6] = thumbnail6;
			imageDict[imagem7] = thumbnail7;
			imageDict[imagem8] = thumbnail8;
			imageDict[imagem9] = thumbnail9;
			imageDict[imagem10] = thumbnail10;
			imageDict[imagem11] = thumbnail11;
			imageDict[imagem12] = thumbnail12;
			imageDict[imagem13] = thumbnail13;
			imageDict[imagem14] = thumbnail14;
			imageDict[imagem15] = thumbnail15;
			imageDict[imagem16] = thumbnail16;
			imageDict[imagem17] = thumbnail17;
			imageDict[imagem18] = thumbnail18;
			
			caixasGruposDict = new Dictionary();
			caixasGruposDict[1] = [caixa18];
			caixasGruposDict[2] = [caixa13];
			caixasGruposDict[3] = [caixa16, caixa17];
			caixasGruposDict[4] = [caixa14, caixa15];
			caixasGruposDict[5] = [caixa1, caixa2, caixa3, caixa4];
			caixasGruposDict[6] = [caixa10, caixa11, caixa12];
			caixasGruposDict[7] = [caixa5, caixa6, caixa7, caixa8];
			caixasGruposDict[8] = [caixa9];
			
			dictRespostas = new Dictionary();
			dictRespostas[caixa1] = [thumbnail1, thumbnail2, thumbnail3, thumbnail4, thumbnail8];
			dictRespostas[caixa2] = [thumbnail1, thumbnail2, thumbnail3, thumbnail4, thumbnail8];
			dictRespostas[caixa3] = [thumbnail1, thumbnail2, thumbnail3, thumbnail4, thumbnail8];
			dictRespostas[caixa4] = [thumbnail1, thumbnail2, thumbnail3, thumbnail4, thumbnail8];
			dictRespostas[caixa5] = [thumbnail5, thumbnail6, thumbnail7, thumbnail8, thumbnail4];
			dictRespostas[caixa6] = [thumbnail5, thumbnail6, thumbnail7, thumbnail8, thumbnail4];
			dictRespostas[caixa7] = [thumbnail5, thumbnail6, thumbnail7, thumbnail8, thumbnail4];
			dictRespostas[caixa8] = [thumbnail5, thumbnail6, thumbnail7, thumbnail8, thumbnail4];
			dictRespostas[caixa9] = [thumbnail9];
			dictRespostas[caixa10] = [thumbnail12, thumbnail11, thumbnail10];
			dictRespostas[caixa11] = [thumbnail12, thumbnail11, thumbnail10];
			dictRespostas[caixa12] = [thumbnail12, thumbnail11, thumbnail10];
			dictRespostas[caixa13] = [thumbnail13];
			dictRespostas[caixa14] = [thumbnail14, thumbnail15];
			dictRespostas[caixa15] = [thumbnail14, thumbnail15];
			dictRespostas[caixa16] = [thumbnail16, thumbnail17];
			dictRespostas[caixa17] = [thumbnail16, thumbnail17];
			dictRespostas[caixa18] = [thumbnail18];
			dictRespostas[caixa19] = [thumbnail18];
			dictRespostas[caixa20] = [thumbnail18];
			dictRespostas[caixa21] = [thumbnail18];
			dictRespostas[caixa22] = [thumbnail13];
			dictRespostas[caixa23] = [thumbnail13];
			dictRespostas[caixa24] = [thumbnail13];
			dictRespostas[caixa25] = [thumbnail16, thumbnail17];
			dictRespostas[caixa26] = [thumbnail16, thumbnail17];
			dictRespostas[caixa27] = [thumbnail14, thumbnail15];
			dictRespostas[caixa28] = [thumbnail14, thumbnail15];
			dictRespostas[caixa29] = [thumbnail12, thumbnail11, thumbnail10];
			dictRespostas[caixa30] = [thumbnail9];
			dictRespostas[caixa31] = [thumbnail9];
			dictRespostas[caixa32] = [thumbnail9];
			
			dictImage = new Dictionary();
			dictCaixa = new Dictionary();
			
			for each (var caixa in caixas) dictCaixa[caixa] = null;
		}
		
		private function saveAIStatus():void
		{
			var object:Object = new Object();
			object.thumbs = new Object();
			object.caixas = new Object();
			object.imagens = new Object();
			
			// Transforma os Dictionary em Object
			for (var i:int = 1; i <= 18; i++) 
			{
				var thumb:MovieClip = this["thumbnail" + String(i)];
				object.thumbs[thumb.name] = new Object();
				if (dictImage[thumb] != null) object.thumbs[thumb.name].caixa = dictImage[thumb].name;
				else object.thumbs[thumb.name].caixa = "null";
				object.thumbs[thumb.name].visible = thumb.visible;
				object.thumbs[thumb.name].x = thumb.x;
				object.thumbs[thumb.name].y = thumb.y;
				
				var image:MovieClip = this["imagem" + String(i)];
				object.imagens[image.name] = new Object();
				object.imagens[image.name].visible = image.visible;
				object.imagens[image.name].x = image.x;
				object.imagens[image.name].y = image.y;
			}
			
			for (i = 1; i <= 32; i++) 
			{
				var caixa:MovieClip = this["caixa" + String(i)];
				object.caixas[caixa.name] = new Object();
				if (dictCaixa[caixa] != null) object.caixas[caixa.name].image = dictCaixa[caixa].name;
				else object.caixas[caixa.name].image = "null";
				object.caixas[caixa.name].visible = caixa.visible;
				object.caixas[caixa.name].x = caixa.x;
				object.caixas[caixa.name].y = caixa.y;
			}
			
			// Transforma o Array "alvosUsados" num Object
			var strAlvosUsados:String = "";
			for (i = 0; i < alvosUsados.length; i++) 
			{
				if (i == alvosUsados.length - 1) strAlvosUsados += (alvosUsados[i].name);
				else strAlvosUsados += (alvosUsados[i].name + ";");
			}
			
			object.alvosUsados = strAlvosUsados;
			object.movimentos = movimentos;
			object.acertos = acertos;
			object.lastGrupo = lastGrupo;
			object.grupoAtual = grupoAtual;
			object.grupoVisible = grupo.visible;
			if (lastCaixa1 != null) object.lastCaixa1 = lastCaixa1.name;
			else object.lastCaixa1 = "null";
			if (lastCaixa2 != null) object.lastCaixa2 = lastCaixa2.name;
			else object.lastCaixa2 = "null";
			if (lastCaixa3 != null) object.lastCaixa3 = lastCaixa3.name;
			else object.lastCaixa3 = "null";
			if (lastCaixa4 != null) object.lastCaixa4 = lastCaixa4.name;
			else object.lastCaixa4 = "null";
			
			statusAI = object;
			mementoSerialized = JSON.encode(statusAI);
			
			saveStatus();
		}
		
		private function restoreAIStatus(e:MouseEvent):void
		{
			statusAI = JSON.decode(mementoSerialized);
			alvosUsados.splice(0);
			
			// Transforma o Object "statusAI" em um Dictionary
			for (var i:int = 1; i <= 18; i++) 
			{
				var thumb:MovieClip = this["thumbnail" + String(i)];
				var image:MovieClip = this["imagem" + String(i)];
				
				if (statusAI.thumbs[thumb.name].caixa != "null") dictImage[thumb] = this[statusAI.thumbs[thumb.name].caixa];
				thumb.visible = statusAI.thumbs[thumb.name].visible;
				thumb.x = statusAI.thumbs[thumb.name].x;
				thumb.y = statusAI.thumbs[thumb.name].y;
				
				image.visible = statusAI.imagens[image.name].visible;
				image.x = statusAI.imagens[image.name].x;
				image.y = statusAI.imagens[image.name].y;
				
			}
			
			for (i = 1; i <= 32; i++) 
			{
				var caixa:MovieClip = this["caixa" + String(i)];
				if (statusAI.caixas[caixa.name].image != "null") dictCaixa[caixa] = this[statusAI.caixas[caixa.name].image];
				caixa.visible = statusAI.caixas[caixa.name].visible;
				caixa.x = statusAI.caixas[caixa.name].x;
				caixa.y = statusAI.caixas[caixa.name].y;
			}
			
			// Transforma o Object "statusAI.alvosUsados" em um Array
			var arrayAlvos:Array = String(statusAI.alvosUsados).split(";");
			for (i = 0; i < arrayAlvos.length; i++) 
			{
				alvosUsados.push(this[arrayAlvos[i]]);
			}
			
			movimentos = statusAI.movimentos;
			acertos = statusAI.acertos;
			lastGrupo = int(statusAI.lastGrupo);
			grupoAtual = int(statusAI.grupoAtual);
			grupo.visible = statusAI.grupoVisible;
			if (statusAI.lastCaixa1 != "null") lastCaixa1 = this[statusAI.lastCaixa1];
			if (statusAI.lastCaixa2 != "null") lastCaixa2 = this[statusAI.lastCaixa2];
			if (statusAI.lastCaixa3 != "null") lastCaixa3 = this[statusAI.lastCaixa3];
			if (statusAI.lastCaixa4 != "null") lastCaixa4 = this[statusAI.lastCaixa4];
			grupo.gotoAndStop(grupoAtual);
			setChildIndex(grupo, 1);
			
			verifyAICompletion();
		}
		
		private function reset(e:MouseEvent):void 
		{
			movimentos = acertos = lastGrupo = grupoAtual = 0;
			
			lastCaixa1 = null;
			lastCaixa2 = null;
			lastCaixa3 = null;
			lastCaixa4 = null;
			
			grupo.visible = false;
			
			feedbackCerto.visible = false;
			feedbackErrado.visible = false;
			
			finaliza.removeEventListener(MouseEvent.MOUSE_DOWN, finalizaExercicio);
			finaliza.alpha = 0.5;
			finaliza.buttonMode = false;
			
			//for (var i:int = 1; i <= 7; i++) this["texto" + String(i)].visible = false;
			//box1.visible = texto5.visible;
			
			for (var i:int = 1; i <= 18; i++) {
				this["thumbnail" + String(i)].removeEventListener(MouseEvent.MOUSE_DOWN, drag);
				this["imagem" + String(i)].removeEventListener(MouseEvent.MOUSE_DOWN, drag);
				this["thumbnail" + String(i)].addEventListener(MouseEvent.MOUSE_DOWN, drag);
				this["imagem" + String(i)].addEventListener(MouseEvent.MOUSE_DOWN, drag);
				this["thumbnail" + String(i)].visible = true;
				this["thumbnail" + String(i)].x = imagePositions[i].x;
				this["thumbnail" + String(i)].y = imagePositions[i].y;
				this["imagem" + String(i)].x = -100;
				this["thumbnail" + String(i)].gotoAndStop(1);
				this["imagem" + String(i)].visible = false;
			}
			
			for (i = 1; i <= 32; i++) {
				this["caixa" + String(i)].visible = false;
				this["caixa" + String(i)].enabled = true;
			}
			
			for (i = 1; i <= 8; i++) {
				this["grupo" + String(i)].barra.filters = [];
			}
			
			alvosUsados = new Array();
			
			for each (var caixa in caixas) caixa.alpha = 1;
			
			criaDict();
			
			saveAIStatus();
		}
		
		var caixa_origem = null;
		
		
		
		function drag(e:MouseEvent) :void {
			var i:int = 0;
			if (tweenX != null && tweenX.isPlaying) return;
			dragging = e.target as MovieClip;
			//lastWidth = dragging.width;
			//lastHeight = dragging.height;
			
			trace("drag --> " + dragging.name);
			if (dragging.name.slice(0, 6) == "imagem") {
				
				dragging = imageDict[dragging];
				
				caixa_origem = dictImage[dragging];
				alvo = caixa_origem;
				dragging.visible = true;
				dragging.x = mouseX;
				dragging.y = mouseY;
			}
			
			
			
			/*
			for each (var key in alvosUsados) {
				if (key == dictImage[dragging]) alvosUsados.splice(i);
				i++;
			}*/
			
			dragging.gotoAndStop(2);
			dragging.alpha = 0.5;
			setChildIndex(dragging, numChildren - 1);
			startX = dragging.x;
			startY = dragging.y;
			stage.addEventListener(MouseEvent.MOUSE_UP, drop);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			dragging.startDrag();
			
			for each (var caixa in caixas) caixa.alpha = 1;
		}
		
		function drop(e:MouseEvent) :void {
			dragging.alpha = 1;
			dragging.gotoAndStop(1);
			stage.removeEventListener(MouseEvent.MOUSE_UP, drop);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			dragging.stopDrag();
			
			var thumbnail_origem:DisplayObject = dragging;
			var caixa_destino:DisplayObject = alvo;
			var caixa_destino_preenchida:Boolean = (dictCaixa[caixa_destino] != null);
			var index:int;
			
			// ORIGEM: nada (biblioteca)
			if (caixa_origem == null) {
				
				// PARA: nada (vai para a biblioteca)
				if (caixa_destino == null) {
					// não faço nada
				}
				// PARA: caixa
				else {
					// adicionar a caixa de destino no vetor alvosUsados
					if (alvosUsados.indexOf(caixa_destino) == -1) alvosUsados.push(caixa_destino);
				}
			}
			// ORIGEM: caixa
			else {
				// PARA: nada (vai para a abiblioteca)
				if (caixa_destino == null) {
					// remover a caixa de origem do vetor alvosUsados
					index = alvosUsados.indexOf(caixa_origem);
					if (index != -1) alvosUsados.splice(index, 1);
					
				}
				// PARA: caixa
				else {
					
					// caixa_destino CONTÉM alguma imagem
					if (caixa_destino_preenchida) {
					}
					// caixa_destino NÃO contém imagem
					else {
						index = alvosUsados.indexOf(caixa_origem);
						if (index != -1) alvosUsados.splice(index, 1);
						
						alvosUsados.push(caixa_destino);
					}
				}
			}
			
			
			
			
			
			
			
			
			// DESTINO: alguma caixa
			if (alvo != null) {
				//thumbnailDict[dragging].width = alvo.width;
				//thumbnailDict[dragging].height = alvo.height;
				thumbnailDict[dragging].visible = true;
				dragging.visible = false;
				
				trace(dragging.name + " --> " + (dictImage[dragging] ? dictImage[dragging].name : null));
				
				// ORIGEM: biblioteca
				// luciano if (dictCaixa[alvo] == null && dictImage[dragging] == null) {
					trace("ORIGEM: biblioteca");
					movimentos++;
					thumbnailDict[dragging].x = alvo.x;
					thumbnailDict[dragging].y = alvo.y;
					//tweenX = new Tween(thumbnailDict[dragging], "x", None.easeNone, dragging.x, alvo.x, 0.2, true);
					//tweenY = new Tween(thumbnailDict[dragging], "y", None.easeNone, dragging.y, alvo.y, 0.2, true);
					dictCaixa[alvo] = dragging;
					dictImage[dragging] = alvo;
					
					// Verifica se soltou no alvo certo
					if (dictRespostas[alvo].indexOf(dictCaixa[alvo]) != -1) {
						alvo.enabled = false;
						thumbnailDict[dragging].buttonMode = false;
						thumbnailDict[dragging].removeEventListener(MouseEvent.MOUSE_DOWN, drag);
					} else {
						tweenX = new Tween(thumbnailDict[dragging], "x", None.easeNone, thumbnailDict[dragging].x, imagePositions[images.indexOf(dragging)].x, 0.2, true);
						tweenY = new Tween(thumbnailDict[dragging], "y", None.easeNone, thumbnailDict[dragging].y, imagePositions[images.indexOf(dragging)].y, 0.2, true);
						dictCaixa[alvo] = null;
						dictImage[dragging] = null;
						movimentos--;
					}
					
				// ORIGEM: alguma caixa
				/* luciano } else {
					
					//Alguma peça no alvo
					if (dictImage[dragging] == null) {
						//vindo da parte de baixo
						var posFinalDrag:Point = new Point(alvo.x, alvo.y);
						var imageAlvo:DisplayObject = dictCaixa[alvo];
						var posImagemCaixa:Point = imagePositions[images.indexOf(imageAlvo)];
						
						setChildIndex(imageAlvo, numChildren - 1);
						
						tweenX = new Tween(thumbnailDict[dragging], "x", None.easeNone, dragging.x, posFinalDrag.x, 0.2, true);
						tweenY = new Tween(thumbnailDict[dragging], "y", None.easeNone, dragging.y, posFinalDrag.y, 0.2, true);
						
						thumbnailDict[imageAlvo].visible = false;
						imageAlvo.visible = true;
						
						tweenX2 = new Tween(imageAlvo, "x", None.easeNone, alvo.x, posImagemCaixa.x, 0.2, true);
						tweenY2 = new Tween(imageAlvo, "y", None.easeNone, alvo.y, posImagemCaixa.y, 0.2, true);
						
						dictCaixa[alvo] = dragging;
						dictImage[dragging] = alvo;
						dictImage[imageAlvo] = null;
						
					} else {
						//vindo de alguma caixa
						if (dictCaixa[alvo] == null) {
							thumbnailDict[dragging].x = alvo.x;
							thumbnailDict[dragging].y = alvo.y;
							//tweenX = new Tween(thumbnailDict[dragging], "x", None.easeNone, dragging.x, alvo.x, 0.2, true);
							//tweenY = new Tween(thumbnailDict[dragging], "y", None.easeNone, dragging.y, alvo.y, 0.2, true);
							dictCaixa[dictImage[dragging]] = null;
							dictCaixa[alvo] = dragging;
							dictImage[dragging] = alvo;
							
						} else {
							var caixaDrag:DisplayObject = dictImage[dragging];
							imageAlvo = dictCaixa[alvo];
							
							setChildIndex(imageAlvo, numChildren - 1);
							
							tweenX = new Tween(thumbnailDict[dragging], "x", None.easeNone, thumbnailDict[dragging].x, alvo.x, 0.2, true);
							tweenY = new Tween(thumbnailDict[dragging], "y", None.easeNone, thumbnailDict[dragging].y, alvo.y, 0.2, true);
							
							//thumbnailDict[imageAlvo].width = lastWidth;
							//thumbnailDict[imageAlvo].height = lastHeight;
							
							tweenX2 = new Tween(thumbnailDict[imageAlvo], "x", None.easeNone, thumbnailDict[imageAlvo].x, caixaDrag.x, 0.2, true);
							tweenY2 = new Tween(thumbnailDict[imageAlvo], "y", None.easeNone, thumbnailDict[imageAlvo].y, caixaDrag.y, 0.2, true);
							
							dictCaixa[caixaDrag] = imageAlvo;
							dictImage[imageAlvo] = caixaDrag;
							
							dictCaixa[alvo] = dragging;
							dictImage[dragging] = alvo;
						}
					}
					
				}
			// DESTINO: biblioteca
			} else {
				var posFinal:Point = imagePositions[images.indexOf(dragging)];
				thumbnailDict[dragging].visible = false;
				if (dictImage[dragging] != null) {
					//vindo de alguma caixa
					tweenX = new Tween(dragging, "x", None.easeNone, dragging.x, posFinal.x, 0.2, true);
					tweenY = new Tween(dragging, "y", None.easeNone, dragging.y, posFinal.y, 0.2, true);
					
					finaliza.removeEventListener(MouseEvent.MOUSE_DOWN, finalizaExercicio);
					finaliza.alpha = 0.5;
					finaliza.buttonMode = false;
					movimentos--;
					
					caixaDrag = dictImage[dragging];
					dictCaixa[caixaDrag] = null;
					dictImage[dragging] = null;
				} else {
					//vindo do lugar inicial
					tweenX = new Tween(dragging, "x", None.easeNone, dragging.x, posFinal.x, 0.2, true);
					tweenY = new Tween(dragging, "y", None.easeNone, dragging.y, posFinal.y, 0.2, true);
				}*/
			} else { // luciano
				tweenX = new Tween(dragging, "x", None.easeNone, dragging.x, imagePositions[images.indexOf(dragging)].x, 0.2, true);
				tweenY = new Tween(dragging, "y", None.easeNone, dragging.y, imagePositions[images.indexOf(dragging)].y, 0.2, true);
				dictCaixa[alvo] = null;
				dictImage[dragging] = null;
			}
			
			removeFilter(null);
			
			alvo = null;
			
			verifyAICompletion();
			
			for each (var caixa in caixas) {
				if (alvosUsados.indexOf(caixa) != -1) caixa.alpha = 0;
				else caixa.alpha = 1;
			}
			
			caixa_origem = null;
			
			setTimeout(saveAIStatus, 0.3 * 1000);
		}
		
		private function verifyAICompletion():void
		{
			trace("movimentos: " + movimentos);
			
			if (movimentos == 18) {
				finaliza.alpha = 1;
				finaliza.buttonMode = true;
				finaliza.addEventListener(MouseEvent.MOUSE_DOWN, finalizaExercicio);
			}
		}
		
		private function finalizaExercicio(e:Event = null):void
		{
			acertos = 0;
			//for (var i:int = 1; i <= 7; i++) this["texto" + String(i)].visible = false;
			for (var i:int = 1; i <= 32; i++) if (dictRespostas[this["caixa" + String(i)]].indexOf(dictCaixa[this["caixa" + String(i)]]) != -1) {
				acertos++;
				//if (textDict[this["caixa" + String(i)]] != null) textDict[this["caixa" + String(i)]].visible = true;
			}
			
			//box1.visible = texto5.visible;
			
			trace("Terminou. " + String(acertos) + " acertos.");
			
			if (acertos == 18) feedbackCerto.visible = true;
			else feedbackErrado.visible = true;
			
			setChildIndex(feedbackCerto, numChildren - 1);
			setChildIndex(feedbackErrado, numChildren - 1);
			
			if(!completed){
				score = Math.floor((100 / 32) * acertos);
				completed = true;
				commit();
			}
			
			//finaliza.alpha = 0.5;
			//finaliza.buttonMode = false;
			//finaliza.removeEventListener(MouseEvent.MOUSE_DOWN, finalizaExercicio);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{	
			var peca:MovieClip;
			//alvo = null;
			
			loopForTest: for (var i:int = 1; i <= 32; i++) {
				
				peca = this["caixa" + String(i)];
				//if (peca == dragging) continue;
				
				if (peca.hitTestPoint(dragging.x, dragging.y) && peca.visible && peca.enabled) {
					if (peca.filters.length == 0) peca.filters = [GLOW_FILTER];
					//setChildIndex(peca, Math.max(0, getChildIndex(dragging) - 1));
					removeFilter(peca);
					alvo = MovieClip(peca);
					//break loopForTest;
					return;
				} else {
					peca.filters = [];
				}
			}
			
			alvo = null;
		}
		
		private function removeFilter(peca:DisplayObject):void
		{
			var pecaSemFiltro:DisplayObject;
			for (var i:int = 1; i <= 32; i++) {
				pecaSemFiltro = this["caixa" + String(i)];
				if (peca != pecaSemFiltro/* && peca is Caixa*/) (pecaSemFiltro as Caixa).filters = [];
			}
		}
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:Number = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		private var caixas:Array;
		private var textDict:Dictionary;
		private var statusAI:Object;
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				// Verifica se a AI já foi concluída.
				scorm.set("cmi.exit", "suspend");
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = String(scorm.get("cmi.suspend_data"));
				var stringScore:String = scorm.get("cmi.score.raw");
			 
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				//txNota.text = score.toFixed(1).replace(".", ",");
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
				mementoSerialized = ExternalInterface.call("getLocalStorageString");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit():void
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				//success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}else { //LocalStorage
				ExternalInterface.call("save2LS", mementoSerialized);
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent):void
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
		private function saveStatus():void
		{
			if (ExternalInterface.available) {
				if (connected) {
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
	}

}