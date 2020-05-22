class Player
{
  private float m_posX, m_posY, m_speed, m_distanceTravelled;
  private boolean m_isMoving, m_isRunning, m_checkTile;
  private int m_direction, m_spriteFrame, m_spriteCount;
  private PImage m_sprite, m_imgFrame;
  Monster[] m_monsterTeam;
  private int[] m_itemList = new int[4];//макс. количество вещей в рюкзаке
  Player(float posX, float posY, PImage sprite, Monster[] monsterTeam)
  {
    m_posX = posX;
    m_posY = posY;
    m_sprite = sprite;
    m_spriteCount = m_sprite.width/tileSize;

    m_isMoving = false;
    m_isRunning = false;
    m_distanceTravelled = 0;
    m_speed = 0.5;
    m_direction = 0;
    
    m_monsterTeam = monsterTeam;
	m_itemList[0] = 5;
    m_itemList[1] = 5;
  }

  void display()
  {
    m_checkTile = false;
    fill(255, 255, 255, 100);//white
    if (m_isRunning == false) m_speed = 0.5;

    //если мы не дошли до след тайла, то анимация продолжается пока не достигнем тайл
    if (m_isMoving == true && m_distanceTravelled < tileSize)
    {
      if (m_direction == 0) m_posX += m_speed;
      if (m_direction == 1) m_posY += m_speed;
      if (m_direction == 2) m_posX -= m_speed;
      if (m_direction == 3) m_posY -= m_speed;
      m_distanceTravelled += m_speed;
      m_checkTile = false;
    }

    //если мы достигли тайл, он оставнавливается
    if (m_distanceTravelled >= tileSize)
    {
      m_isMoving = false;//no longer moving
      m_isRunning = false;
      m_checkTile = true;

      float forceBack = m_distanceTravelled-tileSize;//насколько мы перешагнули тайл
      if (m_direction == 0) m_posX -= forceBack;
      if (m_direction == 1) m_posY -= forceBack;
      if (m_direction == 2) m_posX += forceBack;
      if (m_direction == 3) m_posY += forceBack;
      m_posX = round(m_posX); 
      m_posY = round(m_posY);

      m_distanceTravelled = 0;

      //для правильной анимации
      if (m_spriteFrame == 0)
      {
        m_spriteFrame = 1;
      }
      else
      {
        m_spriteFrame = 0;
      }
    }
    //меняем спрайты
    handleSprite();
  }

void move(int direction)
  {  
    m_direction = direction;
    m_isMoving = true;//мы передвигаемся
  }
  
  boolean getIsMoving()
  {
    return m_isMoving;
  }

  float getPosX()
  {
    return m_posX;
  }

  float getPosY()
  {
    return m_posY;
  }
  
  int getDirection()
  {
    return m_direction;
  }
  
  boolean getCheckTile()
  {
    return m_checkTile;
  }
  
   int getItemCount(int index)
  {
    return m_itemList[index];
  }
  
  void setItemCount(int index, int amount)
  {
    m_itemList[index] = amount;
  }
 
  void setMoveState(boolean state)
  {
    m_isMoving = state;
  }
  void setPosition(float x, float y)
  {
    m_posX = x;
    m_posY = y;
  }
  
  void setDirection(int direction)
  {
    m_direction = direction;
  }
 //Monster
    Monster getPlayerMonster(int index)
  {
    return m_monsterTeam[index];
  }
  
  Monster[] getPlayerTeam()
  {
    return m_monsterTeam;
  }
  
  void setPlayerTeam(Monster[] importData)//
  {
    m_monsterTeam = new Monster[0];
    m_monsterTeam = importData;
  }
  
   void reduceMonsterHP(int amount)
  {
    m_monsterTeam[0].reduceHP(amount);
    m_monsterTeam[1].reduceHP(amount);
    m_monsterTeam[2].reduceHP(amount);
  }
   void healAllmonstr()
  {
      m_monsterTeam[0].setHP(m_monsterTeam[0].getMonsterMaxHP());
    
  }
  
  
  
  void handleSprite()
  {
    //m_sprite.width/spriteCount ширина каждоого спрайта
//если дистанция пройденная героем меньше половины максимального шага, показыаем спрайт где он стоит
//если дистанция пройденная героем больше половины максимального шага, показыаем спрайт где он идет   
    int m_frameNumber = 0;
    //спрайты для ходьбы
    if (m_distanceTravelled < tileSize/2)
    {
      if(m_isRunning == false)
      {
        if (m_direction == 1) m_frameNumber = 0;
        else if (m_direction == 0) m_frameNumber = (m_sprite.width/m_spriteCount)*6;
        else if (m_direction == 2) m_frameNumber = (m_sprite.width/m_spriteCount)*9;
        else if (m_direction == 3) m_frameNumber = (m_sprite.width/m_spriteCount)*3;
      }
     
    }
    //running sprites
    if (m_distanceTravelled >= tileSize/2)
    {
      if (m_spriteFrame == 0 && m_isMoving == true)
      {
        if (m_direction == 1) m_frameNumber = (m_sprite.width/m_spriteCount)*1;
        else if (m_direction == 0) m_frameNumber = (m_sprite.width/m_spriteCount)*7;
        else if (m_direction == 2) m_frameNumber = (m_sprite.width/m_spriteCount)*10;
        else if (m_direction == 3) m_frameNumber = (m_sprite.width/m_spriteCount)*4;
      } 
     
      else if (m_spriteFrame == 1 && m_isMoving == true)
      {
        if (m_direction == 1) m_frameNumber = (m_sprite.width/m_spriteCount)*2;
        else if (m_direction == 0) m_frameNumber = (m_sprite.width/m_spriteCount)*8;
        else if (m_direction == 2) m_frameNumber = (m_sprite.width/m_spriteCount)*11;
        else if (m_direction == 3) m_frameNumber = (m_sprite.width/m_spriteCount)*5;
      }
     
    }

    //рисуем спрайт героя
    m_imgFrame = m_sprite.get(m_frameNumber,0,m_sprite.width/m_spriteCount, m_sprite.height);
    image(m_imgFrame, m_posX+tileSize-m_imgFrame.width, m_posY+tileSize-m_imgFrame.height);
  }
}
