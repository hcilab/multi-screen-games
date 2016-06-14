//======================================================================================================
// Author: David Hanna
//
// Components are attached to Game Objects to provide their data and behaviour.
//======================================================================================================

//-------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------

public enum ComponentType
{
  RENDER,
  TRANSLATE_OVER_TIME,
  ROTATE_OVER_TIME,
  SCALE_OVER_TIME,
}

public interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public JSONObject      serialize();
  public void            deserialize(JSONObject jsonComponent);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
}


//-----------------------------------------------------------------
// IMPLEMENTATION
//-----------------------------------------------------------------

public String componentTypeEnumToString(ComponentType componentType)
{
  switch(componentType)
  {
    case RENDER:
      return "render";
      
    case TRANSLATE_OVER_TIME:
      return "translateOverTime";
      
    case ROTATE_OVER_TIME:
      return "rotateOverTime";
      
    case SCALE_OVER_TIME:
      return "scaleOverTime";
      
    default:
      println("Assertion: ComponentType not added to EnumToString.");
      assert(false);
      return null;
  }
}

public ComponentType componentTypeStringToEnum(String componentType)
{
  switch(componentType)
  {
    case "render":
      return ComponentType.RENDER;
      
    case "translateOverTime":
      return ComponentType.TRANSLATE_OVER_TIME;
      
    case "rotateOverTime":
      return ComponentType.ROTATE_OVER_TIME;
      
    case "scaleOverTime":
      return ComponentType.SCALE_OVER_TIME;
      
    default:
      println("Assertion: String not mapped to a ComponentType.");
      assert(false);
      return null;
  }
}

public abstract class Component implements IComponent
{
  protected IGameObject gameObject;
  
  public Component(IGameObject _gameObject)
  {
    gameObject = _gameObject;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  // There is no need to change this in subclasses.
  @Override final public IGameObject getGameObject()
  {
    return gameObject;
  }
  
  @Override public void update(int deltaTime)
  {
  }
}


public class RenderComponent extends Component
{
  ArrayList<ISprite> sprites;
  ArrayList<IModel> models;
  
  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    sprites = new ArrayList<ISprite>();
    models = new ArrayList<IModel>();
  }
  
