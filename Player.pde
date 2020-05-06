class Player
{
  private float m_posX, m_posY, m_speed, m_distanceTravelled;
  private boolean m_isMoving, m_isRunning, m_checkTile;
  private int m_direction, m_spriteFrame, m_spriteCount;
  private PImage m_sprite, m_imgFrame;
  Monster[] m_monsterTeam;

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
  }

  void display()
  {
    m_checkTile = false;
    fill(255, 255, 255, 100);//white

    m_speed = 0.5;

    //  Если двигается, но дистанция < размера тайла
    if (m_isMoving == true && m_distanceTravelled < tileSize)
    {
      if (m_direction == 0) m_posX += m_speed;
      if (m_direction == 1) m_posY += m_speed;
      if (m_direction == 2) m_posX -= m_speed;
      if (m_direction == 3) m_posY -= m_speed;
      m_distanceTravelled += m_speed;
      m_checkTile = false;
    }

    // Если персонаж достиг следующего тайла, остановить
    if (m_distanceTravelled >= tileSize)
    {
      m_isMoving = false;   // Больше не двигается
      m_isRunning = false;
      m_checkTile = true;
      //println("step"); // test

      m_distanceTravelled = 0;

      // Смена спрайта для правой и левой ноги
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


  // Movements:

  void move(int direction)
  {  
    m_direction = direction;
    m_isMoving = true;//we are now moving
  }
  
  boolean getIsMoving()
  {
    return m_isMoving;
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
 
  
  void handleSprite()
  {
    //m_sprite.width/spriteCount это ширина каждого сроайта  
    int m_frameNumber = 0;

    // Смена спрайтов:
    if (m_distanceTravelled < tileSize/2)
    {
      if(m_isRunning == false)//if the character is not running, show walking sprites
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
