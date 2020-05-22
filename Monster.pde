class Monster
{
  //HP Iv = между 10 и 20 / остальное между 3 и 10
  private int m_lvl,m_maxHP,m_att,m_def,m_spd,m_currentHP, m_exp, m_expMax;
  private int m_ID, m_HPIV, m_attIV, m_defIV, m_spdIV;
  private String m_name, m_type;
  private float m_posX, m_posY;//координаты спрайта вовремя боя
  private PImage m_sprite;
  
  
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
  
     
    //загружаем данные о монстрах
    String[] loadFile = loadStrings("data/scripts/monsterData.txt");
    String[] dissection = split(loadFile[ID], "/");
    m_type = dissection[1];
    
    //даем монстрам атаки
    for(int i = 2; i<dissection.length; ++i)
    {
      m_moveset = (Move[]) append(m_moveset, new Move(int(dissection[i])));
    }
   
  }
  
  void display()
  {
    fill(255);
    image(m_sprite, m_posX, m_posY);
  }
void raiseLevel()
  {
    m_lvl++;
    m_maxHP = m_lvl*m_HPIV;
    m_att = m_lvl*m_attIV;
    m_def = m_lvl*m_defIV;
    m_spd = m_lvl*m_spdIV;  
  }
  
  void raiseExp(int amount)
  {
    m_expMax = (m_lvl+1)*125;//необходимый опыт для повышения уровня (next level * 100(ex. at level5, level 6 необходимо 750 exp)
    m_exp += amount;
    
    if(m_exp >= m_expMax)//если мы повысили уровень
    {
      raiseLevel();//повышаем уровень и пересчитываем наши данные
      m_exp -= m_expMax;//если мы получаем больше чем лимит для след уровня, то остальное сохраняем чтоб добавить для след уровня
    }
  }
  
  int getMonsterHP()
  {
    return m_currentHP;
  }
  
  int getMonsterMaxHP()
  {
    return m_maxHP;
  }
  
  String getMonsterName()
  {
    return m_name;
  }
  
  int getMonsterID()
  {
    return m_ID;
  }
  
  String getType()
  {
    return m_type;
  }
  
  int getMonsterSpeed()
  {
    return m_spd;
  }
  
  int getMonsterAtt()//используется для расчета урона
  {
    return m_att;
  }
  
  int getMonsterDef()
  {
    return m_def;
  }
  
  int getMonsterLvl()//используется для рассчета получаемого опыта (больше опыта, если у монстра был выше уровень)
  {
    return m_lvl;
  }
  
  int getMonsterEXP()
  {
    return m_exp;
  }
  
  int getMonsterMaxEXP()
  {
    return m_expMax;
  }
  
  void reduceHP(int amount)
  {
    m_currentHP -= amount;
  }
  
  void setHP(int amount)
  {
    m_currentHP = amount;
  }
  
  void setPosition(float x, float y)
  {
    m_posX = x;
    m_posY = y;
  }
  
  void setSprite(PImage sprite)
  {
    m_sprite = sprite;
  }
  
  //moveset data
  int getMonsterMoveDamage(int index)
  {
    return m_moveset[index].getMoveDmg();
  }
  
  String getMonsterMoveName(int index)
  {
    if(index < m_moveset.length)
    {
      return m_moveset[index].getMoveName();  
    }
    else
    {
      return "-----";
    }
  }
  
  int getMonsterMovesAmount()
  {
    return m_moveset.length;
  }
  
  String getMonsterMoveType(int index)
  {
    return m_moveset[index].getType();
  }
  
  String getmonstrData()//для сохранения данных  о герое
  {
    String fullData = "-100"+"/"+str(m_ID)+"/"+ str(m_lvl)+"/"+ str(m_currentHP)+"/"+ str(m_HPIV)+"/"+ str(m_attIV)+"/"+ str(m_defIV)+"/"+ str(m_spdIV);
    return fullData;
  }
}