  @Override public void destroy()
  {
    for (ISprite sprite : sprites)
    {
      scene.removeSprite(sprite.getName());
    }
    for (IModel model : models)
    {
      scene.removeModel(model.getName());
    }
    
    sprites.clear();
    models.clear();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlSubComponent : xmlComponent.getChildren())
    {
      if (xmlSubComponent.getName().equals("Sprite"))
      {
        ISprite sprite = new Sprite(xmlSubComponent.getString("name"));
        scene.addSprite(sprite);
        sprites.add(sprite);
      }
      else if (xmlSubComponent.getName().equals("Model"))
      {
        IModel model = new Model(xmlSubComponent.getString("name"));
        model.fromOBJ(xmlSubComponent.getString("objFileName"));
        scene.addModel(model);
        models.add(model);
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONArray jsonSprites = new JSONArray();
    JSONArray jsonModels = new JSONArray();
    
    for (ISprite sprite : sprites)
    {
      jsonSprites.append(sprite.serialize());
    }
    
    for (IModel model : models)
    {
      jsonModels.append(model.serialize());
    }
    
    JSONObject jsonRenderComponent = new JSONObject();
    jsonRenderComponent.setJSONArray("sprites", jsonSprites);
    jsonRenderComponent.setJSONArray("models", jsonModels);
    
    return jsonRenderComponent;
  }
  
  @Override public void deserialize(JSONObject jsonRenderComponent)
  {
    sprites.clear();
    models.clear();
    
    JSONArray jsonSprites = jsonRenderComponent.getJSONArray("sprites");
    JSONArray jsonModels = jsonRenderComponent.getJSONArray("models");
    
    for (int i = 0; i < jsonSprites.size(); i++)
    {
      ISprite sprite = new Sprite(jsonSprites.getJSONObject(i));
      scene.addSprite(sprite);
      sprites.add(sprite);
    }
    
    for (int i = 0; i < jsonModels.size(); i++)
    {
      IModel model = new Model(jsonModels.getJSONObject(i));
      scene.addModel(model);
      models.add(model);
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (ISprite sprite : sprites)
    {
      sprite.setTranslation(gameObject.getTranslation());
      sprite.setRotation(gameObject.getRotation().z);
      sprite.setScale(gameObject.getScale());
    }
    
    for (IModel model : models)
    {
      model.setTranslation(gameObject.getTranslation());
      model.setRotation(gameObject.getRotation());
      model.setScale(gameObject.getScale());
    }
  }
}


public class TranslateOverTimeComponent extends Component
{
  private boolean movingLeft;
  private float xUnitsPerMillisecond;
  private float leftLimit;
  private float rightLimit;
  
  private boolean movingDown;
  private float yUnitsPerMillisecond;
  private float lowerLimit;
  private float upperLimit;
  
  private boolean movingForward;
  private float zUnitsPerMillisecond;
  private float forwardLimit;
  private float backwardLimit;
  
  public TranslateOverTimeComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  public void setMovingLeft(boolean _movingLeft)
  {
    movingLeft = _movingLeft;
  }
  
  public void setMovingDown(boolean _movingDown)
  {
    movingDown = _movingDown;
  }
  
  public void setMovingForward(boolean _movingForward)
  {
    movingForward = _movingForward;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    movingLeft = xmlComponent.getString("movingLeft").equals("true") ? true : false;
    xUnitsPerMillisecond = xmlComponent.getFloat("xUnitsPerSecond") / 1000.0f;
    leftLimit = xmlComponent.getFloat("leftLimit");
    rightLimit = xmlComponent.getFloat("rightLimit");
    
    movingDown = xmlComponent.getString("movingDown").equals("true") ? true : false;
    yUnitsPerMillisecond = xmlComponent.getFloat("yUnitsPerSecond") / 1000.0f;
    lowerLimit = xmlComponent.getFloat("lowerLimit");
    upperLimit = xmlComponent.getFloat("upperLimit");
    
    movingForward = xmlComponent.getString("movingForward").equals("true") ? true : false;
    zUnitsPerMillisecond = xmlComponent.getFloat("zUnitsPerSecond") / 1000.0f;
    forwardLimit = xmlComponent.getFloat("forwardLimit");
    backwardLimit = xmlComponent.getFloat("backwardLimit");
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonTranslateOverTime = new JSONObject();
    
    jsonTranslateOverTime.setBoolean("movingLeft", movingLeft);
    jsonTranslateOverTime.setFloat("xUnitsPerMillisecond", xUnitsPerMillisecond);
    jsonTranslateOverTime.setFloat("leftLimit", leftLimit);
    jsonTranslateOverTime.setFloat("rightLimit", rightLimit);
    
    jsonTranslateOverTime.setBoolean("movingDown", movingDown);
    jsonTranslateOverTime.setFloat("yUnitsPerMillisecond", yUnitsPerMillisecond);
    jsonTranslateOverTime.setFloat("lowerLimit", lowerLimit);
    jsonTranslateOverTime.setFloat("upperLimit", upperLimit);
    
    jsonTranslateOverTime.setBoolean("movingForward", movingForward);
    jsonTranslateOverTime.setFloat("zUnitsPerMillisecond", zUnitsPerMillisecond);
    jsonTranslateOverTime.setFloat("forwardLimit", forwardLimit);
    jsonTranslateOverTime.setFloat("backwardLimit", backwardLimit);
    
    return jsonTranslateOverTime;
  }
  
  @Override public void deserialize(JSONObject jsonTranslateOverTime)
  {
    movingLeft = jsonTranslateOverTime.getBoolean("movingLeft");
    xUnitsPerMillisecond = jsonTranslateOverTime.getFloat("xUnitsPerMillisecond");
    leftLimit = jsonTranslateOverTime.getFloat("leftLimit");
    rightLimit = jsonTranslateOverTime.getFloat("rightLimit");
    
    movingDown = jsonTranslateOverTime.getBoolean("movingDown");
    yUnitsPerMillisecond = jsonTranslateOverTime.getFloat("yUnitsPerMillisecond");
    lowerLimit = jsonTranslateOverTime.getFloat("lowerLimit");
    upperLimit = jsonTranslateOverTime.getFloat("upperLimit");
    
    movingForward = jsonTranslateOverTime.getBoolean("movingForward");
    zUnitsPerMillisecond = jsonTranslateOverTime.getFloat("zUnitsPerMillisecond");
    forwardLimit = jsonTranslateOverTime.getFloat("forwardLimit");
    backwardLimit = jsonTranslateOverTime.getFloat("backwardLimit");
  } 
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.TRANSLATE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector translation = new PVector();
    
    if (movingLeft)
    {
      translation.x = -xUnitsPerMillisecond;
      
      if (gameObject.getTranslation().x < leftLimit)
      {
        movingLeft = false;
        addSetMovingLeftAction();
      }
    }
    else
    {
      translation.x = xUnitsPerMillisecond;
      
      if (gameObject.getTranslation().x > rightLimit)
      {
        movingLeft = true;
        addSetMovingLeftAction();
      }
    }
    
    if (movingDown)
    {
      translation.y = -yUnitsPerMillisecond;
      
      if (gameObject.getTranslation().y < lowerLimit)
      {
        movingDown = false;
        addSetMovingDownAction();
      }
    }
    else
    {
      translation.y = yUnitsPerMillisecond;
      
      if (gameObject.getTranslation().y > upperLimit)
      {
        movingDown = true;
        addSetMovingDownAction();
      }
    }    
    
    if (movingForward)
    {
      translation.z = -zUnitsPerMillisecond;
      
      if (gameObject.getTranslation().z < forwardLimit)
      {
        movingForward = false;
        addSetMovingForwardAction();
      }
    }
    else
    {
      translation.z = zUnitsPerMillisecond;
      
      if (gameObject.getTranslation().z > backwardLimit)
      {
        movingForward = true;
        addSetMovingForwardAction();
      }
    }
    
    translation = translation.mult(deltaTime);
    gameObject.translate(translation);
    addTranslateAction(translation);
  }
  
  private void addSetMovingLeftAction()
  {
    SetMovingLeftAction setMovingLeftAction = new SetMovingLeftAction();
    setMovingLeftAction.setTarget(gameObject);
    setMovingLeftAction.setMovingLeft(movingLeft);
    
    actionBuffer.add(setMovingLeftAction);
  }
  
  private void addSetMovingDownAction()
  {
    SetMovingDownAction setMovingDownAction = new SetMovingDownAction();
    setMovingDownAction.setTarget(gameObject);
    setMovingDownAction.setMovingDown(movingDown);
    
    actionBuffer.add(setMovingDownAction);
  }
  
  private void addSetMovingForwardAction()
  {
    SetMovingForwardAction setMovingForwardAction = new SetMovingForwardAction();
    setMovingForwardAction.setTarget(gameObject);
    setMovingForwardAction.setMovingForward(movingForward);
    
    actionBuffer.add(setMovingForwardAction);
  }
  
  private void addTranslateAction(PVector translation)
  {
    TranslateAction translateAction = new TranslateAction();
    translateAction.setTarget(gameObject);
    translateAction.setTranslation(translation);
    
    actionBuffer.add(translateAction);
  }
}


public class RotateOverTimeComponent extends Component
{
  private float xRadiansPerMillisecond;
  private float yRadiansPerMillisecond;
  private float zRadiansPerMillisecond;
  
