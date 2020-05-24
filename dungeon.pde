import processing.sound.*;
Player player;
Collision[] blokje = new Collision[0];//collision со стенами
OverworldObject[] map01obj = new OverworldObject[0];//интерактивные объекты (NPC, знаки
OverworldObject[] mapTransitions = new OverworldObject[0];//переходы между зонами (для потом) 
OverworldObject[] warpTiles = new OverworldObject[0];//для перемещения персонажа между уровнями 
OverworldObject[] grassPatches = new OverworldObject[0];//(для начала боевки тайлы где будет происходить бой 

//map parameters
final int rows = 20;
final int columns = 50;
final int tileSize = 16;
float owScaler = 3.0;

// Для варпа, названия городов, проверка на conversation
int currentArea; //used to know which area the player is in (town/route)
int notificationTimer = 0;
String[] areaName = {"TOWN", "DUNGEON"};
boolean grasspatchTick;//проверка наступил ли персонаж на тайл где могут напасть монстры

//игрок
float pPosX,pPosY;
boolean pLeft, pRight, pDown, pUp;

//картиночки
PImage pSprite, npcSprite01, npcSprite02, npcSprite03;//спрайты персонажей
PImage imgArrow, boxFrame01, boxFrame02, boxFrame03, boxFrame04, boxFrame05;// меню
PImage overworldmapImg,tileset01,stage1Img,stage2Img,stage3Img,stage4Img;//карта
PImage trainerSprite01, battleBackground01;//задний план боя и герой
PImage[] monstrSpritesFront = new PImage[0];
PImage[] monstrSpritesBack = new PImage[0];
PImage healthbarBg, healthbarOver, expbarOver;

//меню
PFont font;
boolean isInConversation = false; //не разговариваем с Нпс
int conversationNum = 0;//это для подсчета индексов в разговоре с нпс
String[] conversation = new String[0];//сохраняем фразу которую персонаж будет говорить
boolean owMenuOpened;
int owMenu = -1;
int menuOption, submenuOption;
int owMenu5option1 = 1;//позиция начала в меню
boolean healmonstr;//хилим персонажа если он умер

//warp var
int blackoutEffectAlpha;//transparency
boolean isTransitioning;
int fadeAmount = 15;//strength
float destinationX, destinationY;// координаты появления

//здесь будут перменные для монстров
String[] monstrList = {"PLAYER", "BAPHOMET", "BUGGIE", "MAYA","INU","GEN.TURTLE","ORC","RSX 0806","SNAKE LORD","WHITE LADY",};


//для боя переменные
boolean isBattling = false;//находимся ли мы в бою или нет
Monster opposingmonstr;//вражеский монстр
int battleOption;//выбор опций меню
boolean fightMenu, bagMenu;
SoundFile[] soundFile = new SoundFile[areaName.length];

//прогресс
int pBattlesWon;
int pPlaytimeFrame;

void setup()
{
	// сетап окна. Настройки графики. Функция выполняется один раз
  size(1000,700);
  frameRate(120);
  noSmooth();//пиксельное
  
  
  
  
  overworldmapImg = loadImage("data/sprites/map.png"); // загружаем главную мапу
  // Данж - 1, 2, 3 уровень и финальный босс. (карты)
  stage1Img = loadImage("data/sprites/stage1.png");
  stage2Img = loadImage("data/sprites/stage2.png");
  stage3Img = loadImage("data/sprites/stage3.png");
  stage4Img = loadImage("data/sprites/final.png");
  tileset01 = loadImage("sprites/spr_tileset01.png");//тайлсет

  // initialize the array
  for (int i=0; i<2; i++) {
    soundFile[i] = new SoundFile (this, "song"+i+".mp3");
  }
  soundFile[1].amp(0.3);
  soundFile[1].loop();

//menu stuff
  boxFrame01 = loadImage("data/sprites/boxFrame01.png");
  boxFrame02 = loadImage("data/sprites/boxFrame02.png");//box used in conversations
  boxFrame03 = loadImage("data/sprites/boxFrame03.png");//player overview
  boxFrame04 = loadImage("data/sprites/boxFrame04.png");
  boxFrame05 = loadImage("data/sprites/boxFrame05.png");
  imgArrow = loadImage("data/sprites/imgArrow.png");
    font = createFont("data/pkmrs.ttf", 14);
  textFont(font);
  //спрайты для монстров
PImage loadedBackImg = loadImage("data/sprites/spr_monstrback0.png");//спрайт для героя
   monstrSpritesBack = (PImage[]) append(monstrSpritesBack, loadedBackImg);
  for(int i = 0; i<monstrList.length; ++i)//для каждого монстра загружаем картинку
  {
    PImage loadedImg = loadImage("data/sprites/spr_monstr"+i+".png");
    monstrSpritesFront = (PImage[]) append(monstrSpritesFront, loadedImg);
  }
  
//NPC
  npcSprite01 = loadImage("data/sprites/spr_npc01.png");
  npcSprite02 = loadImage("data/sprites/spr_npc02.png");
  npcSprite03 = loadImage("data/sprites/spr_npc03.png");
  trainerSprite01 = loadImage("data/sprites/spr_trainer01.png");
  battleBackground01 = loadImage("data/sprites/img_battleBackground01.jpg");
  battleBackground01.resize(width,height);
    
  //для перса
  pSprite = loadImage("sprites/spr_player01.png");
  Monster[] testPlayerTeam = new Monster[1];
  int playerStarterMonster = int(monstrList[0]);//это для боевки потом
  testPlayerTeam[0] = new Monster(playerStarterMonster, 5, int(random(10,20)), int(random(3,10)), int(random(3,10)), int(random(3,10)), 0, 0); // для боевки
  player = new Player(tileSize*5,tileSize*7, pSprite, testPlayerTeam);
  
  //для боевки еще
  healthbarBg = loadImage("data/sprites/spr_healthbarBg.png");
  healthbarOver = loadImage("data/sprites/spr_healthbarOverlay.png");
  expbarOver = loadImage("data/sprites/spr_expbarOverlay.png");

  
 loadCollision();
   loadEntities();
}

