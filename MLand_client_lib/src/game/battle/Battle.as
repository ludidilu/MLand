package game.battle
{
	import com.greensock.TweenLite;
	import com.greensock.easing.ElasticIn;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import connect.Connect;
	
	import csv.Csv;
	
	import data.csv.Csv_hero;
	import data.csv.Csv_map;
	import data.map.Map;
	import data.map.MapUnit;
	import data.resource.ResourceFont;
	import data.resource.ResourcePublic;
	
	import game.Game;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class Battle extends Sprite
	{
		public static const MAX_CARDS_NUM:int = 5;
		public static const MONEY_NUM:int = 5;
		public static const POWER_CAN_MOVE:int = 1;
		
		private static const CARD_WIDTH:int = 64;
		private static const CARD_HEIGHT:int = 80;
		private static const CARD_GAP:int = 5;
		
		public var gameContainerScale:Number = 0.9;
		
		private var gameContainer:Sprite;
		private var battleMap:BattleMap;
		private var heroContainer:Sprite;
		private var arrowContainer:Sprite;
		private var effectContainer:Sprite;
		private var cardContainer:Sprite;
		private var uiContainer:Sprite;
		private var moneyContainer:Sprite;
		private var heroDetailContainer:Sprite;
		private var btContainer:Sprite;
		private var alertContainer:Sprite;
		
		internal var isHost:Boolean;
		private var mapUnit:MapUnit;
		private var mapData:Dictionary;
		
		internal var money:int;
		
		internal var summonDic:Dictionary;
		internal var nowChooseCard:BattleCard;
		
		internal var moveDic:Dictionary;
		internal var moveResultDic:Dictionary;
		
		private var myAllCardsNum:int;
		private var oppAllCardsNum:int;
		private var oppCardsNum:int;
		
		private var myScore:int;
		private var oppScore:int;
		
		private var nowRound:int;
		private var maxRound:int;
		
		internal var canMoveData:Vector.<int>;
		private var myCards:Vector.<BattleCard>;
		
		internal var heroData:Dictionary;
		
		internal var isActioned:Boolean;
		private var isPlayBattle:Boolean;
		
		private var playBattleOverCallBack:Function;
		private var playBattleOverCallBackArg:Array;
		
		private var actionBt:Button;
		private var quitBt:Button;
		
		private var roundTf:TextField;
		private var scoreTf:TextField;
		private var myMoneyTf:TextField;
		private var oppCardsNumTf:TextField;
		private var myAllCardsNumTf:TextField;
		private var oppAllCardsNumTf:TextField;
		private var alertTf:TextField;
		
		private var heroDetailPanel:BattleHeroDetailPanel;
		
		private var moneyIsTrembling:Boolean;
		
		private var cardTouchMoveFun:Function;
		
		public static var instance:Battle;
		
		private var tmpRect:Rectangle = new Rectangle;
		private var tmpPoint:Point = new Point;
		private var tmpPoint2:Point = new Point;
		
		public function Battle()
		{
			super();
			
			instance = this;
			
			gameContainer = new Sprite;
			
			gameContainer.scaleX = gameContainer.scaleY = gameContainerScale;
			
			addChild(gameContainer);
			
			battleMap = new BattleMap;
			
			gameContainer.addChild(battleMap);
			
			heroContainer = new Sprite;
			
			heroContainer.touchable = false;
			
			gameContainer.addChild(heroContainer);
			
			arrowContainer = new Sprite;
			
			arrowContainer.touchable = false;
			
			gameContainer.addChild(arrowContainer);
			
			effectContainer = new Sprite;
			
			effectContainer.touchable = false;
			
			gameContainer.addChild(effectContainer);
			
			cardContainer = new Sprite;
			
			addChild(cardContainer);
			
			uiContainer = new Sprite;
			
			uiContainer.touchable = false;
			
			addChild(uiContainer);
			
			oppCardsNumTf = new TextField(150,30,"",ResourceFont.fontName,16);
			oppCardsNumTf.hAlign = HAlign.LEFT;
			oppCardsNumTf.x = Starling.current.backBufferWidth - 30 - oppCardsNumTf.width;
			oppCardsNumTf.y = Starling.current.backBufferHeight - 150 - oppCardsNumTf.height;
			
			uiContainer.addChild(oppCardsNumTf);
			
			myAllCardsNumTf = new TextField(150,30,"",ResourceFont.fontName,16);
			myAllCardsNumTf.hAlign = HAlign.LEFT;
			myAllCardsNumTf.x = Starling.current.backBufferWidth - 30 - myAllCardsNumTf.width;
			myAllCardsNumTf.y = Starling.current.backBufferHeight - 110 - myAllCardsNumTf.height;
			
			uiContainer.addChild(myAllCardsNumTf);
			
			oppAllCardsNumTf = new TextField(150,30,"",ResourceFont.fontName,16);
			oppAllCardsNumTf.hAlign = HAlign.LEFT;
			oppAllCardsNumTf.x = Starling.current.backBufferWidth - 30 - oppAllCardsNumTf.width;
			oppAllCardsNumTf.y = Starling.current.backBufferHeight - 70 - oppAllCardsNumTf.height;
			
			uiContainer.addChild(oppAllCardsNumTf);
			
			scoreTf = new TextField(150,30,"",ResourceFont.fontName,16);
			scoreTf.hAlign = HAlign.LEFT;
			scoreTf.x = Starling.current.backBufferWidth - 30 - scoreTf.width;
			scoreTf.y = Starling.current.backBufferHeight - 190 - scoreTf.height;
			
			uiContainer.addChild(scoreTf);
			
			roundTf = new TextField(150,30,"",ResourceFont.fontName,16);
			roundTf.hAlign = HAlign.LEFT;
			roundTf.x = Starling.current.backBufferWidth - 30 - roundTf.width;
			roundTf.y = Starling.current.backBufferHeight - 230 - roundTf.height;
			
			uiContainer.addChild(roundTf);
			
			
			moneyContainer = new Sprite;
			
			moneyContainer.touchable = false;
			
			addChild(moneyContainer);
			
			myMoneyTf = new TextField(150,30,"",ResourceFont.fontName,16);
			myMoneyTf.hAlign = HAlign.LEFT;
			myMoneyTf.x = Starling.current.backBufferWidth - 30 - myMoneyTf.width;
			myMoneyTf.y = Starling.current.backBufferHeight - 270 - myMoneyTf.height;
			
			moneyContainer.addChild(myMoneyTf);
			
			
			
			heroDetailContainer = new Sprite;
			
			heroDetailPanel = new BattleHeroDetailPanel;
			
			heroDetailPanel.visible = false;
			
			heroDetailContainer.addChild(heroDetailPanel);
			
			addChild(heroDetailContainer);
			
			btContainer = new Sprite;
			
			addChild(btContainer);
			
			actionBt = new Button(Texture.fromColor(150,30,0xFFFF0000));
			
			actionBt.x = Starling.current.backBufferWidth - 30 - actionBt.width;
			actionBt.y = Starling.current.backBufferHeight - 30 - actionBt.height;
			
			actionBt.addEventListener(Event.TRIGGERED,btClick);
			
			btContainer.addChild(actionBt);
			
			quitBt = new Button(Texture.fromColor(150,30,0xFFFF0000));
			
			quitBt.x = Starling.current.backBufferWidth - 30 - quitBt.width;
			quitBt.y = 50;
			
			quitBt.addEventListener(Event.TRIGGERED,quitBattle);
			
			btContainer.addChild(quitBt);
			
			alertContainer = new Sprite;
			
			addChild(alertContainer);
			
			var sp:Sprite = new Sprite;
			
			var quad:starling.display.Quad = new starling.display.Quad(Starling.current.backBufferWidth,Starling.current.backBufferHeight,0x0);
			
			quad.alpha = 0.3;
			
			sp.addChild(quad);
			
			quad = new starling.display.Quad(400,300,0xFFFF0000);
			
			quad.x = (Starling.current.backBufferWidth - quad.width) * 0.5;
			quad.y = (Starling.current.backBufferHeight - quad.height) * 0.5;
			
			sp.addChild(quad);
			
			sp.flatten();
			
			alertContainer.addChild(sp);
			
			alertTf = new TextField(400,300,"",ResourceFont.fontName,24);
			
			alertTf.x = (Starling.current.backBufferWidth - alertTf.width) * 0.5;
			alertTf.y = (Starling.current.backBufferHeight - alertTf.height) * 0.5;
			
			alertContainer.addChild(alertTf);
			
			alertContainer.visible = false;
			
			alertContainer.addEventListener(TouchEvent.TOUCH,alertContainerBeTouch);
		}
		
		public function start(_isHost:Boolean,_nowRound:int,_maxRound:int,_mapID:int,_mapData:Vector.<int>,_myCards:Vector.<Vector.<int>>,_oppCardsNum:int,_userAllCardsNum1:int,_userAllCardsNum2:int,_heroData:Vector.<Vector.<int>>,_canMoveData:Vector.<int>,_isActioned:Boolean,_actionHeroData:Vector.<Vector.<int>>,_actionSummonData:Vector.<Vector.<int>>):void{
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			
			isHost = _isHost;
			mapUnit = Map.getMap(_mapID);
			
			nowRound = _nowRound;
			maxRound = _maxRound;
			
			canMoveData = _canMoveData;
			
			mapData = new Dictionary;
			
			summonDic = new Dictionary;
			
			moveDic = new Dictionary;
			
			myScore = oppScore = 0;
			
			for(var str:String in mapUnit.dic){
				
				var pos:int = int(str);
				
				if(isHost){
					
					if(_mapData.indexOf(pos) != -1){
						
						myScore++;
						
						mapData[pos] = 1;
						
					}else{
						
						oppScore++;
						
						mapData[pos] = 2;
					}
					
				}else{
					
					if(_mapData.indexOf(pos) != -1){
						
						oppScore++;
						
						mapData[pos] = 2;
						
					}else{
						
						myScore++;
						
						mapData[pos] = 1;
					}
				}
			}
			
			var csvMap:Csv_map = Csv.getData(Csv_map.NAME,_mapID) as Csv_map;
			
			battleMap.start(mapUnit,mapData,csvMap.flipType);
			
			gameContainer.x = (Starling.current.backBufferWidth - battleMap.mapContainer.width * gameContainerScale) * 0.5;
			gameContainer.y = (Starling.current.backBufferHeight - battleMap.mapContainer.height * gameContainerScale - 80) * 0.5;
			
			if(_isHost){
				
				myAllCardsNum =_userAllCardsNum1;
				oppAllCardsNum = _userAllCardsNum2;
				
			}else{
				
				myAllCardsNum =_userAllCardsNum2;
				oppAllCardsNum = _userAllCardsNum1;
			}
			
			oppCardsNum = _oppCardsNum;
			
			refreshUIContainer();
			
			money = MONEY_NUM;
			
			refreshMoneyTf();
			
			if(_myCards != null){
				
				myCards = new Vector.<BattleCard>(_myCards.length);
				
				for(var i:int = 0 ; i < _myCards.length ; i++){
					
					var battleCard:BattleCard = new BattleCard(_myCards[i][1]);
					
					battleCard.uid = _myCards[i][0];
					
					cardContainer.addChild(battleCard);
					
					myCards[i] = battleCard;
				}
				
				refreshCards();
				
			}else{
				
				myCards = new Vector.<BattleCard>();
			}
			
			heroData = new Dictionary;
			
			if(_heroData != null){
				
				for(i = 0 ; i < _heroData.length ; i++){
					
					var hero:BattleHero = new BattleHero;
					
					var vec:Vector.<int> = _heroData[i];
					
					hero.pos = vec[0];
					
					if(mapData[hero.pos] == 1){
						
						hero.isMine = true;
						
					}else{
						
						hero.isMine = false;
					}
					
					hero.csv = Csv.getData(Csv_hero.NAME,vec[1]) as Csv_hero;
					
					hero.hp = vec[2];
					
					hero.power = vec[3];
					
					hero.refresh(true);
					
					heroData[hero.pos] = hero;
					
					heroContainer.addChild(hero);
					
					var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[hero.pos];
					
					hero.x = tmpBattleMapUnit.x;
					hero.y = tmpBattleMapUnit.y;
				}
			}
			
			isActioned = _isActioned;
			
			if(isActioned){
				
				if(_actionHeroData != null){
					
					for(i = 0 ; i < _actionHeroData.length ; i++){
						
						pos = _actionHeroData[i][0];
						var target:int = BattlePublic.getTargetPos(mapUnit.mapWidth,pos,_actionHeroData[i][1]);
						
						moveDic[pos] = target;
					}
					
					money = money - _actionHeroData.length;
					
					refreshMoneyTf();
				}
				
				if(_actionSummonData != null){
					
					for(i = 0 ; i < _actionSummonData.length ; i++){
						
						var uid:int = _actionSummonData[i][0];
						target = _actionSummonData[i][1];
						
						for(var m:int = 0 ; m < myCards.length ; m++){
							
							if(myCards[m].uid == uid){
								
								nowChooseCard = myCards[m];
								
								break;
							}
						}
						
						summon(target);
					}
					
					nowChooseCard = null;
				}
				
				refreshMove();
				
				actionBt.enabled = false;
			}
		}
		
		private function refreshCards():void{
			
			var startX:Number = (Starling.current.backBufferWidth - myCards.length * CARD_WIDTH - (myCards.length - 1) * CARD_GAP) * 0.5;
			
			for(var i:int = 0 ; i < myCards.length ; i++){
				
				var card:BattleCard = myCards[i];
				
				card.setIsSummoned(false);
				
				card.y = Starling.current.backBufferHeight - CARD_HEIGHT * 0.5;
				
				card.x = startX + i * (CARD_WIDTH + CARD_GAP) + CARD_WIDTH * 0.5;
			}
		}
		
		public function get gameContainerX():Number{
			
			return gameContainer.x;
		}
		
		public function set gameContainerX(value:Number):void{
			
			gameContainer.x = value;
		}
		
		public function get gameContainerY():Number{
			
			return gameContainer.y;
		}
		
		public function set gameContainerY(value:Number):void{
			
			gameContainer.y = value;
		}
		
		public function cardTouchBegin(_card:BattleCard):void{
			
			tmpPoint.x = _card.x;
			tmpPoint.y = _card.y;
			
			_card.parent.localToGlobal(tmpPoint,tmpPoint2);
			
			showHeroDetail(tmpPoint2.x,tmpPoint2.y,_card.heroCsv.id);
			
			clearNowChooseCard();
			
			if(myCards.indexOf(_card) != -1){
				
				_card.y = _card.y - 20;
				
				battleMap.clearSelectedUnit();
				
				if(!isActioned){
					
					cardTouchMoveFun = cardMove0;
				}
				
			}else{
				
				for(var str:String in summonDic){
					
					var card:BattleCard = summonDic[str];
					
					if(card == _card){
						
						battleMap.setSelectedUnit(battleMap.dic[str]);
						
						break;
					}
				}
				
				if(!isActioned){
					
					battleMap.moveFun = cardMove0;
				}
			}
			
			nowChooseCard = _card;
		}
		
		public function cardTouchMove(_card:BattleCard,_globalX:Number,_globalY:Number):void{
			
			if(cardTouchMoveFun != null){
				
				cardTouchMoveFun(_globalX,_globalY);
			}
		}
		
		public function cardTouchEnd(_card:BattleCard,_globalX:Number,_globalY:Number):void{
			
			if(cardTouchMoveFun == cardMove0){
				
				cardTouchMoveFun = null;
				
			}else if(cardTouchMoveFun == cardMove1){
				
				cardTouchMoveFun = null;
				
				var unit:BattleMapUnit = battleMap.getSelectedUnit();
				
				if(unit != null){
					
					summon(unit.id);
					
					battleMap.clearSelectedUnit();
					
				}else{
					
					myCards.push(nowChooseCard);
					
					refreshCards();
				}
				
				nowChooseCard = null;
				
			}else if(battleMap.moveFun == cardMove0){
				
				battleMap.moveFun = null;
				
			}else if(battleMap.moveFun == cardMove1){
				
				battleMap.moveFun = null;
				
				unit = battleMap.getSelectedUnit();
				
				if(unit != null){
					
					summon(unit.id);
					
					battleMap.clearSelectedUnit();
					
				}else{
					
					myCards.push(nowChooseCard);
					
					refreshCards();
				}
				
				nowChooseCard = null;
			}
		}
		
		private function cardMove0(_globalX:Number,_globalY:Number):void{
			
			nowChooseCard.getBounds(this,tmpRect);
			
			if(_globalX < tmpRect.left || _globalX > tmpRect.right || _globalY > tmpRect.bottom || _globalY < tmpRect.top){
				
				if(cardTouchMoveFun == cardMove0){//从手里拉出来的
					
					if(money >= nowChooseCard.heroCsv.star){
						
						myCards.splice(myCards.indexOf(nowChooseCard),1);
						
						refreshCards();
						
						cardTouchMoveFun = cardMove1;
						
					}else{
						
						moneyTremble();
						
						cardTouchMoveFun = null;
					}
					
				}else{
					
					for(var str:String in summonDic){
						
						var card:BattleCard = summonDic[str];
						
						if(card == nowChooseCard){
							
							delete summonDic[str];
							
							break;
						}
					}
					
					heroContainer.removeChild(nowChooseCard);
					
					nowChooseCard.x = _globalX;
					nowChooseCard.y = _globalY;
					
					cardContainer.addChild(nowChooseCard);
					
					money = money + nowChooseCard.heroCsv.star;
					
					refreshMoneyTf();
					
					battleMap.moveFun = cardMove1;
					
					refreshMove();
				}
			}
		}
		
		public function cardMove1(_globalX:Number,_globalY:Number):void{
			
			hideHeroDetail();
			
			battleMap.clearSelectedUnit();
			
			nowChooseCard.x = _globalX;
			nowChooseCard.y = _globalY;
			
			var battleMapUnit:BattleMapUnit = battleMap.getTouchUnit(_globalX,_globalY);
			
			if(battleMapUnit != null){
				
				if(mapData[battleMapUnit.id] == 1 && heroData[battleMapUnit.id] == null && summonDic[battleMapUnit.id] == null){
					
					var b:Boolean = true;
					
					var tmpPosVec:Vector.<int> = mapUnit.neightbourDic[battleMapUnit.id];
					
					for each(var tmpPos:int in tmpPosVec){
						
						if(mapData[tmpPos] == 2 && heroData[tmpPos] != null && canMoveData != null && canMoveData.indexOf(tmpPos) != -1){
							
							b = false;
							
							break;
						}
					}
					
					if(b){
						
						battleMap.setSelectedUnit(battleMapUnit);
					}
				}
			}
		}
		
		public function clearNowChooseCard():void{
			
			if(nowChooseCard != null){
				
				if(myCards.indexOf(nowChooseCard) != -1){
					
					nowChooseCard.y = nowChooseCard.y + 20;
				}
				
				nowChooseCard = null;
			}
		}
		
		public function summon(_pos:int):void{
			
			money = money - nowChooseCard.heroCsv.star;
			
			refreshMoneyTf();
			
			var index:int = myCards.indexOf(nowChooseCard);
			
			if(index != -1){
				
				myCards.splice(index,1);
				
				refreshCards();
			}
			
			cardContainer.removeChild(nowChooseCard);
			
			summonDic[_pos] = nowChooseCard;
			
			heroContainer.addChild(nowChooseCard);
			
			nowChooseCard.setIsSummoned(true);
			
			var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[_pos];
			
			nowChooseCard.x = tmpBattleMapUnit.x;
			nowChooseCard.y = tmpBattleMapUnit.y;
			
			nowChooseCard = null;
			
			refreshMove();
			
			hideHeroDetail();
		}
		
		public function heroMove(_hero:BattleHero,_target:int):void{
			
			if(_hero.pos in moveDic){
				
				if(_target == -1){
					
					delete moveDic[_hero.pos];
					
					money = money + 1;
					
					refreshMoneyTf();
					
					refreshMove();
					
				}else{
					
					var target:int = moveDic[_hero.pos];
					
					if(target != _target){
						
						//						var vec:Vector.<int> = BattlePublic.getNeighbourPosVec(mapUnit.mapWidth,mapUnit.size,mapUnit.dic,_hero.pos);
						
						var vec:Vector.<int> = mapUnit.neightbourDic[_hero.pos];
						
						if(vec.indexOf(_target) != -1){
							
							moveDic[_hero.pos] = _target;
							
						}else{
							
							delete moveDic[_hero.pos];
							
							money = money + 1;
							
							refreshMoneyTf();
						}
						
						refreshMove();
					}
				}
				
			}else{
				
				if(_target != -1){
					
					vec = mapUnit.neightbourDic[_hero.pos];
					
					//					vec = BattlePublic.getNeighbourPosVec(mapUnit.mapWidth,mapUnit.size,mapUnit.dic,_hero.pos);
					
					if(vec.indexOf(_target) != -1){
						
						money = money - 1;
						
						refreshMoneyTf();
						
						moveDic[_hero.pos] = _target;
						
						refreshMove();
					}
				}
			}
		}
		
//		private function checkHeroCanMoveToPos(_hero:BattleHero,_target:int):Boolean{
//			
//			var vec:Vector.<int> = mapUnit.neightbourDic[_hero.pos];
//			
//			if(vec.indexOf(_target) != -1){
//				
//				var hero:BattleHero = heroData[_target];
//				
//				if(hero != null){
//					
//					if(!hero.isMine){
//						
//						return false;
//						
//					}else{
//						
//						
//						
//					}
//					
//				}
//				
//				return true;
//				
//			}else{
//				
//				return false;
//			}
//		}
		
		private function refreshMove():void{
			
			arrowContainer.unflatten();
			
			arrowContainer.removeChildren();
			
			checkMove();
			
			for(var str:String in moveDic){
				
				var pos:int = int(str);
				
				var target:int = moveDic[str];
				
				var sp:Sprite = new Sprite;
				
				if(moveResultDic[str] == 0){
					
					var picName:String = "greenArrow";
					
				}else if(moveResultDic[str] == 1){
					
					picName = "yellowArrow";
					
				}else{
					
					picName = "redArrow";
				}
				
				var img:Image = new Image(ResourcePublic.getTexture(picName));
				
				img.x = -0.5 * img.width + 15;
				img.y = -0.5 * img.height;
				
				sp.addChild(img);
				
				arrowContainer.addChild(sp);
				
				var tmpBattleMapUnit0:BattleMapUnit = battleMap.dic[pos];
				
				var tmpBattleMapUnit1:BattleMapUnit = battleMap.dic[target];
				
				sp.x = (tmpBattleMapUnit0.x + tmpBattleMapUnit1.x) * 0.5;
				sp.y = (tmpBattleMapUnit0.y + tmpBattleMapUnit1.y) * 0.5;
				
				sp.rotation = Math.atan2(tmpBattleMapUnit1.y - tmpBattleMapUnit0.y,tmpBattleMapUnit1.x - tmpBattleMapUnit0.x);
			}
			
			for each(var hero:BattleHero in heroData){
				
				if(hero.isMine){
					
					hero.refresh(true);
				}
			}
			
			arrowContainer.flatten();
		}
		
		private function checkMove():void{
			
			moveResultDic = new Dictionary;
			
			var targetDic:Dictionary = new Dictionary;
			
			for each(var target:int in moveDic){
				
				if(targetDic[target] == null){
					
					targetDic[target] = 1;
					
				}else{
					
					targetDic[target] = 2;
				}
			}
			
			for(var str:String in moveDic){
				
				target = moveDic[str];
				
				if(targetDic[target] == 2){
					
					moveResultDic[str] = 2;
					
				}else if(summonDic[target] != null){
					
					if(moveDic[target] == null){
						
						moveResultDic[str] = 2;
					}
					
				}else if(mapData[target] == 2){
					
					var hero:BattleHero = heroData[target];
					
					if(hero != null){
						
						moveResultDic[str] = 2;
						
					}else{
						
						var b:Boolean = true;
						
						var tmpPosVec:Vector.<int> = mapUnit.neightbourDic[target];
						
						for each(var tmpPos:int in tmpPosVec){
							
							if(mapData[tmpPos] == 2 && heroData[tmpPos] != null && canMoveData.indexOf(tmpPos) != -1){
								
								moveResultDic[str] = 2;
								
								b = false;
								
								break;
							}
						}
						
						if(b){
							
							moveResultDic[str] = 0;
						}
					}
					
				}else if(heroData[target] == null){
					
					moveResultDic[str] = 0;
					
				}else{
					
					if(moveDic[target] == null){
						
						moveResultDic[str] = 2;
					}
				}
			}
			
			for(str in moveDic){
				
				if(moveResultDic[str] == null){
					
					var pos:int = int(str);
					
					var vec:Vector.<int> = new Vector.<int>;
					
					vec.push(pos);
					
					var result:int;
					
					while(true){
						
						target = moveDic[pos];
						
						if(moveResultDic[target] != null){
							
							result = moveResultDic[target];
							
							break;
							
						}else if(vec.indexOf(target) != -1){
							
							result = 0
							
							break;
							
						}else{
							
							vec.push(target);
							
							pos = target;
						}
					}
					
					for each(pos in vec){
						
						moveResultDic[pos] = result;
					}
				}
			}
		}
		
		private function btClick(e:Event):void{
			
			for each(var result:int in moveResultDic){
				
				if(result == 2){
					
					return;
				}
			}
			
			if(nowChooseCard != null){
				
				clearNowChooseCard();
			}
			
			isActioned = true;
			
			var moveData:Vector.<Vector.<int>>;
			
			for(var str:String in moveDic){
				
				if(moveData == null){
					
					moveData = new Vector.<Vector.<int>>;
				}
				
				var pos:int = int(str);
				
				var target:int = moveDic[str];
				
				moveData.push(Vector.<int>([pos, BattlePublic.getDirect(mapUnit.mapWidth,pos,target)]));
			}
			
			var summonData:Vector.<Vector.<int>>;
			
			for(str in summonDic){
				
				if(summonData == null){
					
					summonData = new Vector.<Vector.<int>>;
				}
				
				pos = int(str);
				
				var card:BattleCard = summonDic[str];
				
				summonData.push(Vector.<int>([card.uid, pos]));
			}
			
			Connect.sendData(11,sendBattleActionOK,moveData,summonData);
		}
		
		public function sendBattleActionOK(_result:Boolean):void{
			
			if(_result){
				
				actionBt.enabled = false;
			}
		}
		
		public function playBattle(_summonData1:Vector.<Vector.<int>>,_summonData2:Vector.<Vector.<int>>,_moveData:Vector.<Vector.<int>>,_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			isPlayBattle = true;
			
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			
			battleMap.clearSelectedUnit();
			
			for each(var hero:BattleHero in heroData){
				
				hero.refresh(false);
			}
			
			hideHeroDetail();
			
			Starling.current.touchable = false;
			
			for each(var card:BattleCard in summonDic){
				
				heroContainer.removeChild(card);
			}
			
			summonDic = new Dictionary;
			
			moveDic = new Dictionary;
			
			moveResultDic = new Dictionary;
			
			arrowContainer.unflatten();
			
			arrowContainer.removeChildren();
			
			arrowContainer.flatten();
			
			startSummon(_summonData1,_summonData2,_moveData,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
		}
		
		private function startSummon(_summonData1:Vector.<Vector.<int>>,_summonData2:Vector.<Vector.<int>>,_moveData:Vector.<Vector.<int>>,_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			if(_summonData1 != null && _summonData1.length > 0){
				
				var pos:int = _summonData1[0][2];
				
				var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[pos];
				
				moveGameContainerToCenter(tmpBattleMapUnit.x,tmpBattleMapUnit.y,startSummonReal,_summonData1,_summonData2,_moveData,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
				
			}else if(_summonData2 != null && _summonData2.length > 0){
				
				pos = _summonData2[0][2];
				
				tmpBattleMapUnit = battleMap.dic[pos];
				
				moveGameContainerToCenter(tmpBattleMapUnit.x,tmpBattleMapUnit.y,startSummonReal,_summonData1,_summonData2,_moveData,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
				
			}else{
				
				startMove(_moveData,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
			}
		}
		
		private function startSummonReal(_summonData1:Vector.<Vector.<int>>,_summonData2:Vector.<Vector.<int>>,_moveData:Vector.<Vector.<int>>,_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			if(isHost){
				
				if(_summonData1 != null && _summonData1.length > 0){
					
					var vec:Vector.<int> = _summonData1.shift();
					
					var hero:BattleHero = new BattleHero;
					
					hero.isMine = true;
					
				}else{
					
					vec = _summonData2.shift();
					
					hero = new BattleHero;
					
					hero.isMine = false;
					
					oppCardsNum--;
					
					refreshUIContainer();
				}
				
			}else{
				
				if(_summonData2 != null && _summonData2.length > 0){
					
					vec = _summonData2.shift();
					
					hero = new BattleHero;
					
					hero.isMine = true;
					
				}else{
					
					vec = _summonData1.shift();
					
					hero = new BattleHero;
					
					hero.isMine = false;
					
					oppCardsNum--;
					
					refreshUIContainer();
				}
			}
			
			hero.pos = vec[2];
			
			hero.csv = Csv.getData(Csv_hero.NAME,vec[1]) as Csv_hero;
			
			hero.hp = hero.csv.maxHp;
			
			hero.power = hero.csv.maxPower;
			
			hero.refresh(false);
			
			heroData[hero.pos] = hero;
			
			heroContainer.addChild(hero);
			
			var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[hero.pos];
			
			hero.x = tmpBattleMapUnit.x;
			hero.y = tmpBattleMapUnit.y;
			
			hero.scaleX = hero.scaleY = 5;
			
			//			TweenLite.to(hero,0.5,{scaleX:1,scaleY:1,ease:Quad.easeIn,onComplete:startSummon,onCompleteParams:[_summonData1,_summonData2,_moveData,_skillData,_attackData,_cardUid,_cardID,_canMoveData]});
			
			TweenLite.to(hero,0.5,{scaleX:1,scaleY:1,ease:com.greensock.easing.Quad.easeIn,onComplete:delayCall,onCompleteParams:[0.5,startSummon,[_summonData1,_summonData2,_moveData,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]]});
		}
		
		private function startMove(_moveData:Vector.<Vector.<int>>,_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			if(_moveData == null || _moveData.length == 0){
				
				startSkill(_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
				
			}else{
				
				var vec:Vector.<int> = _moveData.shift();
				
				var pos:int = vec[0];
				var target:int = vec[1];
				
				var dic:Dictionary = new Dictionary;
				
				dic[pos] = target;
				
				var dic2:Dictionary = new Dictionary;
				
				dic2[target] = pos;
				
				while(true){
					
					var hasMoveUnit:Boolean = false;
					
					for(var i:int = 0 ; i < _moveData.length ; i++){
						
						vec = _moveData[i];
						
						pos = vec[0];
						target = vec[1];
						
						if(dic[target] != null || dic2[pos] != null){
							
							_moveData.splice(i,1);
							
							dic[pos] = target;
							dic2[target] = pos;
							
							hasMoveUnit = true;
							
							break;
						}
					}
					
					if(!hasMoveUnit){
						
						break;
					}
				}
				
				var heroVec:Vector.<BattleHero> = new Vector.<BattleHero>;
				
				var _x:Number = 0;
				var _y:Number = 0;
				
				for(var str:String in dic){
					
					pos = int(str);
					target = dic[str];
					
					var hero:BattleHero = heroData[pos];
					
					canMoveData.splice(canMoveData.indexOf(pos),1);
					
					delete heroData[pos];
					
					hero.pos = target;
					
					heroVec.push(hero);
					
					var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[pos];
					
					_x = _x + tmpBattleMapUnit.x;
					_y = _y + tmpBattleMapUnit.y;
				}
				
				_x = _x / heroVec.length;
				_y = _y / heroVec.length;
				
				moveGameContainerToCenter(_x,_y,startMoveReal,_moveData,_skillData,_attackData,_cardUid,_cardID,heroVec,_oppCardID,_canMoveData);
			}
		}
		
		private function startMoveReal(_moveData:Vector.<Vector.<int>>,_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_heroVec:Vector.<BattleHero>,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var hasAddCallBack:Boolean = false;
			
			for each(var hero:BattleHero in _heroVec){
				
				var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[hero.pos];
				
				if(!hasAddCallBack){
					
					hasAddCallBack = true;
					
					TweenLite.to(hero,0.5,{ease:Linear.easeNone,x:tmpBattleMapUnit.x,y:tmpBattleMapUnit.y,onComplete:moveComplete,onCompleteParams:[_moveData,_skillData,_attackData,_cardUid,_cardID,_heroVec,_oppCardID,_canMoveData]});
					
				}else{
					
					TweenLite.to(hero,0.5,{ease:Linear.easeNone,x:tmpBattleMapUnit.x,y:tmpBattleMapUnit.y});
				}
			}
		}
		
		private function moveComplete(_moveData:Vector.<Vector.<int>>,_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_heroVec:Vector.<BattleHero>,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			for each(var hero:BattleHero in _heroVec){
				
				heroData[hero.pos] = hero;
				
				if(mapData[hero.pos] == 1 && !hero.isMine){
					
					mapData[hero.pos] = 2;
					
					myScore--;
					
					oppScore++;
					
					refreshUIContainer();
					
				}else if(mapData[hero.pos] == 2 && hero.isMine){
					
					mapData[hero.pos] = 1;
					
					myScore++;
					
					oppScore--;
					
					refreshUIContainer();
				}
			}
			
			battleMap.refresh(mapData);
			
			TweenLite.delayedCall(0.5,startMove,[_moveData,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]);
			
			//			startMove(_moveData,_skillData,_attackData,_cardUid,_cardID,_canMoveData);
		}
		
		private function startSkill(_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			effectContainer.removeChildren();
			
			if(_skillData == null || _skillData.length == 0){
				
				castSkillOver(_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
				
				return;
			}
			
			var vec:Vector.<Vector.<int>> = _skillData[0];
			
			var pos:int = vec[0][0];
			
			var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[pos];
			
			moveGameContainerToCenter(tmpBattleMapUnit.x,tmpBattleMapUnit.y,startSkillReal,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData);
		}	
		
		private function startSkillReal(_skillData:Vector.<Vector.<Vector.<int>>>,_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var vec:Vector.<Vector.<int>> = _skillData.shift();
			
			var pos:int = vec.shift()[0];
			
			var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[pos];
			
			var index:int = 0;
			
			for each(var vec2:Vector.<int> in vec){
				
				var targetPos:int = vec2.shift();
				
				if(mapData[pos] == mapData[targetPos]){
					
					var textureName:String = "greenArrow";
					
				}else{
					
					textureName = "redArrow";
				}
				
				var sp:Sprite = new Sprite;
				
				var img:Image = new Image(ResourcePublic.getTexture(textureName));
				
				img.x = -0.5 * img.width;
				img.y = -0.5 * img.height;
				
				sp.addChild(img);
				
				sp.flatten();
				
				sp.x = tmpBattleMapUnit.x;
				sp.y = tmpBattleMapUnit.y;
				
				var targetBattleMapUnit:BattleMapUnit = battleMap.dic[targetPos];
				
				sp.rotation = Math.atan2(targetBattleMapUnit.y - sp.y, targetBattleMapUnit.x - sp.x);
				
				effectContainer.addChild(sp);
				
				if(index == 0){
					
					TweenLite.to(sp,0.8,{x:targetBattleMapUnit.x - Math.cos(sp.rotation) * sp.width * 0.5,y:targetBattleMapUnit.y - Math.sin(sp.rotation) * sp.width * 0.5,ease:ElasticIn.ease,onComplete:skillShootTarget,onCompleteParams:[sp,index,pos,targetPos,vec2,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]});
					
				}else{
					
					TweenLite.to(sp,0.8,{x:targetBattleMapUnit.x - Math.cos(sp.rotation) * sp.width * 0.5,y:targetBattleMapUnit.y - Math.sin(sp.rotation) * sp.width * 0.5,ease:ElasticIn.ease,onComplete:skillShootTarget,onCompleteParams:[sp,index,pos,targetPos,vec2]});
				}
				
				index++;
			}
		}
		
		private static const tfVerticalGap:Number = 24;
		private static const tfFix:Number = 16;
		private static const tfSize:int = 30;
		private static const tfWidth:int = 200;
		private static const tfHeight:int = 30;
		
		private function skillShootTarget(_arrow:Sprite,_index:int,_pos:int,_targetPos:int,_vec:Vector.<int>,_skillData:Vector.<Vector.<Vector.<int>>> = null,_attackData:Vector.<Vector.<Vector.<int>>> = null,_cardUid:int = 0,_cardID:int = 0,_oppCardID:int = 0,_canMoveData:Vector.<int> = null):void{
			
			TweenLite.to(_arrow,0.5,{alpha:0,onComplete:arrowAlphaOutOver,onCompleteParams:[_arrow]});
			
			var sp:Sprite = new Sprite;
			
			effectContainer.addChild(sp);
			
			for(var i:int = 0 ; i < _vec.length / 2 ; i++){
				
				var type:int = _vec[i * 2];
				var data:int = _vec[i * 2 + 1];
				
				switch(type){
					
					case 1:
						
						var str:String = "Silent";
						var color:uint = 0xFF0000;
						
						var tf:TextField = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 2:
						
						var hero:BattleHero = heroData[_targetPos];
						
						hero.hpChange = hero.hpChange + data;
						
						hero.refresh(false);
						
						if(data < 0){
							
							str = "HP" + data;
							
							color = 0xFF0000;
							
							hero.tremble();
							
						}else if(data == 0){
							
							str = "HP-" + data;
							
							color = 0xFF0000;
							
						}else{
							
							str = "HP+" + data;
							
							color = 0x00FF00;
						}
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 3:
						
						hero = heroData[_targetPos];
						
						hero.atkFix = hero.atkFix + data;
						
						hero.refresh(false);
						
						if(data < 0){
							
							str = "ATK" + data;
							
							color = 0xFF0000;
							
						}else{
							
							str = "ATK+" + data;
							
							color = 0x00FF00;
						}
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 4:
						
						hero = heroData[_targetPos];
						
						hero.maxHpFix = hero.maxHpFix + data;
						
						hero.hpChange = hero.hpChange + data;
						
						hero.refresh(false);
						
						str = "MAXHP+" + data;
						
						color = 0x00FF00;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 5:
						
						str = "Root";
						color = 0xFF0000;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 6:
						
						if(data < 100){
							
							str = "W-" + (100 - data) + "%";
							
							color = 0x00FF00;
							
						}else{
							
							str = "W+" + (data - 100) + "%";
							
							color = 0xFF0000;
						}
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 7:
						
						hero = heroData[_targetPos];
						
						hero.die = true;
						
						str = "Die";
						color = 0xFF0000;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_targetPos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * i;
						
						break;
					
					case 101:
						
						str = "Silent";
						color = 0xFF0000;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
					
					case 102:
						
						hero = heroData[_pos];
						
						hero.hpChange = hero.hpChange + data;
						
						hero.refresh(false);
						
						if(data < 0){
							
							str = "HP" + data;
							
							color = 0xFF0000;
							
							hero.tremble();
							
						}else if(data == 0){
							
							str = "HP-" + data;
							
							color = 0xFF0000;
							
						}else{
							
							str = "HP+" + data;
							
							color = 0x00FF00;
						}
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
					
					case 103:
						
						hero = heroData[_pos];
						
						hero.atkFix = hero.atkFix + data;
						
						hero.refresh(false);
						
						if(data < 0){
							
							str = "ATK" + data;
							
							color = 0xFF0000;
							
						}else{
							
							str = "ATK+" + data;
							
							color = 0x00FF00;
						}
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
					
					case 104:
						
						hero = heroData[_pos];
						
						hero.maxHpFix = hero.maxHpFix + data;
						
						hero.hpChange = hero.hpChange + data;
						
						hero.refresh(false);
						
						str = "MAXHP+" + data;
						
						color = 0x00FF00;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
					
					case 105:
						
						str = "Root";
						color = 0xFF0000;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
					
					case 106:
						
						if(data < 100){
							
							str = "W-" + (100 - data) + "%";
							
							color = 0x00FF00;
							
						}else{
							
							str = "W+" + (data - 100) + "%";
							
							color = 0xFF0000;
						}
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
					
					case 107:
						
						hero = heroData[_pos];
						
						hero.die = true;
						
						str = "Die";
						color = 0xFF0000;
						
						tf = new TextField(tfWidth,tfHeight,str,ResourceFont.fontName,tfSize,color);
						tf.hAlign = HAlign.CENTER;
						tf.vAlign = VAlign.CENTER;
						
						tmpBattleMapUnit = battleMap.dic[_pos];
						
						tf.x = tmpBattleMapUnit.x - 0.5 * tf.width;
						tf.y = tmpBattleMapUnit.y - 0.5 * tf.height - tfFix - tfVerticalGap * _index;
						
						break;
				}
				
				sp.addChild(tf);
			}
			
			sp.flatten();
			
			if(_skillData != null){
				
				TweenLite.to(sp,2,{y:sp.y - 30,ease:Linear.easeNone,onComplete:skillTfTweenOver1,onCompleteParams:[sp,_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]});
				
			}else{
				
				TweenLite.to(sp,2,{y:sp.y - 30,ease:Linear.easeNone,onComplete:skillTfTweenOver1,onCompleteParams:[sp]});
			}
		}
		
		private function arrowAlphaOutOver(_arrow:Sprite):void{
			
			effectContainer.removeChild(_arrow);
		}
		
		private function skillTfTweenOver1(_sp:Sprite,_skillData:Vector.<Vector.<Vector.<int>>> = null,_attackData:Vector.<Vector.<Vector.<int>>> = null,_cardUid:int = 0,_cardID:int = 0,_oppCardID:int = 0,_canMoveData:Vector.<int> = null):void{
			
			if(_skillData != null){
				
				TweenLite.to(_sp,0.5,{alpha:0,ease:Linear.easeNone,onComplete:startSkill,onCompleteParams:[_skillData,_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]});
				
			}else{
				
				TweenLite.to(_sp,0.5,{alpha:0,ease:Linear.easeNone});
			}
		}
		
		private function castSkillOver(_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var hasAddCallBack:Boolean = false;
			
			for(var str:String in heroData){
				
				var hero:BattleHero = heroData[str];
				
				if(hero.die){
					
					if(!hasAddCallBack){
						
						hasAddCallBack = true;
						
						TweenLite.delayedCall(1,startAttack,[_attackData,_cardUid,_cardID]);
					}
					
					TweenLite.to(hero,0.5,{alpha:0,ease:Linear.easeNone,onComplete:spriteAlphaOutOver,onCompleteParams:[hero]});
					
					delete heroData[str];
					
					//					if(hero.isMine){
					//						
					//						oppScore++;
					//						
					//						myScore--;
					//						
					//					}else{
					//						
					//						myScore++;
					//						
					//						oppScore--;
					//					}
					
					continue;
				}
				
				if(hero.hpChange != 0){
					
					hero.hp = hero.hp + hero.hpChange;
					
					if(hero.hp < 1){
						
						if(!hasAddCallBack){
							
							hasAddCallBack = true;
							
							TweenLite.delayedCall(1,startAttack,[_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]);
						}
						
						TweenLite.to(hero,0.5,{alpha:0,ease:Linear.easeNone,onComplete:spriteAlphaOutOver,onCompleteParams:[hero]});
						
						delete heroData[str];
						
						continue;
					}
					
					if(hero.maxHpFix > 0){
						
						if(hero.hpChange <= 0){
							
							hero.maxHpFix = 0;
							
						}else if(hero.hpChange < hero.maxHpFix){
							
							hero.maxHpFix = hero.hpChange;
						}
					}
					
					if(hero.hp > hero.getMaxHp()){
						
						hero.hp = hero.getMaxHp();
					}
					
					hero.hpChange = 0;
					
					if(hero.hp > hero.csv.maxHp + hero.maxHpFix){
						
						hero.hp = hero.csv.maxHp + hero.maxHpFix;
					}
				}
			}
			
			if(!hasAddCallBack){
				
				TweenLite.delayedCall(0.5,startAttack,[_attackData,_cardUid,_cardID,_oppCardID,_canMoveData]);
			}
			
		}
		
		private function spriteAlphaOutOver(_sp:Sprite):void{
			
			_sp.parent.removeChild(_sp);
		}
		
		private function startAttack(_attackData:Vector.<Vector.<Vector.<int>>>,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var attackDic:Dictionary = new Dictionary;
			
			var beAttackDic:Dictionary = new Dictionary;
			
			var beHitDic:Dictionary = new Dictionary;
			
			for each(var vec:Vector.<Vector.<int>> in _attackData){
				
				var vec1:Vector.<int> = vec[0];
				
				var pos:int = vec1[0];
				
				var hero:BattleHero = heroData[pos];
				
				var beHitObj:Object = null;
				
				var beHitNum:int = vec1[1];
				
				if(beHitNum > 0){
					
					beHitDic[pos] = true;
					
					beHitObj = new Object;
					
					beAttackDic[hero.pos] = beHitObj;
					
					beHitObj.num = beHitNum;
					
					beHitObj.attackerDic = new Vector.<int>(vec.length - 1,true);
				}
				
				for(var i:int = 1 ; i < vec.length ; i++){
					
					vec1 = vec[i];
					
					var attackHeroPos:int = vec1[0];
					
					var attackHero:BattleHero = heroData[attackHeroPos];
					
					var damage:int = vec1[1];
					
					var tmpDic:Object = attackDic[attackHeroPos];
					
					if(tmpDic == null){
						
						tmpDic = new Object;
						
						attackDic[attackHero.pos] = tmpDic;
						
						tmpDic.num = 1;
						
						tmpDic.targetDic = new Dictionary;
						
					}else{
						
						tmpDic.num++;
					}
					
					tmpDic.targetDic[hero.pos] = damage;
					
					if(beHitObj != null){
						
						beHitObj.attackerDic[i - 1] = attackHeroPos;
					}
				}
			}
			
			startAttack1(attackDic,beAttackDic,beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData);
		}
		
		private function startAttack1(_attackDic:Dictionary,_beAttackDic:Dictionary,_beHitDic:Dictionary,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			effectContainer.removeChildren();
			
			var hasBeAttack:Boolean = false;
			
			for(var str:String in _beAttackDic){
				
				hasBeAttack = true;
				
				var pos:int = int(str);
				
				var obj:Object = _beAttackDic[str];
				
				delete _beAttackDic[str];
				
				var targetBattleMapUnit:BattleMapUnit = battleMap.dic[pos];
				
				moveGameContainerToCenter(targetBattleMapUnit.x,targetBattleMapUnit.y,startAttack1Real,_attackDic,_beAttackDic,_beHitDic,_cardUid,_cardID,pos,obj,_oppCardID,_canMoveData);
				
				break;
			}
			
			if(!hasBeAttack){
				
				startAttack2(_attackDic,_beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData);
			}
		}
		
		private function startAttack1Real(_attackDic:Dictionary,_beAttackDic:Dictionary,_beHitDic:Dictionary,_cardUid:int,_cardID:int,_pos:int,_obj:Object,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var targetBattleMapUnit:BattleMapUnit = battleMap.dic[_pos];
			
			var hitNum:int = _obj.num;
			
			var attackerVec:Vector.<int> = _obj.attackerDic;
			
			if(hitNum == 1){
				
				for each(var attackPos:int in attackerVec){
					
					if(_attackDic[attackPos].num == 1){
						
						var vec:Vector.<int> = Vector.<int>([attackPos]);
						
						break;
					}
				}
				
			}else{
				
				vec = BattlePublic.getAttackerPos(mapUnit.mapWidth,_pos,hitNum,attackerVec);
			}
			
			var damage:int = 0;
			
			for(var i:int = 0 ; i < vec.length ; i++){
				
				var attackerPos:int = vec[i];
				
				damage = damage + _attackDic[attackerPos].targetDic[_pos];
				
				delete _attackDic[attackerPos].targetDic[_pos];
				
				var remain:Boolean = false;
				
				for each(var tmp:int in _attackDic[attackerPos].targetDic){
					
					remain = true;
					
					break;
				}
				
				if(!remain){
					
					delete _attackDic[attackerPos];
				}
				
				var sp:Sprite = new Sprite;
				
				var img:Image = new Image(ResourcePublic.getTexture("redArrow"));
				
				img.x = -0.5 * img.width;
				img.y = -0.5 * img.height;
				
				sp.addChild(img);
				
				sp.flatten();
				
				var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[attackerPos];
				
				sp.x = tmpBattleMapUnit.x;
				sp.y = tmpBattleMapUnit.y;
				
				sp.rotation = Math.atan2(targetBattleMapUnit.y - sp.y, targetBattleMapUnit.x - sp.x);
				
				effectContainer.addChild(sp);
				
				if(i == vec.length - 1){
					
					TweenLite.to(sp,0.8,{x:targetBattleMapUnit.x - Math.cos(sp.rotation) * sp.width * 0.5,y:targetBattleMapUnit.y - Math.sin(sp.rotation) * sp.width * 0.5,ease:ElasticIn.ease,onComplete:shoowTarget,onCompleteParams:[sp,_pos,damage,hitNum,startAttack1,_attackDic,_beAttackDic,_beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData]});
					
				}else{
					
					TweenLite.to(sp,0.8,{x:targetBattleMapUnit.x - Math.cos(sp.rotation) * sp.width * 0.5,y:targetBattleMapUnit.y - Math.sin(sp.rotation) * sp.width * 0.5,ease:ElasticIn.ease,onComplete:arrowAlphaOut,onCompleteParams:[sp]});
				}
			}
		}
		
		private function arrowAlphaOut(_arrow:Sprite):void{
			
			TweenLite.to(_arrow,0.5,{alpha:0,onComplete:arrowAlphaOutOver,onCompleteParams:[_arrow]});
		}
		
		private function shoowTarget(_arrow:Sprite,_pos:int,_damage:int,_hitNum:int,_callBack:Function = null,...arg):void{
			
			arrowAlphaOut(_arrow);
			
			var hero:BattleHero = heroData[_pos];
			
			hero.hpChange = hero.hpChange - _damage;
			
			var sp:Sprite = new Sprite;
			
			effectContainer.addChild(sp);
			
			var tf:TextField = new TextField(tfWidth,tfHeight,"HP-" + _damage,ResourceFont.fontName,tfSize,0xFF0000);
			tf.hAlign = HAlign.CENTER;
			
			tf.x = -0.5 * tf.width;
			tf.y = -0.5 * tf.height - tfFix;
			
			sp.addChild(tf);
			
			var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[_pos];
			
			sp.x = tmpBattleMapUnit.x;
			sp.y = tmpBattleMapUnit.y;
			
			if(_hitNum > 0){
				
				hero.power = hero.power - _hitNum;
				
				if(hero.power < 0){
					
					hero.power = 0;
				}
				
				tf = new TextField(tfWidth,tfHeight,"M-" + _hitNum,ResourceFont.fontName,tfSize,0xFF0000);
				tf.hAlign = HAlign.CENTER;
				
				tf.x = -0.5 * tf.width;
				tf.y = -0.5 * tf.height - tfFix - tfVerticalGap;
				
				sp.addChild(tf);
			}
			
			sp.flatten();
			
			TweenLite.to(sp,2,{y:sp.y - 30,ease:Linear.easeNone,onComplete:shoowTargetOver,onCompleteParams:[sp,_callBack,arg]});
			
			hero.refresh(false);
			
			hero.tremble();
		}
		
		private function shoowTargetOver(_sp:Sprite,_callBack:Function,_arg:Array):void{
			
			TweenLite.to(_sp,0.5,{alpha:0,onComplete:_callBack,onCompleteParams:_arg});
		}
		
		private function startAttack2(_attackDic:Dictionary,_beHitDic:Dictionary,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			effectContainer.removeChildren();
			
			var hasAttack:Boolean = false;
			
			for(var str:String in _attackDic){
				
				hasAttack = true;
				
				var pos:int = int(str);
				
				var obj:Object = _attackDic[str];
				
				delete _attackDic[str];
				
				var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[pos];
				
				moveGameContainerToCenter(tmpBattleMapUnit.x,tmpBattleMapUnit.y,startAttack2Real,_attackDic,_beHitDic,_cardUid,_cardID,pos,obj,_oppCardID,_canMoveData);
				
				break;
			}
			
			if(!hasAttack){
				
				attackOver(_beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData);
			}
		}
		
		private function startAttack2Real(_attackDic:Dictionary,_beHitDic:Dictionary,_cardUid:int,_cardID:int,_pos:int,_obj:Object,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var tmpBattleMapUnit:BattleMapUnit = battleMap.dic[_pos];
			
			var hasAddCallBack:Boolean = false;
			
			for(var str2:String in _obj.targetDic){
				
				var targetPos:int = int(str2);
				
				var damage:int = _obj.targetDic[str2];
				
				var sp:Sprite = new Sprite;
				
				var img:Image = new Image(ResourcePublic.getTexture("yellowArrow"));
				
				img.x = -0.5 * img.width;
				img.y = -0.5 * img.height;
				
				sp.addChild(img);
				
				sp.flatten();
				
				sp.x = tmpBattleMapUnit.x;
				sp.y = tmpBattleMapUnit.y;
				
				var targetBattleMapUnit:BattleMapUnit = battleMap.dic[targetPos];
				
				sp.rotation = Math.atan2(targetBattleMapUnit.y - sp.y, targetBattleMapUnit.x - sp.x);
				
				effectContainer.addChild(sp);
				
				if(!hasAddCallBack){
					
					hasAddCallBack = true;
					
					TweenLite.to(sp,0.8,{x:targetBattleMapUnit.x - Math.cos(sp.rotation) * sp.width * 0.5,y:targetBattleMapUnit.y - Math.sin(sp.rotation) * sp.width * 0.5,ease:ElasticIn.ease,onComplete:shoowTarget,onCompleteParams:[sp,targetPos,damage,0,startAttack2,_attackDic,_beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData]});
					
				}else{
					
					TweenLite.to(sp,0.8,{x:targetBattleMapUnit.x - Math.cos(sp.rotation) * sp.width * 0.5,y:targetBattleMapUnit.y - Math.sin(sp.rotation) * sp.width * 0.5,ease:ElasticIn.ease,onComplete:shoowTarget,onCompleteParams:[sp,targetPos,damage,0]});
				}
			}
		}
		
		private function attackOver(_beHitDic:Dictionary,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			var hasAddCallBack:Boolean = false;
			
			for(var str:String in heroData){
				
				var pos:int = int(str);
				
				var hero:BattleHero = heroData[str];
				
				if(hero.hpChange < 0){
					
					hero.hp = hero.hp + hero.hpChange;
					
					if(hero.hp < 1){
						
						if(!hasAddCallBack){
							
							hasAddCallBack = true;
							
							TweenLite.delayedCall(1,resetData,[_beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData]);
						}
						
						TweenLite.to(hero,0.5,{alpha:0,ease:Linear.easeNone,onComplete:spriteAlphaOutOver,onCompleteParams:[hero]});
						
						delete heroData[str];
						
						continue;
					}
					
					if(hero.maxHpFix > 0){
						
						hero.maxHpFix = hero.maxHpFix + hero.hpChange;
						
						if(hero.maxHpFix < 0){
							
							hero.maxHpFix = 0;
						}
					}
					
					hero.hpChange = 0;
				}
				
				if(hero.maxHpFix > 0){
					
					hero.hp = hero.hp - hero.maxHpFix;
					
					hero.maxHpFix = 0;
				}
				
				if(hero.hp < hero.csv.maxHp && hero.power > 0){
					
					hero.hp = hero.hp + hero.power;
					
					if(hero.hp > hero.csv.maxHp){
						
						hero.hp = hero.csv.maxHp;
					}
				}
				
				if(hero.atkFix != 0){
					
					hero.atkFix = 0;
				}
				
				if(hero.power < hero.csv.maxPower){
					
					if(_beHitDic[pos] == null){
						
						hero.power = hero.power + 1;
					}
				}
				
				hero.refresh(false);
			}
			
			if(!hasAddCallBack){
				
				TweenLite.delayedCall(0.5,resetData,[_beHitDic,_cardUid,_cardID,_oppCardID,_canMoveData]);
			}
		}
		
		private function resetData(_beHitDic:Dictionary,_cardUid:int,_cardID:int,_oppCardID:int,_canMoveData:Vector.<int>):void{
			
			canMoveData = _canMoveData;
			
			for each(var hero:BattleHero in heroData){
				
				hero.refresh(true);
			}
			
			var isTween:Boolean = false;
			
			if(_cardID != -1){
				
				myAllCardsNum--;
				
				var card:BattleCard = new BattleCard(_cardID);
				
				if(_cardUid != -1){
					
					card.uid = _cardUid;
					
					myCards.push(card);
					
					cardContainer.addChild(card);
					
					refreshCards();
					
				}else{
					
					isTween = true;
					
					card.x = Starling.current.backBufferWidth * 0.5;
					
					card.y = Starling.current.backBufferHeight - card.height * 2;
					
					heroDetailContainer.addChild(card);
					
					TweenLite.to(card,2,{alpha:0,ease:Linear.easeNone,onComplete:spriteAlphaOutOver,onCompleteParams:[card]});
				}
			}
			
			if(_oppCardID == -1){
				
				if(oppAllCardsNum > 0){
					
					oppAllCardsNum--;
					
					oppCardsNum++;
				}
				
			}else{
				
				oppAllCardsNum--;
				
				isTween = true;
				
				card = new BattleCard(_oppCardID);
				
				card.x = Starling.current.backBufferWidth * 0.5;
				
				card.y = card.height * 2;
				
				heroDetailContainer.addChild(card);
				
				TweenLite.to(card,2,{alpha:0,ease:Linear.easeNone,onComplete:spriteAlphaOutOver,onCompleteParams:[card]});
			}
			
			if(!isTween){
				
				playBattleOver();
				
			}else{
				
				refreshUIContainer();
				
				TweenLite.delayedCall(2,playBattleOver);
			}
		}
		
		private function playBattleOver():void{
			
			nowRound++;
			
			refreshUIContainer();
			
			money = MONEY_NUM;
			
			refreshMoneyTf();
			
			isActioned = false;
			
			Starling.current.touchable = true;
			
			actionBt.enabled = true;
			
			isPlayBattle = false;
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			
			if(playBattleOverCallBack != null){
				
				playBattleOverCallBack.apply(null,playBattleOverCallBackArg);
				
				playBattleOverCallBack = null;
				playBattleOverCallBackArg = null;
			}
		}
		
		private function refreshUIContainer():void{
			
			uiContainer.unflatten();
			
			oppCardsNumTf.text = "OppCardsNum:" + oppCardsNum;
			myAllCardsNumTf.text = "MyAllCardsNum:" + myAllCardsNum;
			oppAllCardsNumTf.text = "OppAllCardsNum:" + oppAllCardsNum;
			
			roundTf.text = "Round:" + nowRound + "/" + maxRound;
			
			scoreTf.text = "Score:" + myScore + ":" + oppScore;
			
			uiContainer.flatten();
		}
		
		private function refreshMoneyTf():void{
			
			myMoneyTf.text = "MyMoney:" + money;
		}
		
		public function showHeroDetail(_x:Number,_y:Number,_heroID:int):void{
			
			hideHeroDetail();
			
			if(_x <= Starling.current.backBufferWidth * 0.5 && _y <= Starling.current.backBufferHeight * 0.5){
				
				heroDetailPanel.x = Starling.current.backBufferWidth * 0.5 + (Starling.current.backBufferWidth * 0.5 - heroDetailPanel.width) * 0.5;
				heroDetailPanel.y = Starling.current.backBufferHeight * 0.5 + (Starling.current.backBufferHeight * 0.5 - heroDetailPanel.height) * 0.5;
				
			}else if(_x > Starling.current.backBufferWidth * 0.5 && _y <= Starling.current.backBufferHeight * 0.5){
				
				heroDetailPanel.x = (Starling.current.backBufferWidth * 0.5 - heroDetailPanel.width) * 0.5;
				heroDetailPanel.y = Starling.current.backBufferHeight * 0.5 + (Starling.current.backBufferHeight * 0.5 - heroDetailPanel.height) * 0.5;
				
			}else if(_x <= Starling.current.backBufferWidth * 0.5 && _y > Starling.current.backBufferHeight * 0.5){
				
				heroDetailPanel.x = Starling.current.backBufferWidth * 0.5 + (Starling.current.backBufferWidth * 0.5 - heroDetailPanel.width) * 0.5;
				heroDetailPanel.y = (Starling.current.backBufferHeight * 0.5 - heroDetailPanel.height) * 0.5;
				
			}else{
				
				heroDetailPanel.x = (Starling.current.backBufferWidth * 0.5 - heroDetailPanel.width) * 0.5;
				heroDetailPanel.y = (Starling.current.backBufferHeight * 0.5 - heroDetailPanel.height) * 0.5;
			}
			
			heroDetailPanel.visible = true;
			
			heroDetailPanel.setData(_heroID);
		}
		
		public function hideHeroDetail():void{
			
			heroDetailPanel.visible = false;
			
			battleMap.hideTargetFrame();
		}
		
		public function moneyTremble():void{
			
			if(moneyIsTrembling){
				
				return;
			}
			
			moneyIsTrembling = true;
			
			startMoneyTremble(myMoneyTf.x,8);
		}
		
		private function startMoneyTremble(_opos:Number,_posFix:Number):void{
			
			if(Math.abs(_posFix) < 1){
				
				myMoneyTf.x = _opos;
				
				moneyIsTrembling = false;
				
				return;
			}
			
			if(_posFix < 0){
				
				var posFix:Number = -_posFix - 0.5;
				
			}else{
				
				posFix = -_posFix + 0.5;
			}
			
			TweenLite.to(myMoneyTf,0.05,{x:_opos + _posFix,ease:Linear.easeNone,onComplete:startMoneyTremble,onCompleteParams:[_opos,posFix]});
		}
		
		private function moveGameContainerToCenter(_x:Number,_y:Number,_callBack:Function = null,...arg):void{
			
			TweenLite.to(gameContainer,0.5,{x:Starling.current.backBufferWidth * 0.5 - _x * gameContainerScale,y:Starling.current.backBufferHeight * 0.5 - _y * gameContainerScale,ease:com.greensock.easing.Quad.easeOut,onComplete:delayCall,onCompleteParams:[0.3,_callBack,arg]});
		}
		
		private function delayCall(_time:Number,_callBack:Function,_arg:Array):void{
			
			TweenLite.delayedCall(_time,_callBack,_arg);
		}
		
		private function quitBattle(e:Event):void{
			
			Connect.sendData(18,quitBattleOK);
		}
		
		private function quitBattleOK(_result:Boolean):void{
			
			if(_result){
				
				leaveBattle(-1);
			}
		}
		
		public function leaveBattle(_result:int):void{
			
			if(!isPlayBattle){
				
				leaveBattleReal(_result);
				
			}else{
				
				playBattleOverCallBack = leaveBattleReal;
				playBattleOverCallBackArg = [_result];
			}
		}
		
		private function leaveBattleReal(_result:int):void{
			
			alertContainer.visible = true;
			
			switch(_result){
				
				case -1:
					
					alertTf.text = "You have left the game!";
					
					trace("你主动退出了游戏!!");
					
					break;
				
				case 0:
					
					alertTf.text = "Your opponent has left the game!";
					
					trace("对手主动退出了游戏！！");
					
					break;
				
				case 1:
					
					alertTf.text = "You win the game!";
					
					trace("你赢了！！");
					
					break;
				
				case 2:
					
					alertTf.text = "You lose the game!";
					
					trace("你输了！！");
					
					break;
				
				case 3:
					
					alertTf.text = "It is a draw game!";
					
					trace("平局！！");
					
					break;
			}
		}
		
		private function disposeBattle():void{
			
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			
			battleMap.disposeBattleMap();
			
			heroContainer.removeChildren();
			
			arrowContainer.unflatten();
			
			arrowContainer.removeChildren();
			
			arrowContainer.flatten();
			
			effectContainer.removeChildren();
			
			cardContainer.removeChildren();
			
			cardTouchMoveFun = null;
			
			moneyIsTrembling = false;
			
			hideHeroDetail();
			
			Game.leaveBattleOK();
		}
		
		private function onMouseWheel(e:MouseEvent):void{
			
			var point:Point = new Point(e.stageX,e.stageY);
			
			var point2:Point = gameContainer.globalToLocal(point);
			
			if(e.delta > 0){
				
				gameContainer.scaleX = gameContainer.scaleY = gameContainerScale = gameContainerScale + 0.1;
				
			}else{
				
				gameContainer.scaleX = gameContainer.scaleY = gameContainerScale = gameContainerScale - 0.1;
			}
			
			var point3:Point = gameContainer.globalToLocal(point);
			
			gameContainer.x = gameContainer.x + (point3.x - point2.x) * gameContainerScale;
			gameContainer.y = gameContainer.y + (point3.y - point2.y) * gameContainerScale;
		}
		
		private function alertContainerBeTouch(e:TouchEvent):void{
			
			var touch:Touch = e.getTouch(alertContainer,TouchPhase.ENDED);
			
			if(touch != null){
				
				alertContainer.visible = false;
				
				disposeBattle();
			}
		}
	}
}

