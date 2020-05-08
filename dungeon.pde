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

//player variables
float pPosX,pPosY;
boolean pLeft, pRight, pDown, pUp;
PImage pSprite;

PImage overworldmapImg,tileset01;//карта
PFont font;
//NPC
  npcSprite01 = loadImage("data/sprites/spr_npc01.png");
  npcSprite02 = loadImage("data/sprites/spr_npc02.png");
  npcSprite03 = loadImage("data/sprites/spr_npc03.png");

//здесь будут перменные для монстров
String[] monstList = {"PLAYER", "CHARMANDER", "SQUIRTLE", "PIDGEY", "RATTATA", "PIKACHU", "VULPIX"}; 
// todo: добавить пикчи
// todo: добавить названия монстров

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
  String[] loadFile = loadStrings("data/scripts/map01collision.txt");//load our textfile from the map editor program
  String[] dissection = new String[0];//take the loaded file and for each index, we split it up and correctly use that data in the code below
  
  for(int i = 0; i<loadFile.length; ++i)
  {
    dissection = split(loadFile[i], ",");//split each line of the saved file
    //only append collision if the line starts with a "0" (using "1" for comments)
    if(int(dissection[0]) == 0) blokje = (Collision[]) append(blokje, new Collision(float(dissection[1])*tileSize,float(dissection[2])*tileSize,tileSize));//create collision with the given data from the saveFile
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
   
    player.display();	// проросовка игрока
  
    popMatrix();
  
    fill(0);
    textSize(24);
    textAlign(LEFT);
    textLeading(30);

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
}

void keyPressed()
{
      if(keyCode == LEFT) pLeft = true;
      if(keyCode == RIGHT) pRight = true;
      if(keyCode == UP) pUp = true;
      if(keyCode == DOWN) pDown = true;
   
  }
  void checkCollision(int direction)
{
  boolean playerCollision = false;
  //collision with walls
  for (int i = 0; i<blokje.length; ++i)
  {
    if (blokje[i].checkCollision(player.getPosX(), player.getPosY(), direction))//check if the player was about to move into an obstacle (collision)
    {
      playerCollision = true;
    }
  }  
  //collision with objects
  for (int i = 0; i<map01obj.length; ++i)
  {
    if (map01obj[i].checkCollision(player.getPosX(), player.getPosY(), direction))//check if the player was about to move into an obstacle (collision)
    {
      playerCollision = true;//there was a collision
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