void loadCollision()
{
  String[] loadFile = loadStrings("data/scripts/map01collision.txt");
  String[] dissection = new String[0];
  
  for(int i = 0; i<loadFile.length; ++i)
  {
    dissection = split(loadFile[i], ",");
    //только применять collison если в файле начинается с 0 "0" (1 для комментариев)
    if(int(dissection[0]) == 0) blokje = (Collision[]) append(blokje, new Collision(float(dissection[1])*tileSize,float(dissection[2])*tileSize,tileSize));
  } 
}

void loadEntities()
{  
  //map01entities.txt: ID, posX, posY, object type
  //disectEnts[0]: -3 и ниже = NPC / -2 = варп / -1 = переходы / 0 and above = статичные интерактивные знаки
  //mapTransitions: ID = -1 / object type =название зоны
  //warps: ID = -2 / type 0 = варп на след зону / type 1 = варп к предыдущему
  String[] loadEnts = loadStrings("data/scripts/map01entities.txt");
  String[] disectEnts = new String[0];
  for(int i = 0; i<loadEnts.length; ++i)
  {
    disectEnts = split(loadEnts[i], ",");
    if(int(disectEnts[0]) == -5) map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, npcSprite03, int(disectEnts[3])));
    if(int(disectEnts[0]) == -4) map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, npcSprite02, int(disectEnts[3])));
    if(int(disectEnts[0]) == -3) map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, npcSprite01, int(disectEnts[3])));
    if(int(disectEnts[0]) == -2) warpTiles = (OverworldObject[]) append(warpTiles, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, null, int(disectEnts[3])));
    if(int(disectEnts[0]) == -1) mapTransitions = (OverworldObject[]) append(mapTransitions, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, null, int(disectEnts[3])));
    if(int(disectEnts[0]) > 0 && int(disectEnts[0]) != 10)  map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, tileset01.get(int(disectEnts[0])*tileSize,0,tileSize,tileSize), int(disectEnts[3])));
    if(int(disectEnts[0]) == 10) grassPatches = (OverworldObject[]) append(grassPatches, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, tileset01.get(int(disectEnts[0])*tileSize,0,tileSize,tileSize), 0));
  }
  
}
void draw()
  {
   pPlaytimeFrame++;//увеличивается про каждом фрейме
  background(0);
    
  if(isBattling)//рисуем боевку
  {
    image(battleBackground01,0,0);
    soundFile[currentArea].stop();
    imageMode(CENTER);
    textAlign(CENTER);
    rectMode(CENTER);
    textSize(24);
    
    
    opposingmonstr.setPosition(width*0.85,height*0.45);//позиция монстра
    opposingmonstr.setSprite(monstrSpritesFront[opposingmonstr.getMonsterID()]);//загружаем спрайт
    opposingmonstr.display();//рисуем
    image(boxFrame05, width*0.85, height*0.45-130);
    textMessage(width*0.85, height*0.45-130, opposingmonstr.m_name+ " lv."+ opposingmonstr.m_lvl, color(0));//имя монстра и уровень
    
    //playerMonster = player.getPlayerMonster(0);
    player.getPlayerMonster(0).setPosition(width*0.25, height*0.65);//позиция героя
    player.getPlayerMonster(0).setSprite(monstrSpritesBack[player.getPlayerMonster(0).getMonsterID()]);//устанаваливаем спрайт
    player.getPlayerMonster(0).display();//рисуем
    image(boxFrame05, width*0.25, height*0.65-150);
    textMessage(width*0.25, height*0.65-150, player.getPlayerMonster(0).m_name+ " lv."+ player.getPlayerMonster(0).m_lvl, color(0));

    if(isInConversation == true) 
    {
      conversationHandler(1);  // (1 - сообщения для батла)
    }
    else
    {
      image(boxFrame05, width/2, height*0.75);//бой
      image(boxFrame05, width/2-boxFrame05.width*0.75, height*0.85);//сумка
      image(boxFrame05, width/2+boxFrame05.width*0.75, height*0.85);//выход
      color c = 0;
      
      if(fightMenu == true)
      {
       
        textMessage(width/2,height*0.75+10,player.getPlayerMonster(0).getMonsterMoveName(0), color(30,30,30));//первая атака  
        textMessage(width/2-boxFrame05.width*0.75,height*0.85+10,player.getPlayerMonster(0).getMonsterMoveName(1), color(30,30,30));//вторая атака
        textMessage(width/2+boxFrame05.width*0.75,height*0.85+10,player.getPlayerMonster(0).getMonsterMoveName(2), color(30,30,30));

      }
     
      else if(bagMenu == true)//если мы выбрали сумку
      {
        if(player.getItemCount(1) <= 0) c = color(200,0,0);
        else c = 0;
        textMessage(width/2,height*0.75+10,"POTION x"+player.getItemCount(1), c);
        c = 0;//the unused item slots are just colored black
        textMessage(width/2-boxFrame05.width*0.75,height*0.85+10,"-----", c);
        textMessage(width/2+boxFrame05.width*0.75,height*0.85+10,"-----", c);
  
      }
      else if(fightMenu == false && bagMenu == false)//основное мееню боевки
      {
        textMessage(width/2,height*0.75+10,"FIGHT", color(200,0,0));//бой text
        textMessage(width/2-boxFrame05.width*0.75,height*0.85+10,"BAG", color(0,0,200));//сумка text
        textMessage(width/2+boxFrame05.width*0.75,height*0.85+10,"RUN", color(0,50,0));//выход из боя text
      }
        
      //выбор (красным выделение)
      noFill();
      stroke(225,0,0);//red
      strokeWeight(8);
      if(battleOption == 0) rect(width/2,height*0.75,boxFrame05.width, boxFrame05.height);//вверх
      else if(battleOption == 2) rect(width/2+boxFrame05.width*0.75,height*0.85,boxFrame05.width, boxFrame05.height); //право 
      else if(battleOption == 1) rect(width/2-boxFrame05.width*0.75,height*0.85,boxFrame05.width, boxFrame05.height); //лево 
    }
    
    imageMode(CORNER);
    textAlign(LEFT);
    rectMode(CORNER);
    
    //жизнь и опыт
    drawInfoBar(width*0.85-boxFrame05.width*0.4, height*0.27, opposingmonstr.getMonsterHP(), opposingmonstr.getMonsterMaxHP(), opposingmonstr.getMonsterEXP(), opposingmonstr.getMonsterMaxEXP());//healthbar opposing monstr
    drawInfoBar(width*0.25-boxFrame05.width*0.4, height*0.44, player.getPlayerMonster(0).getMonsterHP(), player.getPlayerMonster(0).getMonsterMaxHP(), player.getPlayerMonster(0).getMonsterEXP(), player.getPlayerMonster(0).getMonsterMaxEXP());//healthbar player monstr
  }
  else //рисуем обычный мир
  {
    pushMatrix();	// сохраняем текущую систему координат
    translate(width/2,height/2);	//центр экрана
    scale(owScaler);	//зум
    translate(player.getPosX()*-1-(tileSize/2),player.getPosY()*-1-(tileSize/2));	//для того чтоб камера на центре была
    drawOverworldmap(); // прорисовка карты 
    
	
	
    //тайлы
    noFill();
    for(int i = 0; i<columns; ++i)
    {   
      for(int j = 0; j<rows; ++j)
      {
        rect(i*tileSize,j*tileSize,tileSize,tileSize);
      }
    }
	  
    if(owMenuOpened == false && isInConversation == false)//меню не открыто и мы не разговариваем с нпс
    {
         if(player.getIsMoving() == false)//
      {
        if(pUp) checkCollision(3);
        else if(pDown) checkCollision(1);      
        else if(pLeft) checkCollision(2);
        else if(pRight) checkCollision(0);

      }   
	  
	  }
    //рисуем объекты
    for(int i = 0; i<map01obj.length; ++i)
    {
      map01obj[i].display();  
    }
    
    //рисуем траву (убрать потом) и ставим что только на этих тайлов может начатся бой
    for(int i = 0; i<grassPatches.length; ++i)
    {
      grassPatches[i].display();//прорисовка травы
      //проверка насупил ли персонаж на такой тайл
      if(player.getCheckTile() && player.getPosX() == grassPatches[i].getPosX() && player.getPosY() == grassPatches[i].getPosY())
      {   
        int battleRNGInitializer = int(random(8));//шанс что начнется бой
        if(battleRNGInitializer == 0 && player.getPlayerMonster(0).getMonsterHP() > 0 && player.getPlayerTeam().length > 0)//если персонаж живой, начинается бой
        {
          opposingmonstr = new Monster((int)random(1,9), int(random(2,5)), int(random(10,20)), int(random(3,10)), int(random(3,10)), int(random(3,10)), 0, 0);
          isBattling = true;
          player.setMoveState(false);//персонаж останавливается на карте
          println("battle");
        }
      }
    }
    
    player.display();//рисуем персонажа
    
    popMatrix();
    
    displayOWMenu();
    handleTransitions();
  
    //текст с информацией
    fill(0);//black
    textSize(24);
    textAlign(LEFT);
    textLeading(30);
    if(owMenu == -1 || owMenuOpened == false) textMessage(10, 30, "X = взаимодействие\nEnter = открыть и закрыть меню\nArrow keys = ходьба\nR = сбросить позицию на начальную\nP = загрузка сохранения", color(255));
    
    if(isInConversation == true) conversationHandler(0);
  
    blackoutEffect();
  }
}

