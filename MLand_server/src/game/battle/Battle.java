package game.battle;

import game.gameAi.GameAi;
import game.gameQueue.GameQueue;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;

import playerData.PlayerData;
import publicTools.PublicTools;
import superService.SuperService;
import userService.UserService;
import data.dataCsv.ai.Csv_ai;
import data.dataCsv.battle.Csv_battle;
import data.dataCsv.battle.Csv_battleAi;
import data.dataCsv.hero.Csv_hero;
import data.dataMap.Map;
import data.dataMap.MapUnit;

public class Battle extends SuperService{

	private static HashMap<String, Method> methodMap;
	
	public static void init() throws Exception{
		
		methodMap = new HashMap<>();
		
		methodMap.put("init",Battle.class.getDeclaredMethod("init",int.class,UserService.class,UserService.class,int.class));
		methodMap.put("getBattleData", Battle.class.getDeclaredMethod("getBattleData", UserService.class));
		methodMap.put("sendBattleAction", Battle.class.getDeclaredMethod("sendBattleAction", UserService.class, int[][].class, int[][].class));
		methodMap.put("quitBattle", Battle.class.getDeclaredMethod("quitBattle", UserService.class));
	}
	
	protected HashMap<String, Method> getMethodMap(){
		
		return methodMap;
	}
	
	private static int START_CARDS_NUM = 4;
	private static int MAX_CARDS_NUM = 5;
	private static int MONEY = 5;
	public static int POWER_CAN_MOVE = 1;
	public static int MAX_MOVE_HERO_NUM = 3;
	
	private UserService service1;
	private UserService service2;
	
	private boolean isActioned1;
	private boolean isActioned2;
	
	private ArrayList<Integer> canMoveHeroArr = new ArrayList<>();
	
	private HashMap<Integer, Integer> moveData1 = new HashMap<>();
	private HashMap<Integer, Integer> moveData2 = new HashMap<>();
	
	private HashMap<Integer, Integer> summonData1 = new HashMap<>();
	private HashMap<Integer, Integer> summonData2 = new HashMap<>();
	
	private int mapID;
	private MapUnit mapUnit;
	private HashMap<Integer, Integer> map;
	private HashMap<Integer, BattleHero> heroMap;
	private ArrayList<Integer> userAllCards1;
	private ArrayList<Integer> userAllCards2;
	private HashMap<Integer, Integer> userCards1;
	private HashMap<Integer, Integer> userCards2;
	
	private int score1;
	private int score2;
	
	private int maxRound;
	private int nowRound;
	
	private int aiMoney;
	
	private int uidIndex = 1;
	
	public Battle(){
		
		heroMap = new HashMap<>();
		
		userCards1 = new HashMap<>();
		userCards2 = new HashMap<>();
	}
	
	public void init(int _battleID,UserService _service1, UserService _service2, int _aiID){
		
		service1 = _service1;
		
		if(_service2 != null){
		
			service2 = _service2;
		}
		
		initBattle(_battleID,_aiID);
		
		service1.process("enterBattle",this);
		
		if(service2 != null){
		
			service2.process("enterBattle",this);
		}
	}
	
