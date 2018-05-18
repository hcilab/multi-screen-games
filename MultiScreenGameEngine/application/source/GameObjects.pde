 //=========================================================================================================
// Author: David Hanna
//
// An object which is an entity in the game world.
//=========================================================================================================

//---------------------------------------------------------------
// INTERFACE
//---------------------------------------------------------------

interface IGameObject
{
  // Must be called before going out of scope.
  public void destroy();
  
  // This should be called immediately after creating a Game Object to load its data from a GameObject XML file.
  public void fromXML(String fileName);
  
  // Convert to and construct from a JSON object. This includes all current object state to make networking possible.
  public int serialize(FlatBufferBuilder builder);
  public void deserialize(FlatGameObject flatGameObject);
  
  // Every instantiated Game Object has a unique ID.
  public int getUID();
  
  // Every GameObject has a back-reference to its manager.
  public IGameObjectManager getGameObjectManager();
  
  // A Game Object can have a tag which may be used for various purposes. e.g. if (getTag() == "player") { ... }
  public String getTag();
  public void setTag(String _tag);
  
  // Transform values.
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();

  public void translate(PVector vector);
  public void rotate(PVector vector);
  public void scale(PVector vector);
  
  public void setTranslation(PVector vector);
  public void setRotation(PVector vector);
  public void setScale(PVector vector);
  
  // Find a component attached to this GameObject. Returns null if not found.
  // Note: GameObjects are limited to having only one component of each type.
  public IComponent getComponent(ComponentType componentType);
  
  public boolean getSend();
  public void setSend(boolean _send);
  
  // Updates and renders the Game Object over the given time in milliseconds.
  public void update(int deltaTime);
  
  public String toString();
}

// This is basically a convenience container class for GameObjects that can load levels,
// provide convenience functions for loading new GameObjects and clearing a level, etc.
interface IGameObjectManager
{
  // Creates a level full of GameObjects based on a Level XML file.
  public void fromXML(String fileName);
  
  // Convert to and construct a whole level from a flat object. This includes all current objects' state to make networking possible.
  public int serialize(FlatBufferBuilder builder);
  public void deserialize(FlatGameWorld flatGameWorld);
  
  public void update(int deltaTime);
  
  public IGameObject            addGameObject(String fileName, PVector translation, PVector rotation, PVector scale);
  public IGameObject            getGameObject(int UID);
  public ArrayList<IGameObject> getGameObjectsByTag(String tag);
  public HashMap<Integer, IGameObject> getGameObjects();
  public void                   removeGameObject(int UID);
  public void                   clearGameObjects();
  
  public String toString();
}

//---------------------------------------------------------------
// IMPLEMENTATION
//---------------------------------------------------------------

// Increments such that every GameObject has a unique ID.
int gameObjectNextUID = 0;

public class GameObject implements IGameObject
{
  private int UID;
  private IGameObjectManager owner;
  private String tag;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  private ArrayList<IComponent> components;
  
  private boolean send;
  
  public GameObject(IGameObjectManager _owner, PVector _translation, PVector _rotation, PVector _scale)
  {
    UID = gameObjectNextUID;
    gameObjectNextUID++;
    owner = _owner;
    tag = "";
    
    translation = _translation;
    rotation = _rotation;
    scale = _scale;
    
    components = new ArrayList<IComponent>();
    
    send = false;
  }
  
  public GameObject(IGameObjectManager _owner, FlatGameObject flatGameObject)
  {
    owner = _owner;
    
    translation = new PVector();
    rotation = new PVector();
    scale = new PVector();
    
    components = new ArrayList<IComponent>();
    
    deserialize(flatGameObject);
  }
  
  @Override public void destroy()
  {
    for (IComponent component : components)
    {
      component.destroy();
    }
    components.clear();
  }
  