void keyPressed()
{
  if(isBattling)//если мы в бою
  {
    if(keyCode == UP) battleOption = 0;
    if(keyCode == LEFT) battleOption = 1;
    if(keyCode == RIGHT) battleOption = 2;
    
    if(isInConversation == true)
    {
      if(key == 'x')
      {
        conversationNum++;
        if(conversationNum >= conversation.length)
        {
          isInConversation = false;
          conversationNum = 0;
          conversation = new String[0];
        }
      }
    }
    else
    {
      if((key == 'z' || key == 'w') && player.getPlayerMonster(0).getMonsterHP() > 0)
      {
        fightMenu = false;
        bagMenu = false;
      }
      
      if(key == 'x' && fightMenu == false  && bagMenu == false)//главное меню боевки
      {
        if(battleOption == 0) fightMenu = true;
        if(battleOption == 1) bagMenu = true;
        if(battleOption == 2) isBattling = false;//выход из боя
        battleOption = 0;//устанавливаем изначально на первую опцию
      }
     
      else if(key == 'x' && fightMenu == true && battleOption < player.getPlayerMonster(0).getMonsterMovesAmount())//Меню БОЙ
      {
        isInConversation = true;//выводим информацию о том что происходит

        int opposingmonstrMove =  int(random(opposingmonstr.getMonsterMovesAmount())); //атака монстра  
        if(player.getPlayerMonster(0).getMonsterSpeed() >= opposingmonstr.getMonsterSpeed())//если персонаж быстрее монстра
        {
          conversation = append(conversation, "Ты "+ player.getPlayerMonster(0).getMonsterName() +" использовал "+ player.getPlayerMonster(0).getMonsterMoveName(battleOption));
          battleMove(player.getPlayerMonster(0), opposingmonstr, battleOption);//атаки будут использованы        
          conversation = append(conversation, "Монстр "+ opposingmonstr.getMonsterName() +" использовал "+ opposingmonstr.getMonsterMoveName(opposingmonstrMove));
          battleMove(opposingmonstr, player.getPlayerMonster(0), opposingmonstrMove);
        }
        else//если монстр быстрее персонажа
        {
          conversation = append(conversation, "Монстр "+ opposingmonstr.getMonsterName() +" использовал "+ opposingmonstr.getMonsterMoveName(opposingmonstrMove));
          battleMove(opposingmonstr, player.getPlayerMonster(0), opposingmonstrMove);       
          conversation = append(conversation, "Ты "+ player.getPlayerMonster(0).getMonsterName() +" использовал "+ player.getPlayerMonster(0).getMonsterMoveName(battleOption));
          battleMove(player.getPlayerMonster(0), opposingmonstr, battleOption);
        }
        fightMenu = false;
        battleOption = 0;//после хода опять ставим изначально на бой
        
        if(opposingmonstr.getMonsterHP() <= 0 || player.getPlayerMonster(0).getMonsterHP() <= 0)//если кто то умер
        {
          conversation = new String[0];
          if(player.getPlayerMonster(0).getMonsterHP() <= 0) //если персонаж умер
          {
            conversation = append(conversation, "Ты" +player.getPlayerMonster(0).getMonsterName()+ " был убит!\nМонстр тебя победил!");
          }
          else if(opposingmonstr.getMonsterHP() <= 0)//если монстр умер
          {
            conversation = append(conversation, "Монстр " +opposingmonstr.getMonsterName() +" был убит!\n " +player.getPlayerMonster(0).getMonsterName()+ " получаешь "+ (opposingmonstr.getMonsterLvl()*100) +" Опыта!");
            player.getPlayerMonster(0).raiseExp(opposingmonstr.getMonsterLvl()*100);
            ++pBattlesWon;//счетсик сколько боев выигранно
          }
          else//если оба умерли
          {
            conversation = append(conversation, "Ты и монстр убили себя друг друга!");
          }
          isInConversation = true;
          isBattling = false;
        }
      }
      else if(key == 'x' && bagMenu == true)//меню сумки
      {
        if(battleOption < 2)//пока только 2 вещей
        {
          conversation = new String[0];

          if(battleOption == 0 && player.getItemCount(1) > 0)//зелье
          {
            int opposingmonstrMove =  int(random(opposingmonstr.getMonsterMovesAmount())); //атака монстра  
            conversation = append(conversation, "Монстр "+ opposingmonstr.getMonsterName() +" использовал "+ opposingmonstr.getMonsterMoveName(opposingmonstrMove)+ "\nСразу после того как ты выпил зелье!");
            player.getPlayerMonster(0).setHP(player.getPlayerMonster(0).getMonsterMaxHP());//ставим хп персонажа на макс.
            player.setItemCount(1, player.getItemCount(1)-1);//отнимаем предмет 
            battleMove(opposingmonstr, player.getPlayerMonster(0), opposingmonstrMove); //так как зелья отнимают твой ход, то монстр атакует
          }
          if(conversation.length != 0)
          {
            isInConversation = true;
            bagMenu = false;
            battleOption = 0;
          }
        }
      }
    }
  }
  else //вне боя
  {

    if(key == 'p')//загрузка сохранения
    {
      String[] loadfile = loadStrings("savegame01.txt");
      player.setPosition(float(loadfile[0]), float(loadfile[1]));
      surface.setSize(int(loadfile[2]), int(loadfile[3]));
      battleBackground01.resize(width,height);
      player.setItemCount(0, int(loadfile[4]));
      player.setItemCount(1, int(loadfile[5]));
      pBattlesWon = int(loadfile[6]);

      pPlaytimeFrame = 0;

      Monster[] importPlayerMonsterTeam = new Monster[0];
      for(int i = 0; i<loadfile.length; ++i)
      {
        String[] dissection = split(loadfile[i], "/");
        if(int(dissection[0]) == -100)
        {
          importPlayerMonsterTeam = (Monster[]) append(importPlayerMonsterTeam, new Monster(int(dissection[1]), int(dissection[2]), int(dissection[4]), int(dissection[5]), int(dissection[6]), int(dissection[7]), 0, 0));
          importPlayerMonsterTeam[importPlayerMonsterTeam.length-1].setHP(int(dissection[3]));//ставим хп
        }
      }
      player.setPlayerTeam(importPlayerMonsterTeam);
    }
  
    if(keyCode == 10 && isInConversation == false)
    {
      owMenuOpened = !owMenuOpened;
      owMenu = -1;
    }
    
    if(owMenuOpened == false && isInConversation == false && isTransitioning == false)//никакое меню не открыто и мы не переходим локацию
    {
      if(keyCode == LEFT) pLeft = true;
      if(keyCode == RIGHT) pRight = true;
      if(keyCode == UP) pUp = true;
      if(keyCode == DOWN) pDown = true;
      if(key == 'x') 
      {
        checkPlayerInteraction();
        checkWarp();//проверям не стоим ли мы перед варпом
      }
      if(key == 'r' && player.getIsMoving() == false) player.setPosition(tileSize*5,tileSize*7);
    }
    else if(isInConversation == true)
    {
      if(key == 'x')
      {
        conversationNum++;
        if(conversationNum >= conversation.length)
        {
          isInConversation = false;
          conversationNum = 0;
          conversation = new String[0];
        }
      }
    }
    
    if(owMenu == -1 && owMenuOpened == true)//если мы нажали на enter вне боя
    {
      if(keyCode == DOWN) menuOption = (menuOption+1)%4;//вниз 4 пункта
      if(keyCode == UP) menuOption--;//вверх выбор
      if(menuOption < 0) menuOption = 3;//самый нижний пункт после которого ниже нельзя
      
      if(key == 'z' || key == 'w') owMenuOpened = false;
      if(key == 'x')
      {
        owMenu = menuOption;
        submenuOption = 0;
      }
    }

    else if(owMenu == 0 && owMenuOpened == true)//Сумка
    {
      if(key == 'z' || key == 'w') owMenu = -1;
    }
    else if(owMenu == 1 && owMenuOpened == true)//Игрок
    {
      if(key == 'z' || key == 'w') owMenu = -1; 
    }
   
    else if(owMenu == 2 && owMenuOpened == true)
    {
      if(key == 'z' || key == 'w') owMenu = -1; // Назад
      if(keyCode == DOWN) submenuOption = 0;// Нет
      if(keyCode == UP) submenuOption = 1;// Да
      if(key == 'x' && submenuOption == 0) owMenu = -1;//submenuOption дефолт = 0
      if(key == 'x' && submenuOption == 1)// сохранить игру
      {
        String[] savefile = new String[0];
        savefile = append(savefile, str(player.getPosX()));// Х - позиция
        savefile = append(savefile, str(player.getPosY()));// Y - позиция
        savefile = append(savefile, str(width));
        savefile = append(savefile, str(height));
        savefile = append(savefile, str(player.getItemCount(0))); /* сохраняет инвентарь */
        savefile = append(savefile, str(player.getItemCount(1))); /* сохраняет инвентарь */
        savefile = append(savefile, str(pBattlesWon));
       
        saveStrings("savegame01.txt", savefile);
        
        owMenu = -1;//return to main overworld menu
        owMenuOpened = false;//turn the main overworld menu off
        menuOption = 0;//reset back to top option 
    }
   
    
    if(owMenu == 3 && owMenuOpened == true)//выход
    {
        owMenuOpened = false;
        owMenu = -1;
    }
  }
}
}
void keyReleased()
{
  if(keyCode == LEFT) pLeft = false;
  if(keyCode == RIGHT) pRight = false;
  if(keyCode == UP) pUp = false;
  if(keyCode == DOWN) pDown = false;
}

