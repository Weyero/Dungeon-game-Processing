class Collision
{
  float m_posX,m_posY,m_size;
  
  Collision(float posX, float posY, float size)
  {
    m_posX = posX;
    m_posY = posY;
    m_size = size;
  }
  
  boolean checkCollision(float checkX, float checkY, int direction)
  {
    //if we are trying to go up (direction == 3) and the Ypos of the player == bottom line of the collision block, then we have a collision and return true
    //do this for the other directions
    if(direction == 3 && checkY == m_posY+m_size && checkX == m_posX || direction == 1 && checkY+m_size == m_posY && checkX == m_posX || direction == 2 && checkX == m_posX+m_size  && checkY == m_posY || direction == 0 && checkX+m_size == m_posX && checkY == m_posY)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
}