  @Override public void fromXML(String fileName)
  {
    XML xmlGameObject = loadXML(fileName);
    
    assert(xmlGameObject.getName().equals("GameObject"));
    
    for (XML xmlComponent : xmlGameObject.getChildren())
    {
      IComponent component = componentFactory(this, xmlComponent);
      if (component != null)
      {
        components.add(component);
      }
    }
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int tagOffset = builder.createString(tag);
    
    ArrayList<Integer> flatComponentsArrayList = new ArrayList<Integer>();
    
    for (int i = 0; i < components.size(); i++)
    {
      if (components.get(i) instanceof INetworkComponent)
      {
        flatComponentsArrayList.add(((INetworkComponent)components.get(i)).serialize(builder));
      }
    }
    
    int[] flatComponents = new int[flatComponentsArrayList.size()];
    for (int i = 0; i < flatComponentsArrayList.size(); i++)
    {
      flatComponents[i] = flatComponentsArrayList.get(i);
    }
    
    int flatComponentsVector = FlatGameObject.createComponentTablesVector(builder, flatComponents);
    
    FlatGameObject.startFlatGameObject(builder);
    FlatGameObject.addUid(builder, UID);
    FlatGameObject.addTag(builder, tagOffset);
    FlatGameObject.addTranslation(builder, FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z));
    FlatGameObject.addRotation(builder, FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z));
    FlatGameObject.addScale(builder, FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z));
    FlatGameObject.addComponentTables(builder, flatComponentsVector);
    
    return FlatGameObject.endFlatGameObject(builder);
  }
  
  @Override public void deserialize(FlatGameObject flatGameObject)
  {
    destroy();
    
    UID = flatGameObject.uid();
    tag = flatGameObject.tag();
    
    FlatVec3 flatTranslation = flatGameObject.translation();
    translation = new PVector(flatTranslation.x(), flatTranslation.y(), flatTranslation.z());
    
    FlatVec3 flatRotation = flatGameObject.rotation();
    rotation = new PVector(flatRotation.x(), flatRotation.y(), flatRotation.z());
    
    FlatVec3 flatScale = flatGameObject.scale();
    scale = new PVector(flatScale.x(), flatScale.y(), flatScale.z());
    
    for (int i = 0; i < flatGameObject.componentTablesLength(); ++i)
    {
      FlatComponentTable flatComponentTable = flatGameObject.componentTables(i);
      components.add(deserializeComponent(this, flatComponentTable));
    }
  }
  
  @Override public int getUID()
  {
    return UID;
  }
  
  @Override public IGameObjectManager getGameObjectManager()
  {
    return owner;
  }
  
  @Override public String getTag()
  {
    return tag;
  }
  
  @Override public void setTag(String _tag)
  {
    tag = _tag;
  }
  
  @Override public PVector getTranslation()
  {
    return translation;
  }
  
  @Override public PVector getRotation()
  {
    return rotation;
  }
  
  @Override public PVector getScale()
  {
    return scale;
  }
  
  @Override public void translate(PVector vector)
  {
    translation.add(vector);
  }
  
  @Override public void rotate(PVector vector)
  {
    rotation.add(vector);
  }
  
  @Override public void scale(PVector vector)
  {
    scale.add(vector);
  }
  
  @Override public void setTranslation(PVector vector)
  {
    translation = vector;
  }
  
  @Override public void setRotation(PVector vector)
  {
    rotation = vector;
  }
  
  @Override public void setScale(PVector vector)
  {
    scale = vector;
  }
  
  @Override public IComponent getComponent(ComponentType componentType)
  {
    for (IComponent component : components)
    {
      if (component.getComponentType() == componentType)
      {
        return component;
      }
    }
    
    return null;
  }
  
  @Override public boolean getSend()
  {
    return send;
  }
  
  @Override public void setSend(boolean _send)
  {
    send = _send;
  }
  
  @Override public void update(int deltaTime)
  {
    for (IComponent component : components)
    {
      component.update(deltaTime);
    }
  }
  
  @Override public String toString()
  {
    String stringGameObject = new String();
    
    stringGameObject += "========== GameObject ==========\n";
    stringGameObject += "UID: " + UID + "\t\t tag: " + tag + "\n";
    stringGameObject += "Translation: (" + translation.x + ", " + translation.y + ", " + translation.z + ")\n";
    stringGameObject += "Rotation: (" + rotation.x + ", " + rotation.y + ", " + rotation.z + ")\n";
    stringGameObject += "Scale: (" + scale.x + ", " + scale.y + ", " + scale.z + ")\n";
    stringGameObject += "Components: \n";
    
    for (IComponent component : components)
    {
      stringGameObject += component.toString();
    }
    
    return stringGameObject;
  }
}

public class GameObjectManager implements IGameObjectManager
{
  private HashMap<Integer, IGameObject> gameObjects;
  private ArrayList<IGameObject> addList;
  private ArrayList<Integer> removeList;
  
  public GameObjectManager()
  {
    gameObjects = new HashMap<Integer, IGameObject>();
    addList = new ArrayList<IGameObject>();
    removeList = new ArrayList<Integer>();
  }
  