//меню
void displayOWMenu()
{
  if(owMenu == -1 && owMenuOpened == true)//главное меню
  {
    textSize(24);
    int textGap = 45;
    
    image(boxFrame01, width-boxFrame01.width, height/2-boxFrame01.height/2);
    textAlign(CENTER);
    rectMode(CENTER);
    color c = color(40);
    float textPosX = width-boxFrame01.width/2;
    float textPosY = height/2-boxFrame01.height/2;
    textLeading(45);//vertical spacing between textlines (\n)
    textMessage(textPosX,textPosY+textGap,"BAG\nPLAYER\nSAVE\nEXIT", c);
    image(imgArrow, width-boxFrame01.width+10, textPosY+30+(menuOption*textGap));
    rectMode(CORNER);
  }
  if(owMenu == 0)//сумка
  {
    imageMode(CENTER);
    image(boxFrame03,width/2,height/2);
    imageMode(CORNER);
    color c = color(40);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+20, height/2-boxFrame03.height/2+40,"\nPOTIONS x"+ player.getItemCount(0), c);//сколько зелья у нас находится
  }
  if(owMenu == 1)//игрок
  {
    imageMode(CENTER);
    image(boxFrame03,width/2,height/2);
    imageMode(CORNER);
    image(trainerSprite01, width/2+boxFrame03.width/2-trainerSprite01.width, height/2-boxFrame03.height/2+5);
    color c = color(40);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+20, height/2-boxFrame03.height/2+40,"NAME\nGENDER\nBATTLES WON\nPLAY TIME", c);
    textMessage(width/2, height/2-boxFrame03.height/2+40, "PLAYER\nMALE\n"+ pBattlesWon, c);
  }
  if(owMenu == 2)//сохранение
  {
    int gap = 20;
    imageMode(CENTER);
    image(boxFrame03,width/2,height/2);
    image(boxFrame02,width/2,height*0.8);
    imageMode(CORNER);
    color c = color(40);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+gap, height/2-boxFrame03.height/2+gap*3,"SAVEFILE NAME\n\nSAVING:\n- POSITION\n- PROGRESS\n- STATS", c);//text in top box left
    textMessage(width/2, height/2-boxFrame03.height/2+gap*3, "savegame01.txt", c);//top box right
    textMessage(width/2-boxFrame02.width/2+gap, height*0.75+gap, "THE SAVEFILE WILL BE OVERWRITTEN.\nARE YOU SURE?", color(40));//bottom box
    textMessage(width/2+boxFrame02.width/4+gap, height*0.75+gap, "YES\nNO", color(40));//confirmation
    image(imgArrow, width/2+boxFrame02.width/4, height*0.75+35-(submenuOption*(30)));
    stroke(255,0,0);
    noFill();
  }
}
void drawOverworldmap()
{
  image(overworldmapImg,0,0);
  image(stage1Img,100*tileSize,0); // 1 данж (+100 по x)
  image(stage2Img,200*tileSize,0); // 2
  image(stage3Img,300*tileSize,0); // 3
  image(stage4Img,400*tileSize,0); // финальный

  // Music
  soundFile[currentArea].amp(0.3);
  soundFile[currentArea].loop();
}

  void checkCollision(int direction)
{
  boolean playerCollision = false;
  //со стенами коллижн
  for (int i = 0; i<blokje.length; ++i)
  {
    if (blokje[i].checkCollision(player.getPosX(), player.getPosY(), direction))//сравнение координат персонажа с координатами стены, если да, то столкновение
    {
      playerCollision = true;
    }
  }  
  //Коллижн с объектами
  for (int i = 0; i<map01obj.length; ++i)
  {
    if (map01obj[i].checkCollision(player.getPosX(), player.getPosY(), direction))// чек на колижн
    {
      playerCollision = true; // колижн
    }
  }  
  
  if(playerCollision == false)
  {
    player.move(direction);
    player.setMoveState(true);
  }
  else if(playerCollision == true)
  {
    player.setDirection(direction);
    player.setMoveState(false);
  }
}

