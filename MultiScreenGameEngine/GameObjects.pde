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
  public JSONObject serialize();
  public void deserialize(JSONObject jsonGameObject);
  
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
  
  // Updates and renders the Game Object over the given time in milliseconds.
  public void update(int deltaTime);
}

// This is basically a convenience container class for GameObjects that can load levels,
// provide convenience functions for loading new GameObjects and clearing a level, etc.
interface IGameObjectManager
{
  // Creates a level full of GameObjects based on a Level XML file.
  public void fromXML(String fileName);
  
  // Convert to and construct a whole level from a JSON object. This includes all current objects' state to make networking possible.
  public JSONArray serialize();
  public void deserialize(JSONArray jsonGameWorld);
  
  public void update(int deltaTime);
  
  public IGameObject            addGameObject(String fileName, PVector translation, PVector rotation, PVector scale);
  public IGameObject            getGameObject(int UID);
  public ArrayList<IGameObject> getGameObjectsByTag(String tag);
  public void                   removeGameObject(int UID);
  public void                   clearGameObjects();
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
  }
  
  public GameObject(IGameObjectManager _owner, JSONObject jsonGameObject)
  {
    owner = _owner;
    
    translation = new PVector();
    rotation = new PVector();
    scale = new PVector();
    
    components = new ArrayList<IComponent>();
    
    deserialize(jsonGameObject);
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
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonGameObject = new JSONObject();
    
    jsonGameObject.setInt("UID", UID);
    jsonGameObject.setString("tag", tag);
    
    JSONObject jsonTranslation = new JSONObject();
    jsonTranslation.setFloat("x", translation.x);
    jsonTranslation.setFloat("y", translation.y);
    jsonTranslation.setFloat("z", translation.z);
    jsonGameObject.setJSONObject("translation", jsonTranslation);
    
    JSONObject jsonRotation = new JSONObject();
    jsonRotation.setFloat("x", rotation.x);
    jsonRotation.setFloat("y", rotation.y);
    jsonRotation.setFloat("z", rotation.z);
    jsonGameObject.setJSONObject("rotation", jsonRotation);
    
    JSONObject jsonScale = new JSONObject();
    jsonScale.setFloat("x", scale.x);
    jsonScale.setFloat("y", scale.y);
    jsonScale.setFloat("z", scale.z);
    jsonGameObject.setJSONObject("scale", jsonScale);
    
    JSONArray jsonComponents = new JSONArray();
    for (IComponent component : components)
    {
      JSONObject jsonComponent = component.serialize();
      jsonComponent.setString("componentType", componentTypeEnumToString(component.getComponentType()));
      jsonComponents.append(jsonComponent);
    }
    jsonGameObject.setJSONArray("components", jsonComponents);
    
    return jsonGameObject;
  }
  
  @Override public void deserialize(JSONObject jsonGameObject)
  {
    destroy();
    
    UID = jsonGameObject.getInt("UID");
    tag = jsonGameObject.getString("tag");
    
    JSONObject jsonTranslation = jsonGameObject.getJSONObject("translation");
    translation.x = jsonTranslation.getFloat("x");
    translation.y = jsonTranslation.getFloat("y");
    translation.z = jsonTranslation.getFloat("z");
    
    JSONObject jsonRotation = jsonGameObject.getJSONObject("rotation");
    rotation.x = jsonRotation.getFloat("x");
    rotation.y = jsonRotation.getFloat("y");
    rotation.z = jsonRotation.getFloat("z");
    
    JSONObject jsonScale = jsonGameObject.getJSONObject("scale");
    scale.x = jsonScale.getFloat("x");
    scale.y = jsonScale.getFloat("y");
    scale.z = jsonScale.getFloat("z");
    
    JSONArray jsonComponents = jsonGameObject.getJSONArray("components");
    for (int i = 0; i < jsonComponents.size(); i++)
    {
      components.add(deserializeComponent(this, jsonComponents.getJSONObject(i)));
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
  
  @Override public void update(int deltaTime)
  {
    for (IComponent component : components)
    {
      component.update(deltaTime);
    }
    
    //println("Translation: (" + translation.x + ", " + translation.y + ", " + translation.z + ")");
    //println("Rotation: (" + rotation.x + ", " + rotation.y + ", " + rotation.z + ")");
    //println("Scale: (" + scale.x + ", " + scale.y + ", " + scale.z + ")");
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
      gameObject.fromXML(xmlGameObject.getString("file"));
      gameObjects.put(gameObject.getUID(), gameObject);
    }
  }
  
  @Override public JSONArray serialize()
  {
    JSONArray jsonGameWorld = new JSONArray();
    
    for (Map.Entry entry : gameObjects.entrySet())
    {
      IGameObject gameObject = (IGameObject)entry.getValue();
      
      jsonGameWorld.append(gameObject.serialize());
    }
    
    return jsonGameWorld;
  }
  
  @Override public void deserialize(JSONArray jsonGameWorld)
  {
    clearGameObjects();
    
    for (int i = 0; i < jsonGameWorld.size(); i++)
    {
      IGameObject gameObject = new GameObject(this, jsonGameWorld.getJSONObject(i));
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
}