	private void initBattle(int _battleID,int _aiID){
		
		if(service2 != null){
		
			Csv_battle csv_battle = Csv_battle.dic.get(_battleID);
			
			mapID = csv_battle.mapID;
			
			mapUnit = Map.getMapUnit(mapID);
			
			maxRound = csv_battle.roundNum;
			
			PlayerData playerData = (PlayerData)service1.user.userData;
			
			userAllCards1 = PublicTools.getSomeOfArr(playerData.heroData.heros,csv_battle.cardsNum);
			
			playerData = (PlayerData)service2.user.userData;
			
			userAllCards2 = PublicTools.getSomeOfArr(playerData.heroData.heros,csv_battle.cardsNum);
			
		}else{
			
			Csv_battleAi csv_battleAi = Csv_battleAi.dic.get(_battleID);
			
			mapID = csv_battleAi.mapID;
			
			mapUnit = Map.getMapUnit(mapID);
			
			maxRound = csv_battleAi.roundNum;
			
			PlayerData playerData = (PlayerData)service1.user.userData;
			
			userAllCards1 = PublicTools.getSomeOfArr(playerData.heroData.heros,csv_battleAi.cardsNum);
			
			Csv_ai csv_ai = Csv_ai.dic.get(_aiID);
			
			int[] aiHeros = csv_ai.heros;
			
			userAllCards2 = new ArrayList<>();
			
			for(int heroID : aiHeros){
				
				userAllCards2.add(heroID);
			}
			
			userAllCards2 = PublicTools.getSomeOfArr(userAllCards2,csv_battleAi.cardsNum);
			
			aiMoney = csv_ai.money;
			
			if(csv_battleAi.defaultHeros.length > 0){
			
				for(int i = 0 ; i < csv_battleAi.defaultHeros.length ; i++){
					
					int pos = csv_battleAi.defaultHeros[i][0];
					int heroID = csv_battleAi.defaultHeros[i][1];
					
					BattleHero hero = new BattleHero();
					
					hero.csv = Csv_hero.dic.get(heroID);
					
					if(mapUnit.dic.get(pos) == 1){
					
						hero.isHost = true;
						
					}else{
						
						hero.isHost = false;
					}
					
					hero.pos = pos;
					
					hero.hp = hero.csv.maxHp;
					
					hero.power = hero.csv.maxPower;
					
					heroMap.put(pos, hero);
				}
				
				ArrayList<Integer> cantMoveHeroPosArr = new ArrayList<>();
				
				Iterator<BattleHero> iter = heroMap.values().iterator();
				
				while(iter.hasNext()){
					
					BattleHero hero = iter.next();
					
					if(hero.csv.heroType.moveType != 0){
						
						canMoveHeroArr.add(hero.pos);
					}
					
					if(hero.csv.heroType.canAttack){
						
						ArrayList<BattleHero> targetHeroArr = new ArrayList<>();
						
						BattlePublic.getHerosAndDirectionInRange(mapUnit.neighbourPosMap, heroMap, hero, 1, targetHeroArr, null);
						
						for(BattleHero tmpHero : targetHeroArr){
							
							if(!cantMoveHeroPosArr.contains(tmpHero.pos)){
								
								cantMoveHeroPosArr.add(tmpHero.pos);
							}
						}
					}
				}
				
				Iterator<Integer> iter2 = canMoveHeroArr.iterator();
				
				while(iter2.hasNext()){
					
					int pos = iter2.next();
					
					if(cantMoveHeroPosArr.contains(pos)){
						
						iter2.remove();
					}
				}
			}
		}
		
		nowRound = 1;
		
		map = (HashMap<Integer, Integer>)mapUnit.dic.clone();
		
		score1 = mapUnit.score1;
		
		score2 = mapUnit.score2;
		
		for(int i = 0 ; i < START_CARDS_NUM ; i++){
			
			if(userAllCards1.size() > 0){
			
				int uid = getUid();
				
				userCards1.put(uid,userAllCards1.remove(0));
			}
			
			if(userAllCards2.size() > 0){
			
				int uid = getUid();
				
				userCards2.put(uid,userAllCards2.remove(0));
			}
		}
	}
	
	private int getUid(){
		
		int uid = uidIndex;
		
		uidIndex++;
		
		return uid;
	}
	
