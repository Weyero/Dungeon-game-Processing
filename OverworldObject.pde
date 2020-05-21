class OverworldObject extends Collision
{
  
  PImage m_sprite,m_imgFrame;
  private int m_direction, m_spriteCount, m_npcType;
  
  OverworldObject(float posX, float posY, PImage sprite, int type)
  {
    super(posX,posY,tileSize);
    m_sprite = sprite;
    m_npcType = type;//0 = character, 1 = static sign (warp: 0 = warp to next index, 1 = warp to previous index)
    
    m_direction = 1;
    if(sprite != null) m_spriteCount = m_sprite.width/tileSize;//technical tiles do not need a sprite
  }
  
  void display()
  {
    //show the sprite and its direction
    if(m_npcType == 0)
    {
      if (m_direction == 1) m_imgFrame = m_sprite.get(0, 0, m_sprite.width/m_spriteCount, m_sprite.height);//idle DOWN 
      else if (m_direction == 0) m_imgFrame = m_sprite.get((m_sprite.width/m_spriteCount)*6, 0, m_sprite.width/m_spriteCount, m_sprite.height);//idle RIGHT
      else if (m_direction == 2) m_imgFrame = m_sprite.get((m_sprite.width/m_spriteCount)*9, 0, m_sprite.width/m_spriteCount, m_sprite.height);//idle LEFT
      else if (m_direction == 3) m_imgFrame = m_sprite.get((m_sprite.width/m_spriteCount)*3, 0, m_sprite.width/m_spriteCount, m_sprite.height);//idle UP  
    }
    else
    {
      m_imgFrame = m_sprite.get(0, 0, m_sprite.width/m_spriteCount, m_sprite.height);//idle DOWN 
    }
    image(m_imgFrame, m_posX+tileSize-m_imgFrame.width, m_posY+tileSize-m_imgFrame.height);
  }
  
  void changeDir(int direction)
  {
    m_direction = direction;
  }
  
  int getNPCType()
  {
    return m_npcType;
  }
  
  float getPosX()
  {
    return m_posX;
  }
  
  float getPosY()
  {
    return m_posY;
  }
  
  int getType()
  {
    return m_npcType;
  }
}