  public RotateOverTimeComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    xRadiansPerMillisecond = xmlComponent.getFloat("xRadiansPerSecond") / 1000.0f;
    yRadiansPerMillisecond = xmlComponent.getFloat("yRadiansPerSecond") / 1000.0f;
    zRadiansPerMillisecond = xmlComponent.getFloat("zRadiansPerSecond") / 1000.0f;
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonRotateOverTime = new JSONObject();
    
    jsonRotateOverTime.setFloat("xRadiansPerMillisecond", xRadiansPerMillisecond);
    jsonRotateOverTime.setFloat("yRadiansPerMillisecond", yRadiansPerMillisecond);
    jsonRotateOverTime.setFloat("zRadiansPerMillisecond", zRadiansPerMillisecond);
    
    return jsonRotateOverTime;
  }
  
  @Override public void deserialize(JSONObject jsonRotateOverTime)
  {
    xRadiansPerMillisecond = jsonRotateOverTime.getFloat("xRadiansPerMillisecond");
    yRadiansPerMillisecond = jsonRotateOverTime.getFloat("yRadiansPerMillisecond");
    zRadiansPerMillisecond = jsonRotateOverTime.getFloat("zRadiansPerMillisecond");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ROTATE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector rotation = new PVector(xRadiansPerMillisecond * deltaTime, yRadiansPerMillisecond * deltaTime, zRadiansPerMillisecond * deltaTime);
    gameObject.rotate(rotation);
    addRotateAction(rotation);
  }
  