	public void getBattleData(UserService _service){
		
		Iterator<Entry<Integer, Integer>> iter = map.entrySet().iterator();
		
		int[] mapData = new int[score1];
		
		int index = 0;
		
		while(iter.hasNext()){
			
			Entry<Integer, Integer> entry = iter.next();
			
			int pos = entry.getKey();
			
			int type = entry.getValue();
			
			if(type == 1){
			
				mapData[index] = pos;
				
				index++;
			}
		}
		
		HashMap<Integer, Integer> cards;
		int oppCardsNum;
		
		if(_service == service1){
			
			cards = userCards1;
			oppCardsNum = userCards2.size();
			
		}else{
			
			cards = userCards2;
			oppCardsNum = userCards1.size();
		}
		
		int[][] cardsData = null;
		
		if(cards.size() > 0){
		
			cardsData = new int[cards.size()][];
			
			iter = cards.entrySet().iterator();
			
			index = 0;
			
			while(iter.hasNext()){
				
				Entry<Integer, Integer> entry = iter.next();
				
				cardsData[index] = new int[]{entry.getKey(),entry.getValue()};
				
				index++;
			}
		}
		
		int[][] heroData = null;
		
		if(heroMap.size() > 0){
			
			heroData = new int[heroMap.size()][];
			
			index= 0;
			
			Iterator<Entry<Integer, BattleHero>> iter3 = heroMap.entrySet().iterator();
			
			while(iter3.hasNext()){
				
				Entry<Integer, BattleHero> entry = iter3.next();
				
				int key = entry.getKey();
				BattleHero hero = entry.getValue();
				
				int[] oneHeroData = new int[]{key,hero.csv.id,hero.hp,hero.power};
				
				heroData[index] = oneHeroData;
				
				index++;
			}
		}
		
		boolean isHost = _service == service1;
		
		boolean isActioned;
		
		HashMap<Integer, Integer> moveMap = null;
		HashMap<Integer, Integer> summonMap = null;
		int[][] moveData = null;
		int[][] summonData = null;
		
		if(isHost){
			
			isActioned = isActioned1;
			moveMap = moveData1;
			summonMap = summonData1;
			
		}else{
			
			isActioned = isActioned2;
			moveMap = moveData2;
			summonMap = summonData2;
		}
		
		if(isActioned){
			
			if(!moveMap.isEmpty()){
				
				moveData = new int[moveMap.size()][];
				
				iter = moveMap.entrySet().iterator();
				
				index = 0;
				
				while(iter.hasNext()){
					
					Entry<Integer, Integer> entry = iter.next();
					
					moveData[index] = new int[]{entry.getKey(),entry.getValue()};
					
					index++;
				}
			}
			
			if(!summonMap.isEmpty()){
				
				summonData = new int[summonMap.size()][];
				
				iter = summonMap.entrySet().iterator();
				
				index = 0;
				
				while(iter.hasNext()){
					
					Entry<Integer, Integer> entry = iter.next();
					
					summonData[index] = new int[]{entry.getKey(),entry.getValue()};
					
					index++;
				}
			}
		}
		
		int[] canMoveData = null;
		
		if(canMoveHeroArr.size() > 0){
			
			canMoveData = new int[canMoveHeroArr.size()];
			
			index = 0;
			
			for(int uid : canMoveHeroArr){
				
				canMoveData[index] = uid;
				
				index++;
			}
		}
		
		_service.process("getBattleDataOK", isHost, nowRound, maxRound, mapID, mapData, cardsData, oppCardsNum, userAllCards1.size(), userAllCards2.size(), heroData, canMoveData, isActioned, moveData, summonData);
	}
	
	public void sendBattleAction(UserService _service, int[][] _moveData, int[][] _summonData){
		
		boolean isHost = _service == service1;
		
		HashMap<Integer, Integer> moveData;
		HashMap<Integer, Integer> summonData;
		
		if(isHost){
			
			if(isActioned1){
				
				_service.process("sendMsg", "BattleError 0");
				
				_service.process("sendBattleActionOK", false);
				
				return;
				
			}else{
				
				isActioned1 = true;
			}
			
			moveData = moveData1;
			summonData = summonData1;
			
		}else{
			
			if(isActioned2){
				
				_service.process("sendMsg", "BattleError 0");
				
				_service.process("sendBattleActionOK", false);
				
				return;
				
			}else{
				
				isActioned2 = true;
			}
			
			moveData = moveData2;
			summonData = summonData2;
		}
		
		if(_moveData != null){
			
			for(int i = 0 ; i < _moveData.length ; i++){
				
				moveData.put(_moveData[i][0], _moveData[i][1]);
			}
		}
		
		if(_summonData != null){
			
			for(int i = 0 ; i < _summonData.length ; i++){
				
				summonData.put(_summonData[i][0], _summonData[i][1]);
			}
		}
		
		_service.process("sendBattleActionOK", true);
		
		if(service2 == null){

//			BattleAI.start(service1,mapUnit,map,heroMap,userCards2,canMoveHeroArr,aiMoney,summonData2,moveData2);
			
			isActioned2 = true;
		}
		
		if(isActioned1 && isActioned2){
			
			isActioned1 = isActioned2 = false;
			
			battleStart();
			
			nowRound++;
			
			if(nowRound > maxRound){
				
				if(score1 > score2){
					
					service1.process("leaveBattle", 1);
					
					if(service2 != null){
						
						service2.process("leaveBattle", 2);
					}
					
				}else if(score1 < score2){
					
					service1.process("leaveBattle", 2);
					
					if(service2 != null){
					
						service2.process("leaveBattle", 1);
					}
					
				}else{
					
					service1.process("leaveBattle", 3);
					
					if(service2 != null){
					
						service2.process("leaveBattle", 3);
					}
				}
				
				battleOver();
				
			}else{
				
				if(score1 == 0){
					
					service1.process("leaveBattle", 2);
					
					if(service2 != null){
					
						service2.process("leaveBattle", 1);
					}
					
					battleOver();
					
				}else if(score2 == 0){
					
					service1.process("leaveBattle", 1);
					
					if(service2 != null){
					
						service2.process("leaveBattle", 2);
					}
					
					battleOver();
				}
			}
		}
	}
	
