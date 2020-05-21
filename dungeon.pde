import processing.sound.*;
Player player;
Collision[] blokje = new Collision[0];//collision со стенами
OverworldObject[] map01obj = new OverworldObject[0];//интерактивные объекты (NPC, знаки
OverworldObject[] mapTransitions = new OverworldObject[0];//переходы между зонами (для потом) todo
OverworldObject[] warpTiles = new OverworldObject[0];//для перемещения персонажа между уровнями (тоже потом)todo
OverworldObject[] grassPatches = new OverworldObject[0];//(для начала боевки тайлы где будет происходить бой todo
//map parameters
final int rows = 20;
final int columns = 50;
final int tileSize = 16;
float owScaler = 3.0;

// Для варпа, названия городов, проверка на conversation
int currentArea; //used to know which area the player is in (town/route)
int notificationTimer = 0;
String[] areaName = {"TOWN", "DUNGEON"};
boolean isInConversation = false;

//player variables
float pPosX,pPosY;
boolean pLeft, pRight, pDown, pUp;
PImage pSprite, npcSprite01, npcSprite02, npcSprite03;//спрайты персонажей
PImage imgArrow, boxFrame01, boxFrame02, boxFrame03, boxFrame04, boxFrame05;// меню
PImage overworldmapImg,tileset01,stage1Img,stage2Img,stage3Img,stage4Img;//карта
PFont font;

//warp var
int blackoutEffectAlpha;//transparency
boolean isTransitioning;
int fadeAmount = 15;//strength
float destinationX, destinationY;// координаты исчезания/появления

//здесь будут перменные для монстров
String[] monstList = {"PLAYER", "CHARMANDER", "SQUIRTLE", "PIDGEY", "RATTATA", "PIKACHU", "VULPIX"}; 
// todo: добавить пикчи
// todo: добавить названия монстров
boolean isBattling = false;

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

//menu stuff
  boxFrame01 = loadImage("data/sprites/boxFrame01.png");
  boxFrame02 = loadImage("data/sprites/boxFrame02.png");//box used in conversations
  boxFrame03 = loadImage("data/sprites/boxFrame03.png");//player overview
  boxFrame04 = loadImage("data/sprites/boxFrame04.png");
  boxFrame05 = loadImage("data/sprites/boxFrame05.png");

//NPC
  npcSprite01 = loadImage("data/sprites/spr_npc01.png");
  npcSprite02 = loadImage("data/sprites/spr_npc02.png");
  npcSprite03 = loadImage("data/sprites/spr_npc03.png");
  font = createFont("data/pkmnrs.ttf", 14);
  textFont(font);
    
  //для перса
  pSprite = loadImage("sprites/spr_player01.png");
  Monster[] testPlayerTeam = new Monster[1];
  int playerStarterMonster = int(monstList[0]);//это для боевки потом
  testPlayerTeam[0] = new Monster(playerStarterMonster, 5, int(random(10,20)), int(random(3,10)), int(random(3,10)), int(random(3,10)), 0, 0); //тест для боевки
  player = new Player(tileSize*5,tileSize*7, pSprite, testPlayerTeam);
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
         if(player.getIsMoving() == false)//
      {
        if(pUp) checkCollision(3);
        else if(pDown) checkCollision(1);      
        else if(pLeft) checkCollision(2);//move the player to the left
        else if(pRight) checkCollision(0);

      }   
    player.display();	// проросовка игрока
  
    popMatrix();

    handleTransitions();
  
    fill(0);
    textSize(24);
    textAlign(LEFT);
    textLeading(30);

    blackoutEffect();
  }

void keyReleased()
{
  if(keyCode == LEFT) pLeft = false;
  if(keyCode == RIGHT) pRight = false;
  if(keyCode == UP) pUp = false;
  if(keyCode == DOWN) pDown = false;
}


void drawOverworldmap()
{
  image(overworldmapImg,0,0);
  image(stage1Img,100*tileSize,0); // 1 данж (+100 по x)
  image(stage2Img,200*tileSize,0); // 2
  image(stage3Img,300*tileSize,0); // 3
  image(stage4Img,400*tileSize,0); // финальный
}

void keyPressed()
{
      if(keyCode == LEFT) pLeft = true;
      if(keyCode == RIGHT) pRight = true;
      if(keyCode == UP) pUp = true;
      if(keyCode == DOWN) pDown = true;
    
    if(key == 'x') //A button on Gameboy
      {
        checkPlayerInteraction();
        checkWarp();//check if we're standing in front of a door 
      }
  }
  void checkCollision(int direction)
{
  boolean playerCollision = false;
  //collision with walls
  for (int i = 0; i<blokje.length; ++i)
  {
    if (blokje[i].checkCollision(player.getPosX(), player.getPosY(), direction))//collision
    {
      playerCollision = true;
    }
  }  
  //collision with objects
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

void checkPlayerInteraction()
{
  for (int i = 0; i<map01obj.length; ++i)
  {
    if (map01obj[i].checkCollision(player.getPosX(), player.getPosY(), player.getDirection())) // проверка на колижн
    {
      isInConversation = true;//we are now talking to the target NPC
      
      
        if(i== 0)
      {
        destinationX = player.getPosX();  // перемещение персонажа
            destinationY = player.getPosY();
            isTransitioning = true;
            //player.healAllmonstr();
            println("healed.");
      }
    }
  }
}