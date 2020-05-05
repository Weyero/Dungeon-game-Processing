import processing.sound.*;
Player player;

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


//здесь будут перменные для монстров
String[] monstList = {"PLAYER", "CHARMANDER", "SQUIRTLE", "PIDGEY", "RATTATA", "PIKACHU", "VULPIX"};//для потом массив с монстрами

void setup()
{

  size(1000,700);
  frameRate(120);
  noSmooth();//пиксельное
  overworldmapImg = loadImage("data/sprites/map.png");
  tileset01 = loadImage("sprites/spr_tileset01.png");//тайлсет

  font = createFont("data/pkmnrs.ttf", 14);
  textFont(font);
    
  //для перса
  pSprite = loadImage("sprites/spr_player01.png");
  Monster[] testPlayerTeam = new Monster[1];
  int playerStarterMonster = int(monstList[0]);//это для боевки потом
  testPlayerTeam[0] = new Monster(playerStarterMonster, 5, int(random(10,20)), int(random(3,10)), int(random(3,10)), int(random(3,10)), 0, 0); //тест для боевки
  player = new Player(tileSize*5,tileSize*7, pSprite, testPlayerTeam);
 
}

void draw()
  {
    pushMatrix();
    translate(width/2,height/2);//центр экрана
    scale(owScaler);//зум
    translate(player.getPosX()*-1-(tileSize/2),player.getPosY()*-1-(tileSize/2));//для того чтоб камера на центре была
    drawOverworldmap(); 
    
    //тайлы
    noFill();
    for(int i = 0; i<columns; ++i)
    {   
      for(int j = 0; j<rows; ++j)
      {
        rect(i*tileSize,j*tileSize,tileSize,tileSize);
      }
    }
   
    player.display();//приросовка игрока
  
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