  @Override public void fromXML(String fileName)
  {
    XML xmlLevel = loadXML(fileName);
    
    assert(xmlLevel.getName().equals("Level"));
    
    for (XML xmlGameObject : xmlLevel.getChildren("GameObject"))
    {
      PVector translation = new PVector(0.0f, 0.0f, 0.0f);
      PVector rotation = new PVector(0.0f, 0.0f, 0.0f);
      PVector scale = new PVector(1.0f, 1.0f, 1.0f);
      
      for (XML xmlTransform : xmlGameObject.getChildren("Transform"))
      {
        for (XML xmlTranslation : xmlTransform.getChildren("Translation"))
        {
          translation.x = xmlTranslation.getFloat("x");
          translation.y = xmlTranslation.getFloat("y");
          translation.z = xmlTranslation.getFloat("z");
        }
        
        for (XML xmlRotation : xmlTransform.getChildren("Rotation"))
        {
          rotation.x = xmlRotation.getFloat("x");
          rotation.y = xmlRotation.getFloat("y");
          rotation.z = xmlRotation.getFloat("z");
        }
        
        for (XML xmlScale : xmlTransform.getChildren("Scale"))
        {
          scale.x = xmlScale.getFloat("x");
          scale.y = xmlScale.getFloat("y");
          scale.z = xmlScale.getFloat("z");
        }
      }
      
      IGameObject gameObject = new GameObject(this, translation, rotation, scale);
      
      String tag = xmlGameObject.getString("tag");
      if (tag != null)
      {
        gameObject.setTag(tag);
      }
      
      String send = xmlGameObject.getString("send");
      if (send != null && send.equals("true"))
      {
        gameObject.setSend(true);
      }
      
      gameObject.fromXML(xmlGameObject.getString("file"));
      gameObjects.put(gameObject.getUID(), gameObject);
    }
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    ArrayList<Integer> flatGameObjectsList = new ArrayList<Integer>();
    
    for (Map.Entry entry : gameObjects.entrySet())
    {
      IGameObject gameObject = (IGameObject)entry.getValue();
      
      if (gameObject.getSend())
      {
        flatGameObjectsList.add(gameObject.serialize(builder));
      }
    }
    
    int[] flatGameObjects = new int[flatGameObjectsList.size()];
    for (int i = 0; i < flatGameObjectsList.size(); i++)
    {
      flatGameObjects[i] = flatGameObjectsList.get(i);
    }
    
    int flatGameObjectsVector = FlatGameWorld.createGameObjectsVector(builder, flatGameObjects);
    
    FlatGameWorld.startFlatGameWorld(builder);
    FlatGameWorld.addGameObjects(builder, flatGameObjectsVector);
    
    return FlatGameWorld.endFlatGameWorld(builder);
  }
  
  @Override public void deserialize(FlatGameWorld flatGameWorld)
  {
    clearGameObjects();
    
    for (int i = 0; i < flatGameWorld.gameObjectsLength(); i++)
    {
      FlatGameObject flatGameObject = flatGameWorld.gameObjects(i);
      IGameObject gameObject = new GameObject(this, flatGameObject);
      gameObjects.put(gameObject.getUID(), gameObject);
    }
  }
  
  @Override public void update(int deltaTime)
  {
    for (Map.Entry entry : gameObjects.entrySet())
    {
      IGameObject gameObject = (IGameObject)entry.getValue();
      gameObject.update(deltaTime);
    }
    
    for (IGameObject gameObject : addList)
    {
      gameObjects.put(gameObject.getUID(), gameObject);
    }
    for (Integer UID : removeList)
    {
      IGameObject gameObject = gameObjects.remove(UID);
      if (gameObject != null) 
      {
        gameObject.destroy();
      }
    }
    
    addList.clear();
    removeList.clear();
  }
  
  @Override public IGameObject addGameObject(String fileName, PVector translation, PVector rotation, PVector scale)
  {
    IGameObject gameObject = new GameObject(this, translation, rotation, scale);
    gameObject.fromXML(fileName);
    addList.add(gameObject);
    return gameObject;
  }
  
  @Override public IGameObject getGameObject(int UID)
  {
    if (gameObjects.containsKey(UID))
    {
      return gameObjects.get(UID);
    }
    return null;
  }
  
  @Override public ArrayList<IGameObject> getGameObjectsByTag(String tag)
  {
    ArrayList<IGameObject> gameObjectsByTag = new ArrayList<IGameObject>();
    
    for (Map.Entry entry : gameObjects.entrySet())
    {
      IGameObject gameObject = (IGameObject)entry.getValue();
      
      if (gameObject.getTag().equals(tag))
      {
        gameObjectsByTag.add(gameObject);
      }
    }
    
    return gameObjectsByTag;
  }
  
  @Override public HashMap<Integer, IGameObject> getGameObjects()
  {
    return gameObjects;
  }
  
  @Override public void removeGameObject(int UID)
  {
    removeList.add(UID);
  }
  
  @Override public void clearGameObjects()
  {
    for (Map.Entry entry : gameObjects.entrySet())
    {
      IGameObject gameObject = (IGameObject)entry.getValue();
      gameObject.destroy();
    }
    gameObjects.clear();
  }
  
  @Override public String toString()
  {
    String stringGameWorld = new String();
    
    stringGameWorld += "======== Game World =======\n";
    stringGameWorld += "GameObjects: \n";
    
    for (Map.Entry entry : gameObjects.entrySet())
    {
      IGameObject gameObject = (IGameObject)entry.getValue();
      stringGameWorld += gameObject.toString();
    }
    
    return stringGameWorld;
  }
}