// *** ВАРП ПЕРСОНАЖА НА ДРУГИЕ ЛОКАЦИИ *** \\
// чек варп, анимация затемнения, проверки

void blackoutEffect()
{
  noStroke();
  fill(0,0,0,blackoutEffectAlpha); // черный
  
  if(isTransitioning)
  {
    rect(0,0,width,height);
    blackoutEffectAlpha += fadeAmount;
    
    if(blackoutEffectAlpha >= 255) 
    {
      fadeAmount *= -1;// Максимум угасает - начинает появляться
      player.setPosition(destinationX,destinationY);
    }
    if(blackoutEffectAlpha <= 0)// Если достигли 0, перемещение окончено (затемнение)
    {
      blackoutEffectAlpha = 0;
      fadeAmount = 15;
      isTransitioning = false;
    }
  }
}

void textMessage(float posX, float posY, String text, color c)
{
    fill(125);
    text(text, posX+1, posY+1);
    fill(c);
    text(text, posX, posY);
}

void handleTransitions()
{
  for(int i = 0; i<mapTransitions.length; ++i)
  {
    if(player.getPosX() == mapTransitions[i].getPosX() && player.getPosY() == mapTransitions[i].getPosY() && currentArea != mapTransitions[i].getNPCType())
    {
      notificationTimer = 360;
      currentArea = mapTransitions[i].getNPCType();// карта на которой находится
    }
  }
  
  if(notificationTimer > 0)
  {
    textAlign(CENTER);
    image(boxFrame02, width/2-boxFrame02.width/2, height*0.05);//background box
    textSize(48);
    textMessage(width/2, height*0.15, areaName[currentArea], color(40));// смена названия территории на которой находится
    notificationTimer--;
  }  
}