  private void addRotateAction(PVector rotation)
  {
    RotateAction rotateAction = new RotateAction();
    rotateAction.setTarget(gameObject);
    rotateAction.setRotation(rotation);
    
    actionBuffer.add(rotateAction);
  }
}


public class ScaleOverTimeComponent extends Component
{
  private boolean xScalingUp;
  private float xScalePerMillisecond;
  private float xLowerLimit;
  private float xUpperLimit;
  
  private boolean yScalingUp;
  private float yScalePerMillisecond;
  private float yLowerLimit;
  private float yUpperLimit;
  
  private boolean zScalingUp;
  private float zScalePerMillisecond;
  private float zLowerLimit;
  private float zUpperLimit;
  
  public ScaleOverTimeComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  public void setXScalingUp(boolean _xScalingUp)
  {
    xScalingUp = _xScalingUp;
  }
  
  public void setYScalingUp(boolean _yScalingUp)
  {
    yScalingUp = _yScalingUp;
  }
  
  public void setZScalingUp(boolean _zScalingUp)
  {
    zScalingUp = _zScalingUp;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    xScalingUp = xmlComponent.getString("xScalingUp").equals("true") ? true : false;
    xScalePerMillisecond = xmlComponent.getFloat("xScalePerSecond") / 1000.0f;
    xLowerLimit = xmlComponent.getFloat("xLowerLimit");
    xUpperLimit = xmlComponent.getFloat("xUpperLimit");
    
    yScalingUp = xmlComponent.getString("yScalingUp").equals("true") ? true : false;
    yScalePerMillisecond = xmlComponent.getFloat("yScalePerSecond") / 1000.0f;
    yLowerLimit = xmlComponent.getFloat("yLowerLimit");
    yUpperLimit = xmlComponent.getFloat("yUpperLimit");
    
    zScalingUp = xmlComponent.getString("zScalingUp").equals("true") ? true : false;
    zScalePerMillisecond = xmlComponent.getFloat("zScalePerSecond") / 1000.0f;
    zLowerLimit = xmlComponent.getFloat("zLowerLimit");
    zUpperLimit = xmlComponent.getFloat("zUpperLimit");
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonScaleOverTime = new JSONObject();
    
    jsonScaleOverTime.setBoolean("xScalingUp", xScalingUp);
    jsonScaleOverTime.setFloat("xScalePerMillisecond", xScalePerMillisecond);
    jsonScaleOverTime.setFloat("xLowerLimit", xLowerLimit);
    jsonScaleOverTime.setFloat("xUpperLimit", xUpperLimit);
    
    jsonScaleOverTime.setBoolean("yScalingUp", yScalingUp);
    jsonScaleOverTime.setFloat("yScalePerMillisecond", yScalePerMillisecond);
    jsonScaleOverTime.setFloat("yLowerLimit", yLowerLimit);
    jsonScaleOverTime.setFloat("yUpperLimit", yUpperLimit);
    
    jsonScaleOverTime.setBoolean("zScalingUp", zScalingUp);
    jsonScaleOverTime.setFloat("zScalePerMillisecond", zScalePerMillisecond);
    jsonScaleOverTime.setFloat("zLowerLimit", zLowerLimit);
    jsonScaleOverTime.setFloat("zUpperLimit", zUpperLimit);
    
    return jsonScaleOverTime;
  }
  
