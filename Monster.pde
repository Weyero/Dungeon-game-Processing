class Monster
{
  //HP Iv = between 10 and 20 / other IVs betweem 3 and 10
  private int m_lvl,m_maxHP,m_att,m_def,m_spd,m_currentHP, m_exp, m_expMax;
  private int m_ID, m_HPIV, m_attIV, m_defIV, m_spdIV;
  private String m_name, m_type;
  private float m_posX, m_posY;//we will use positions to place our sprite on the battlefield
  private PImage m_sprite;
  Move[] m_moveset = new Move[0];
  
  
  Monster(int ID, int level, int HPIV, int attIV, int defIV, int spdIV, float posY, float posX)
  {
    m_lvl = level;
    //данные о монтсре)
    m_HPIV = HPIV;
    m_attIV = attIV;
    m_defIV = defIV;
    m_spdIV = spdIV;
    m_posX = posX;
    m_posY = posY;
    
    //вычиляем остальные характеристики
    m_maxHP = m_lvl*HPIV;
    m_att = m_lvl*attIV;
    m_def = m_lvl*defIV;
    m_spd = m_lvl*spdIV;
    m_currentHP = m_maxHP;//фулл хп
    
    m_name = monstList[ID];//название монстра берем из массива
    m_ID = ID;
  
    
   
  }
  
  void display()
  {
    fill(255);
    image(m_sprite, m_posX, m_posY);
  }

}