void checkWarp()
{
  for(int i = 0; i<warpTiles.length; ++i)
  {
    //если игрок стоит перед тайлом с варпом и смотрит на него, портнуть игрока
    if((player.getPosX() == warpTiles[i].getPosX() && player.getPosY() == warpTiles[i].getPosY()+(1*tileSize) && player.getDirection() == 3) || (player.getPosX() == warpTiles[i].getPosX() && player.getPosY() == warpTiles[i].getPosY()-(1*tileSize) && player.getDirection() == 1))
    {
      if(warpTiles[i].getNPCType() == 0)
      {
        destinationX = warpTiles[i+1].getPosX();
        destinationY = warpTiles[i+1].getPosY()-(1*tileSize);
        isTransitioning = true;
      }
      else if(warpTiles[i].getNPCType() == 1)
      {
        destinationX = warpTiles[i-1].getPosX();
        destinationY = warpTiles[i-1].getPosY()+(1*tileSize);
        isTransitioning = true;
      }
    }
  }
  
}


//рисуем опыт и хп персонажа
void drawInfoBar(float posX, float posY, float health, float maxHP, float exp, float maxExp)
{
  noStroke();
  //хп
  image(healthbarBg, posX, posY);
  fill(0,158,14);
  rect(posX+25, posY, (health/maxHP)*(healthbarOver.width-27), healthbarOver.height);
  image(healthbarOver, posX, posY);
  //опыт
  image(healthbarBg, posX, posY+expbarOver.height+2);
  fill(0,148,255);
  rect(posX+25, posY+expbarOver.height+2, (exp/maxExp)*(healthbarOver.width-27), healthbarOver.height);
  image(expbarOver, posX, posY+expbarOver.height+2);
}