  @Override public void deserialize(JSONObject jsonScaleOverTime)
  {
    xScalingUp = jsonScaleOverTime.getBoolean("xScalingUp");
    xScalePerMillisecond = jsonScaleOverTime.getFloat("xScalePerMillisecond");
    xLowerLimit = jsonScaleOverTime.getFloat("xLowerLimit");
    xUpperLimit = jsonScaleOverTime.getFloat("xUpperLimit");
    
    yScalingUp = jsonScaleOverTime.getBoolean("yScalingUp");
    yScalePerMillisecond = jsonScaleOverTime.getFloat("yScalePerMillisecond");
    yLowerLimit = jsonScaleOverTime.getFloat("yLowerLimit");
    yUpperLimit = jsonScaleOverTime.getFloat("yUpperLimit");
    
    zScalingUp = jsonScaleOverTime.getBoolean("zScalingUp");
    zScalePerMillisecond = jsonScaleOverTime.getFloat("zScalePerMillisecond");
    zLowerLimit = jsonScaleOverTime.getFloat("zLowerLimit");
    zUpperLimit = jsonScaleOverTime.getFloat("zUpperLimit");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.SCALE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector scale = new PVector();
    
    if (xScalingUp)
    {
      scale.x = xScalePerMillisecond;
      
      if (gameObject.getScale().x > xUpperLimit)
      {
        xScalingUp = false;
        addSetXScalingUpAction();
      }
    }
    else
    {
      scale.x = -xScalePerMillisecond;
      
      if (gameObject.getScale().x < xLowerLimit)
      {
        xScalingUp = true;
        addSetXScalingUpAction();
      }
    }
    
    if (yScalingUp)
    {
      scale.y = yScalePerMillisecond;
      
      if (gameObject.getScale().y > yUpperLimit)
      {
        yScalingUp = false;
        addSetYScalingUpAction();
      }
    }
    else
    {
      scale.y = -yScalePerMillisecond;
      
      if (gameObject.getScale().y < yLowerLimit)
      {
        yScalingUp = true;
        addSetYScalingUpAction();
      }
    }
    
    if (zScalingUp)
    {
      scale.z = zScalePerMillisecond;
      
      if (gameObject.getScale().z > zUpperLimit)
      {
        zScalingUp = false;
        addSetZScalingUpAction();
      }
    }
    else
    {
      scale.z = -zScalePerMillisecond;
      
      if (gameObject.getScale().z < zLowerLimit)
      {
        zScalingUp = true;
        addSetZScalingUpAction();
      }
    }
    
    scale = scale.mult(deltaTime);
    gameObject.scale(scale);
    addScaleAction(scale);
  }
  
  private void addSetXScalingUpAction()
  {
    SetXScalingUpAction setXScalingUpAction = new SetXScalingUpAction();
    setXScalingUpAction.setTarget(gameObject);
    setXScalingUpAction.setXScalingUp(xScalingUp);
    
    actionBuffer.add(setXScalingUpAction);
  }
  
  private void addSetYScalingUpAction()
  {
    SetYScalingUpAction setYScalingUpAction = new SetYScalingUpAction();
    setYScalingUpAction.setTarget(gameObject);
    setYScalingUpAction.setYScalingUp(yScalingUp);
    
    actionBuffer.add(setYScalingUpAction);
  }
  
  private void addSetZScalingUpAction()
  {
    SetZScalingUpAction setZScalingUpAction = new SetZScalingUpAction();
    setZScalingUpAction.setTarget(gameObject);
    setZScalingUpAction.setZScalingUp(zScalingUp);
    
    actionBuffer.add(setZScalingUpAction);
  }
  
  private void addScaleAction(PVector scale)
  {
    ScaleAction scaleAction = new ScaleAction();
    scaleAction.setTarget(gameObject);
    scaleAction.setScale(scale);
    
    actionBuffer.add(scaleAction);
  }
}


public IComponent componentFactory(GameObject gameObject, XML xmlComponent)
{
  IComponent component = null;
  String componentName = xmlComponent.getName();
  
  switch (componentName)
  {
    case "Render":
      component = new RenderComponent(gameObject);
      break;
      
    case "TranslateOverTime":
      component = new TranslateOverTimeComponent(gameObject);
      break;
      
    case "RotateOverTime":
      component = new RotateOverTimeComponent(gameObject);
      break;
      
    case "ScaleOverTime":
      component = new ScaleOverTimeComponent(gameObject);
      break;
  }
  
  if (component != null)
  {
    component.fromXML(xmlComponent);
  }
  
  return component;
}

public IComponent deserializeComponent(GameObject gameObject, JSONObject jsonComponent)
{
  IComponent component = null;
  
  ComponentType componentType = componentTypeStringToEnum(jsonComponent.getString("componentType"));
  
  switch (componentType)
  {
    case RENDER:
      component = new RenderComponent(gameObject);
      break;
      
    case TRANSLATE_OVER_TIME:
      component = new TranslateOverTimeComponent(gameObject);
      break;
      
    case ROTATE_OVER_TIME:
      component = new RotateOverTimeComponent(gameObject);
      break;
      
    case SCALE_OVER_TIME:
      component = new ScaleOverTimeComponent(gameObject);
      break;
      
    default:
      println("Assertion: ComponentType not added to deserializeComponent.");
      assert(false);
  }
  
  if (component != null)
  {
    component.deserialize(jsonComponent);
  }
  
  return component;
}