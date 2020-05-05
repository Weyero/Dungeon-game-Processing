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

    //рисуем спрайт героя
    m_imgFrame = m_sprite.get(m_frameNumber,0,m_sprite.width/m_spriteCount, m_sprite.height);
    image(m_imgFrame, m_posX+tileSize-m_imgFrame.width, m_posY+tileSize-m_imgFrame.height);
  }
}
