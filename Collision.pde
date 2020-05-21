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
<<<<<<< HEAD
    //if we are trying to go up (direction == 3) and the Ypos of the player == bottom line of the collision block, then we have a collision and return true
    //do this for the other directions
=======
    //если мы пытаемся идти вверх (direction == 3) и координата Ypos игрока == нижней границы стены , то тогда у нас столкновение и мы возвращаем true
    //ну и также для других направлении
>>>>>>> ec4e71444fbae36237db9c5141ee199db58c13be
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