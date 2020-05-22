
class Move
{
  int m_damage, m_accuracy;
  String m_name, m_type;
  
  Move(int ID)
  {    
    //ID / Move name / move type / base damage / accuracy
    String[] loadFile = loadStrings("data/scripts/movesData.txt");
    String[] dissection = split(loadFile[ID], "/");
    m_name = dissection[1];
    m_type = dissection[2];
    m_damage = int(dissection[3]);
    m_accuracy = int(dissection[4]); 
  }
  
  String getMoveName()
  {
    return m_name;
  }
  
  int getMoveDmg()
  {
    return m_damage;
  }
  
  String getType()
  {
    return m_type;
  }
}