	private void battleStart(){
		
		int money1 = MONEY;
		
		int money2;
		
		if(service2 != null){
		
			money2 = MONEY;
			
		}else{
			
			money2 = aiMoney;
		}
		
		int[][] summonResult1 = null;
		
		if(!summonData1.isEmpty()){
			
			ArrayList<int[]> summonArr1 = null;
			
			Iterator<Entry<Integer, Integer>> iter = summonData1.entrySet().iterator();
			
			while(iter.hasNext()){
				
				Entry<Integer, Integer> entry = iter.next();
				
				int uid = entry.getKey();
				int pos = entry.getValue();
				
				if(!userCards1.containsKey(uid)){
					
					service1.process("sendMsg", "BattleError 1");
					
					continue;
				}
				
				int cardID = userCards1.get(uid);
				
				Csv_hero heroCsv = Csv_hero.dic.get(cardID);
				
				if(heroCsv.star > money1){
					
					service1.process("sendMsg", "BattleError 2");
					
					continue;
				}
				
				if(!map.containsKey(pos)){
					
					service1.process("sendMsg", "BattleError 3");
					
					continue;
				}
				
				if(map.get(pos) == 2){
					
					service1.process("sendMsg", "BattleError 4");
					
					continue;
				}
				
				if(heroMap.containsKey(pos)){
					
					service1.process("sendMsg", "BattleError 5");
					
					continue;
				}
				
				userCards1.remove(uid);
				
				BattleHero hero = new BattleHero();
				
				hero.csv = heroCsv;
				
				hero.isHost = true;
				
				hero.pos = pos;
				
				hero.hp = heroCsv.maxHp;
				
				hero.power = heroCsv.maxPower;
				
				hero.isJustSummon = true;
				
				heroMap.put(pos, hero);
				
				money1 = money1 - heroCsv.star;
				
				if(summonArr1 == null){
					
					summonArr1 = new ArrayList<>();
				}
				
				summonArr1.add(new int[]{uid,cardID,pos});
			}
			
			summonData1.clear();
			
			if(summonArr1 != null){
				
				summonResult1 = new int[summonArr1.size()][];
				
				summonArr1.toArray(summonResult1);
			}
		}
		
		int[][] summonResult2 = null;
		
		if(!summonData2.isEmpty()){
			
			ArrayList<int[]> summonArr2 = null;
			
			Iterator<Entry<Integer, Integer>> iter = summonData2.entrySet().iterator();
			
			while(iter.hasNext()){
				
				Entry<Integer, Integer> entry = iter.next();
				
				int uid = entry.getKey();
				int pos = entry.getValue();
				
				if(service2 != null && !userCards2.containsKey(uid)){
					
					service2.process("sendMsg", "BattleError 1");
					
					continue;
				}
				
				int cardID = userCards2.get(uid);
				
				Csv_hero heroCsv = Csv_hero.dic.get(cardID);
				
				if(service2 != null && heroCsv.star > money2){
					
					service2.process("sendMsg", "BattleError 2");
					
					continue;
				}
				
				if(service2 != null && !map.containsKey(pos)){
					
					service2.process("sendMsg", "BattleError 3");
					
					continue;
				}
				
				if(service2 != null && map.get(pos) == 1){
					
					service2.process("sendMsg", "BattleError 4");
					
					continue;
				}
				
				if(service2 != null && heroMap.containsKey(pos)){
					
					service2.process("sendMsg", "BattleError 5");
					
					continue;
				}
				
				userCards2.remove(uid);
				
				BattleHero hero = new BattleHero();
				
				hero.csv = heroCsv;
				
				hero.isHost = false;
				
				hero.pos = pos;
				
				hero.hp = heroCsv.maxHp;
				
				hero.power = heroCsv.maxPower;
				
				hero.isJustSummon = true;
				
				heroMap.put(pos, hero);
				
				money2 = money2 - heroCsv.star;
				
				if(summonArr2 == null){
					
					summonArr2 = new ArrayList<>();
				}
				
				summonArr2.add(new int[]{uid,cardID,pos});
			}
			
			summonData2.clear();
			
			if(summonArr2 != null){
				
				summonResult2 = new int[summonArr2.size()][];
				
				summonArr2.toArray(summonResult2);
			}
		}
		
		//----检测移动合法性----
		int[][] moveResult = null;
		
		if(!moveData1.isEmpty()){
			
			Iterator<Entry<Integer, Integer>> iter = moveData1.entrySet().iterator();
			
			while(iter.hasNext()){
				
				Entry<Integer, Integer> entry = iter.next();
				
				if(money1 < 1){
					
					service1.process("sendMsg", "BattleError 11");
					
					iter.remove();
					
					continue;
				}
				
				money1 = money1 - 1;
				
				int pos = entry.getKey();
				int direct = entry.getValue();
				
				BattleHero hero = heroMap.get(pos);
				
				if(hero == null){
					
					service1.process("sendMsg", "BattleError 6");
					
					iter.remove();
					
					continue;
				}
				
				if(!hero.isHost){
					
					service1.process("sendMsg", "BattleError 7");
					
					iter.remove();
					
					continue;
				}
				
				if(!canMoveHeroArr.contains(hero.pos)){
					
					service1.process("sendMsg", "BattleError 8");
					
					iter.remove();
					
					continue;
				}

				int targetPos = mapUnit.neighbourPosMap.get(pos)[direct];
				
				if(targetPos != -1){
					
					entry.setValue(targetPos);
					
				}else{
					
					service1.process("sendMsg", "BattleError 9");
					
					iter.remove();
				}
			}
		}
		
		if(!moveData2.isEmpty()){
			
			Iterator<Entry<Integer, Integer>> iter = moveData2.entrySet().iterator();
			
			while(iter.hasNext()){
				
				Entry<Integer, Integer> entry = iter.next();
				
				if(service2 != null && money2 < 1){
					
					service2.process("sendMsg", "BattleError 11");
					
					iter.remove();
					
					continue;
				}
				
				money2 = money2 - 1;
				
				int pos = entry.getKey();
				int direct = entry.getValue();
				
				BattleHero hero = heroMap.get(pos);
				
				if(service2 != null && hero == null){
					
					service2.process("sendMsg", "BattleError 6");
					
					iter.remove();
					
					continue;
				}
				
				if(service2 != null && hero.isHost){
					
					service2.process("sendMsg", "BattleError 7");
					
					iter.remove();
					
					continue;
				}
				
				if(service2 != null && !canMoveHeroArr.contains(hero.pos)){
					
					service2.process("sendMsg", "BattleError 8");
					
					iter.remove();
					
					continue;
				}

				int targetPos = mapUnit.neighbourPosMap.get(pos)[direct];
				
				if(targetPos != -1){
					
					entry.setValue(targetPos);
					
				}else{
					
					service2.process("sendMsg", "BattleError 9");
					
					iter.remove();
				}
			}
		}
		
		canMoveHeroArr.clear();
		//--------
		
		//----检测2边对撞单位以及敌我互换位置单位----
		if(!moveData1.isEmpty() && !moveData2.isEmpty()){
			
			Iterator<Entry<Integer, Integer>> iter = moveData1.entrySet().iterator();
			
			while(iter.hasNext()){
				
				Entry<Integer, Integer> entry = iter.next();
				
				int pos = entry.getKey();
				int target = entry.getValue();
				
				if(map.get(target) == 2 && moveData2.containsValue(target)){
				
					iter.remove();
					
					continue;
				}
				
				if(moveData2.containsKey(target)){
					
					int tmpTarget = moveData2.get(target);
					
					if(tmpTarget == pos){
						
						iter.remove();
						
						moveData2.remove(target);
					}
				}
			}
			
			Iterator<Integer> iter2 = moveData2.values().iterator();
			
			while(iter2.hasNext()){
				
				int target = iter2.next();
				
				if(map.get(target) == 1 && moveData1.containsValue(target)){
					
					iter.remove();
				}
			}
		}
		//--------
		
		//----真正开始移动了----
		moveData1.putAll(moveData2);
		
		moveData2.clear();
		
		if(!moveData1.isEmpty()){
			
			ArrayList<Integer> resultPosArr = new ArrayList<>();
			ArrayList<Integer> resultTargetArr = new ArrayList<>();
			
			ArrayList<Integer> checkedPosArr = new ArrayList<>(); 
		
			Iterator<Integer> iter = moveData1.keySet().iterator();
			
			while(iter.hasNext()){
				
				int pos = iter.next();
				
				if(checkedPosArr.contains(pos)){
					
					continue;
				}
				
				ArrayList<Integer> tmpArr = new ArrayList<>();
				
				tmpArr.add(pos);
				
				int target;
				
				boolean result;
				
				while(true){
					
					target = moveData1.get(pos);
					
					if(heroMap.containsKey(target)){
						
						if(moveData1.containsKey(target)){
							
							int index = tmpArr.indexOf(target);
							
							if(index == -1){
								
								pos = target;
								
								tmpArr.add(pos);
								
							}else if(index == 0){
								
								result = true;
								
								break;
								
							}else{
								
								if(map.get(pos) == 1){
									
									service1.process("sendMsg", "BattleError 10");
									
								}else{
									
									service2.process("sendMsg", "BattleError 10");
								}
								
								result = false;
								
								break;
							}
							
						}else{
							
							result = false;
							
							break;
						}
						
					}else{
						
						result = true;
						
						break;
					}
				}
				
				if(result){
					
					HashMap<Integer, BattleHero> tmpMap = new HashMap<>();
					
					Iterator<Integer> iter2 = tmpArr.iterator();
					
					while(iter2.hasNext()){
						
						pos = iter2.next();
						target = moveData1.get(pos);
						
						BattleHero hero = heroMap.remove(pos);
						
						hero.moved = true;
						
						hero.pos = target;
						
						checkedPosArr.add(pos);
						
						resultPosArr.add(pos);
						resultTargetArr.add(target);
						
						tmpMap.put(target, hero);
						
						if(hero.isHost && map.get(target) == 2){
							
							map.put(target, 1);
							
							score1++;
							
							score2--;
							
						}else if(!hero.isHost && map.get(target) == 1){
							
							map.put(target, 2);
							
							score1--;
							
							score2++;
						}
					}
					
					Iterator<Entry<Integer, BattleHero>> iter3 = tmpMap.entrySet().iterator();
					
					while(iter3.hasNext()){
						
						Entry<Integer, BattleHero> entry = iter3.next();
						
						heroMap.put(entry.getKey(), entry.getValue());
					}
					
				}else{
					
					Iterator<Integer> iter2 = tmpArr.iterator();
					
					while(iter2.hasNext()){
						
						pos = iter2.next();
						
						checkedPosArr.add(pos);
					}
				}
			}
			
			moveData1.clear();
			
			moveResult = new int[resultPosArr.size()][];
			
			for(int i = 0 ; i < resultPosArr.size() ; i++){
				
				moveResult[i] = new int[]{resultPosArr.get(i),resultTargetArr.get(i)};
			}
		}
		//--------
		
		//----开始使用技能----
		int[][][] skillResult = null;
		
		ArrayList<int[][]> skillData = new ArrayList<>();
		
		//----先找沉默技能----
		Iterator<BattleHero> iter = heroMap.values().iterator();
		
		while(iter.hasNext()){

			BattleHero hero = iter.next();
			
			if(hero.isStopMove){//在上个回合结束时再遍历一次数组重置定身属性不太合算  所以在这里重置定身属性
				
				hero.isStopMove = false;
			}
			
			if((hero.isJustSummon && hero.csv.heroType.moveType != 2) || hero.power == 0 || hero.csv.silentSkillIndexArr == null){
				
				continue;
			}
			
			for(int silentSkillIndex : hero.csv.silentSkillIndexArr){
				
				int[][] oneSkillData = BattlePublic.castSkill(mapUnit.neighbourPosMap, heroMap, hero, silentSkillIndex);
			
				if(oneSkillData != null){
				
					skillData.add(oneSkillData);
				}
			}
		}
		//--------
		
		//----使用其他技能----
		iter = heroMap.values().iterator();
		
		while(iter.hasNext()){

			BattleHero hero = iter.next();
			
			if((hero.isJustSummon && hero.csv.heroType.moveType != 2) || hero.power == 0 || hero.isSilent){
				
				continue;
			}
			
			for(int i = 0 ; i < hero.csv.skillTarget.length ; i++){
				
				if(hero.csv.silentSkillIndexArr != null && hero.csv.silentSkillIndexArr.contains(i)){
					
					continue;
				}
				
				int[][] oneSkillData = BattlePublic.castSkill(mapUnit.neighbourPosMap, heroMap, hero, i);
				
				if(oneSkillData != null){
					
					skillData.add(oneSkillData);
				}
			}
		}
		//--------
		
		//----技能使用后的结算----
		iter = heroMap.values().iterator();
		
		while(iter.hasNext()){

			BattleHero hero = iter.next();
			
			if(hero.hpChange != 0){
			
				hero.hp = hero.hp + hero.hpChange;
				
				if(hero.hp < 1){
					
					iter.remove();
					
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
			}
		}
		
		if(skillData.size() > 0){
			
			skillResult = new int[skillData.size()][][];
			
			skillData.toArray(skillResult);
		}
		//--------
		
		//----开始攻击----
		int[][][] attackResult = null;
		
		HashMap<BattleHero, HashMap<BattleHero, Integer>> attackMap = new HashMap<>();
		HashMap<BattleHero, HashMap<BattleHero, Integer>> beAttackMap = new HashMap<>();
		
		iter = heroMap.values().iterator();
		
		while(iter.hasNext()){

			BattleHero hero = iter.next();
			
			if(!hero.csv.heroType.canAttack || (hero.isJustSummon && hero.csv.heroType.moveType != 2) || hero.power == 0 || hero.getAtk() < 1){
				
				continue;
			}
			
			ArrayList<BattleHero> heroArr = new ArrayList<>();
			ArrayList<Integer> directionArr = new ArrayList<>();
			
			BattlePublic.getHerosAndDirectionInRange(mapUnit.neighbourPosMap, heroMap, hero, 1, heroArr, directionArr);
			
			if(heroArr.size() > 0){
				
				int[] damageArr = BattlePublic.getDamageArr(hero, heroArr);
			
				HashMap<BattleHero, Integer> damageHeroMap = new HashMap<>();
				
				attackMap.put(hero, damageHeroMap);
				
				for(int i = 0 ; i < heroArr.size() ; i++){
				
					BattleHero targetHero = heroArr.get(i);
					
					int direction = directionArr.get(i);
					
					damageHeroMap.put(targetHero, damageArr[i]);
					
					HashMap<BattleHero, Integer> tmpMap = beAttackMap.get(targetHero);
					
					if(tmpMap == null){
						
						tmpMap = new HashMap<>();
						
						beAttackMap.put(targetHero, tmpMap);
					}
						
					tmpMap.put(hero, direction);
				}
			}
		}
		
		if(beAttackMap.size() > 0){
			
			ArrayList<int[][]> attackResultArr = new ArrayList<>();
		
			Iterator<Entry<BattleHero, HashMap<BattleHero, Integer>>> iter2 = beAttackMap.entrySet().iterator();
			
			while(iter2.hasNext()){
				
				Entry<BattleHero, HashMap<BattleHero, Integer>> entry = iter2.next();
				
				BattleHero hero = entry.getKey();
				
				HashMap<BattleHero, Integer> tmpMap = entry.getValue();
				
				int[][] attackHeroData = new int[tmpMap.size() + 1][];
				
				attackHeroData[0] = new int[]{hero.pos,0};
				
				Iterator<Entry<BattleHero, Integer>> iter3 = tmpMap.entrySet().iterator();
				
				int index = 0;
				
				boolean needCheckHit = false;
				
				ArrayList<Integer> targetArr = null;
				
				if(hero.power > 0){
					
					needCheckHit = true;
					
					targetArr = new ArrayList<>();
				}
				
				while(iter3.hasNext()){
					
					Entry<BattleHero, Integer> entry2 = iter3.next();
					
					int target = entry2.getValue();
					BattleHero attackHero = entry2.getKey();
					
					int damage = attackMap.get(attackHero).get(hero);
					
					attackHeroData[index + 1] = new int[]{attackHero.pos, damage};
					
					hero.hpChange = hero.hpChange - damage;
					
					if(needCheckHit){
						
						int attackHeroNum = attackMap.get(attackHero).size();
						
						if(attackHeroNum == 1 && !hero.hasLosePower){
							
							hero.hasLosePower = true;
						}
						
						if(!targetArr.contains(target)){
							
							targetArr.add(target);
						}
					}
					
					index++;
				}
				
				if(needCheckHit){
				
					int result = BattlePublic.checkAttackType(targetArr);
						
					if(result == 0){
						
						if(hero.hasLosePower){
							
							hero.power = hero.power - 1;
							
							attackHeroData[0][1] = 1;
							
						}else{
							
							attackHeroData[0][1] = 0;
						}
						
					}else{
						
						if(!hero.hasLosePower){
						
							hero.hasLosePower = true;
						}
						
						hero.power = hero.power - result;
						
						if(hero.power < 0){
							
							hero.power = 0;
						}
						
						attackHeroData[0][1] = result;
					}
					
				}else{
					
					attackHeroData[0][1] = 0;
				}
				
				attackResultArr.add(attackHeroData);
			}
			
			attackResult = new int[attackResultArr.size()][][];
			
			attackResultArr.toArray(attackResult);
		}
		//--------
		
		//----重置英雄数据----
		ArrayList<Integer> cantMoveHeroPosArr = new ArrayList<>();
		
		iter = heroMap.values().iterator();
		
		while(iter.hasNext()){
			
			BattleHero hero = iter.next();
			
			if(hero.hpChange < 0){
			
				hero.hp = hero.hp + hero.hpChange;
				
				if(hero.hp < 1){
					
//					service1.process("sendMsg", hero.pos + "die!!!");
					
					iter.remove();
					
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
			
//			service1.process("sendMsg", hero.pos + ":" + hero.hp);
			
			if(hero.isSilent){
				
				hero.isSilent = false;
			}
			
			if(hero.isJustSummon){
				
				hero.isJustSummon = false;
			}
			
			if(hero.moved){
				
				hero.moved = false;
			}
			
			if(!hero.hasLosePower && hero.power < hero.csv.maxPower){
				
				hero.power++;
			}
			
			hero.atkFix = hero.maxHpFix = 0;
			
			hero.hasLosePower = false;
			
			if(hero.power > POWER_CAN_MOVE){
				
				if(hero.csv.heroType.moveType != 0 && !hero.isStopMove){
					
					canMoveHeroArr.add(hero.pos);
				}
				
				if(hero.csv.heroType.canAttack){
				
					ArrayList<BattleHero> targetHeroArr = new ArrayList<>();
					
					BattlePublic.getHerosAndDirectionInRange(mapUnit.neighbourPosMap, heroMap, hero, 1, targetHeroArr, null);
					
					for(BattleHero tmpHero : targetHeroArr){
						
						if(!cantMoveHeroPosArr.contains(tmpHero.pos)){
							
							cantMoveHeroPosArr.add(tmpHero.pos);
						}
					}
				}
			}
		}
		
		Iterator<Integer> iter2 = canMoveHeroArr.iterator();
		
		while(iter2.hasNext()){
			
			int pos = iter2.next();
			
			if(cantMoveHeroPosArr.contains(pos)){
				
				iter2.remove();
			}
		}
		
		int[] canMoveData = null;
		
		if(canMoveHeroArr.size() > 0){
			
			canMoveData = new int[canMoveHeroArr.size()];
			
			int index = 0;
			
			for(int uid : canMoveHeroArr){
				
				canMoveData[index] = uid;
				
				index++;
			}
		}
		
		int cardUid1 = -1;
		int cardID1 = -1;
		
		if(userAllCards1.size() > 0){
			
			cardID1 = userAllCards1.remove(0);
			
			if(userCards1.size() < MAX_CARDS_NUM){

				cardUid1 = getUid();
				
				userCards1.put(cardUid1, cardID1);
			}
		}
		
		int cardUid2 = -1;
		int cardID2 = -1;
		
		if(userAllCards2.size() > 0){
			
			cardID2 = userAllCards2.remove(0);
			
			if(userCards2.size() < MAX_CARDS_NUM){

				cardUid2 = getUid();
				
				userCards2.put(cardUid2, cardID2);
			}
		}
		//--------
		
		service1.process("playBattle", summonResult1, summonResult2, moveResult, skillResult, attackResult, cardUid1, cardID1, cardUid2 == -1 ? cardID2 : -1, canMoveData);
		
		if(service2 != null){
		
			service2.process("playBattle", summonResult1, summonResult2, moveResult, skillResult, attackResult, cardUid2, cardID2, cardUid1 == -1 ? cardID1 : -1, canMoveData);
		}
	}
	
	public void battleOver(){
		
		canMoveHeroArr.clear();
		
		isActioned1 = isActioned2 = false;
		
		service1 = null;
		
		mapUnit = null;
		map = null;
		
		userCards1.clear();
		userCards2.clear();
		
		userAllCards1.clear();
		userAllCards2.clear();
		
		heroMap.clear();
		
		uidIndex = 1;
		
		if(service2 != null){
			
			service2 = null;
			GameQueue.getInstance().process("battleOver", this);
			
		}else{
			
			GameAi.getInstance().process("battleOver", this);
		}
	}
	
	public void quitBattle(UserService _service){
		
		if(_service == service1){
			
			service1.process("quitBattleOK", true);
			
			if(service2 != null){
				
				service2.process("leaveBattle", 0);
			}
			
			battleOver();
			
		}else if(_service == service2){
			
			service2.process("quitBattleOK", true);
			
			service1.process("leaveBattle", 0);
			
			battleOver();
			
		}else{
			
			_service.process("quitBattleOK", false);
		}
	}
}