void conversationHandler(int type)//type 0 = на карте разговор, type 1 = во время боя разговор
{
  int gap = 20;//расстояние между текстом и краем
  textAlign(LEFT);
  imageMode(CENTER);
  if(type == 0) image(boxFrame02, width/2, height*0.8);
  if(type == 1) image(boxFrame02, width/2, height*0.1);
  imageMode(CORNER);
  
  fill(0);//black
  textFont(font);
  textSize(28);
  textLeading(30);
  if(type == 0) textMessage(width/2-boxFrame02.width/2+gap , height*0.75+gap, conversation[conversationNum], color(40));
  else if(type == 1) textMessage(width/2-boxFrame02.width/2+gap , height*0.1, conversation[conversationNum], color(40));
}


void battleMove(Monster attacker, Monster target, int move)
{
  int fullDamage = (attacker.getMonsterMoveDamage(move)*attacker.getMonsterAtt())/(target.getMonsterDef()*2);//берем урон атаки и умножаем на статистику аттаки после чего делим защиту моснтра и так получаем урон хода


//здесь в зависимости от типа монстра, будет идти разный удар
  if(checkMoveEffectiveness(attacker.getMonsterMoveType(move), target.getType()) == 0)
  {
    target.reduceHP(fullDamage);
  }
  if(checkMoveEffectiveness(attacker.getMonsterMoveType(move), target.getType()) == -1) //не эффективный удар
  {
    target.reduceHP(int(fullDamage*0.5));
    conversation = append(conversation, "It was not very effective!");
  }
  if(checkMoveEffectiveness(attacker.getMonsterMoveType(move), target.getType()) == 1)//очень эффективный удар
  {
    target.reduceHP(int(fullDamage*1.5));
    conversation = append(conversation, "It was super effective!");
  }
}


void checkPlayerInteraction()
{
  for (int i = 0; i<map01obj.length; ++i)
  {
    if (map01obj[i].checkCollision(player.getPosX(), player.getPosY(), player.getDirection()))//коллижн с объектом
    {
      //меняем направление спрайта npc
      if(map01obj[i].getNPCType() == 0)//type 0 = npc
      {
        if(player.getDirection() == 0) map01obj[i].changeDir(2);
        else if(player.getDirection() == 1) map01obj[i].changeDir(3);
        else if(player.getDirection() == 2) map01obj[i].changeDir(0);
        else if(player.getDirection() == 3) map01obj[i].changeDir(1);
      }
      isInConversation = true;//теперь разговариваем с npc
      
      //загрузка текстов персонажей и знаков
      String[] loadFile = loadStrings("data/scripts/map01strings.txt");
      String[] dissection = new String[0];
      for(int j = 0; j<loadFile.length; ++j)
      {
        dissection = split(loadFile[j], "/");
        if(int(dissection[0]) == i) conversation = append(conversation, dissection[1]);
      }

      for(int k = 0; k<conversation.length; ++k)
      {
        conversation[k] = conversation[k].replaceAll("NEWLINE", "\n");
      }
      println("Character ID: "+i);//печатаем ID перса с которым разговариваем
      if(i== 1)//если разговор пошел с боссом то начинается бой с ним
      {
        opposingmonstr = new Monster(9, 10, 20, int(random(7,10)), int(random(8,10)), int(random(7,10)), 0, 0);
          isBattling = true;
          player.setMoveState(false);
      }
        if(i== 0)//хиллим
      {
        destinationX = player.getPosX();//transitioning will move our player, so we need to store our current position
            destinationY = player.getPosY();
            isTransitioning = true;
            player.healAllmonstr();
            println("healed.");
      }
    }
  }
}

//здесь и происходит проверка какой тип кому сильнее или слабее
int checkMoveEffectiveness(String attacker, String target)
{
  //-1 = не эффективно / 0 = стандарт / 1 = очень эффективно
  int result = 0;
  if(attacker.equals("fire") && target.equals("water")) result = -1;
  if(attacker.equals("fire") && target.equals("grass")) result = 1;
  if(attacker.equals("grass") && target.equals("water")) result = 1;
  if(attacker.equals("grass") && target.equals("fire")) result = -1;
  if(attacker.equals("grass") && target.equals("flying")) result = -1;
  if(attacker.equals("water") && target.equals("fire")) result = 1;
  if(attacker.equals("water") && target.equals("grass")) result = -1;
  if(attacker.equals("water") && target.equals("electric")) result = -1;
  if(attacker.equals("flying") && target.equals("grass")) result = 1;
  if(attacker.equals("flying") && target.equals("electric")) result = -1;
  if(attacker.equals("electric") && target.equals("grass")) result = -1;
  if(attacker.equals("electric") && target.equals("water")) result = 1;
  if(attacker.equals("electric") && target.equals("flying")) result = 1;

  if(attacker.equals(target) && attacker.equals("normal") == false && attacker.equals("flying") == false) result = -1;
  return result;
}