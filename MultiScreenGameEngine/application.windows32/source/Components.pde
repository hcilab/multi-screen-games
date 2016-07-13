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
  PERSPECTIVE_CAMERA,
  TRANSLATE_OVER_TIME,
  ROTATE_OVER_TIME,
  SCALE_OVER_TIME,
}

public interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public int             serialize(FlatBufferBuilder builder);
  public void            deserialize(com.google.flatbuffers.Table componentTable);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
  public String          toString();
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
      
    case PERSPECTIVE_CAMERA:
      return "perspectiveCamera";
      
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
      
    case "perspectiveCamera":
      return ComponentType.PERSPECTIVE_CAMERA;
      
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
  ArrayList<Integer> spriteHandles;
  ArrayList<Integer> modelHandles;
  
  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    spriteHandles = new ArrayList<Integer>();
    modelHandles = new ArrayList<Integer>();
  }
  
  @Override public void destroy()
  {
    for (Integer handle : spriteHandles)
    {
      scene.removeSpriteInstance(handle);
    }
    for (Integer handle : modelHandles)
    {
      scene.removeModelInstance(handle);
    }
    
    spriteHandles.clear();
    modelHandles.clear();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlSubComponent : xmlComponent.getChildren())
    {
      if (xmlSubComponent.getName().equals("Sprite"))
      {
        ISpriteInstance sprite = new SpriteInstance(xmlSubComponent.getString("name"));
        spriteHandles.add(scene.addSpriteInstance(sprite));
      }
      else if (xmlSubComponent.getName().equals("Model"))
      {
        IModelInstance modelInstance = new ModelInstance(xmlSubComponent.getString("name"));
        modelHandles.add(scene.addModelInstance(modelInstance));
      }
    }
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int[] flatSprites = new int[spriteHandles.size()];
    for (int i = 0; i < spriteHandles.size(); i++)
    {
      flatSprites[i] = scene.getSpriteInstance(spriteHandles.get(i)).serialize(builder);
    }
    int flatSpritesVector = FlatRenderComponent.createSpritesVector(builder, flatSprites);
    
    int[] flatModels = new int[modelHandles.size()];
    for (int i = 0; i < modelHandles.size(); i++)
    {
      flatModels[i] = scene.getModelInstance(modelHandles.get(i)).serialize(builder);
    }
    int flatModelsVector = FlatRenderComponent.createModelsVector(builder, flatModels);
    
    FlatRenderComponent.startFlatRenderComponent(builder);
    FlatRenderComponent.addSprites(builder, flatSpritesVector);
    FlatRenderComponent.addModels(builder, flatModelsVector);
    
    int flatRenderComponent = FlatRenderComponent.endFlatRenderComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatRenderComponent);
    FlatComponentTable.addComponent(builder, flatRenderComponent);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatRenderComponent flatRenderComponent = (FlatRenderComponent)componentTable;
    
    for (int i = 0; i < flatRenderComponent.spritesLength(); i++)
    {
      FlatSprite flatSprite = flatRenderComponent.sprites(i);
      ISpriteInstance spriteInstance = new SpriteInstance(flatSprite.spriteName());
      spriteInstance.deserialize(flatSprite);
      spriteHandles.add(scene.addSpriteInstance(spriteInstance));
    }
    
    for (int i = 0; i < flatRenderComponent.modelsLength(); i++)
    {
      FlatModel flatModel = flatRenderComponent.models(i);
      IModelInstance modelInstance = new ModelInstance(flatModel.modelName());
      modelInstance.deserialize(flatModel);
      modelHandles.add(scene.addModelInstance(modelInstance));
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (Integer spriteHandle : spriteHandles)
    {
      ISpriteInstance spriteInstance = scene.getSpriteInstance(spriteHandle);
      spriteInstance.setTranslation(gameObject.getTranslation());
      spriteInstance.setRotation(gameObject.getRotation());
      spriteInstance.setScale(gameObject.getScale());
    }
    
    for (Integer modelHandle : modelHandles)
    {
      IModelInstance modelInstance = scene.getModelInstance(modelHandle);
      modelInstance.setTranslation(gameObject.getTranslation());
      modelInstance.setRotation(gameObject.getRotation());
      modelInstance.setScale(gameObject.getScale());
    }
  }
  
  @Override public String toString()
  {
    String stringRenderComponent = "=========== RenderComponent ===========\n";
    
    for (Integer spriteHandle : spriteHandles)
    {
      ISpriteInstance spriteInstance = scene.getSpriteInstance(spriteHandle);
      stringRenderComponent += "\tSprite: " + spriteInstance.getSprite().getName() + "\n";
    }
    
    for (Integer modelHandle : modelHandles)
    {
      IModelInstance modelInstance = scene.getModelInstance(modelHandle);
      stringRenderComponent += "\tModel: " + modelInstance.getModel().getName() + "\n";
    }
    
    return stringRenderComponent;
  }
}


public class PerspectiveCameraComponent extends Component
{
  private IPerspectiveCamera camera;
  
  public PerspectiveCameraComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    camera = new PerspectiveCamera();
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlParameter : xmlComponent.getChildren())
    {
      if (xmlParameter.getName().equals("Position"))
      {
        PVector position = new PVector();
        position.x = xmlParameter.getFloat("x");
        position.y = xmlParameter.getFloat("y");
        position.z = xmlParameter.getFloat("z");
        camera.setPosition(position);
      }
      else if (xmlParameter.getName().equals("Target"))
      {
        PVector target = new PVector();
        target.x = xmlParameter.getFloat("x");
        target.y = xmlParameter.getFloat("y");
        target.z = xmlParameter.getFloat("z");
        camera.setTarget(target);
      }
      else if (xmlParameter.getName().equals("Up"))
      {
        PVector up = new PVector();
        up.x = xmlParameter.getFloat("x");
        up.y = xmlParameter.getFloat("y");
        up.z = xmlParameter.getFloat("z");
        camera.setUp(up);
      }
      else if (xmlParameter.getName().equals("FieldOfView"))
      {
        camera.setFieldOfView(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("AspectRatio"))
      {
        camera.setAspectRatio(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Near"))
      {
        camera.setNear(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Far"))
      {
        camera.setFar(xmlParameter.getFloat("value"));
      }
    }
    
    scene.setPerspectiveCamera(camera);
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    return 0;
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    //FlatPerspectiveCameraComponent flatPerspectiveCameraComponent = (FlatPerspectiveCameraComponent)componentTable;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PERSPECTIVE_CAMERA;
  }
  
  @Override public void update(int deltaTime)
  {
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
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    FlatTranslateOverTimeComponent.startFlatTranslateOverTimeComponent(builder);
    FlatTranslateOverTimeComponent.addMovingLeft(builder, movingLeft);
    FlatTranslateOverTimeComponent.addXUnitsPerMillisecond(builder, xUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addLeftLimit(builder, leftLimit);
    FlatTranslateOverTimeComponent.addRightLimit(builder, rightLimit);
    FlatTranslateOverTimeComponent.addMovingDown(builder, movingDown);
    FlatTranslateOverTimeComponent.addYUnitsPerMillisecond(builder, yUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addLowerLimit(builder, lowerLimit);
    FlatTranslateOverTimeComponent.addUpperLimit(builder, upperLimit);
    FlatTranslateOverTimeComponent.addMovingForward(builder, movingForward);
    FlatTranslateOverTimeComponent.addZUnitsPerMillisecond(builder, zUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addForwardLimit(builder, forwardLimit);
    FlatTranslateOverTimeComponent.addBackwardLimit(builder, backwardLimit);
    int flatTranslateOverTimeComponentOffset = FlatTranslateOverTimeComponent.endFlatTranslateOverTimeComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatTranslateOverTimeComponent);
    FlatComponentTable.addComponent(builder, flatTranslateOverTimeComponentOffset);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatTranslateOverTimeComponent flatTranslateOverTimeComponent = (FlatTranslateOverTimeComponent)componentTable;
    
    movingLeft = flatTranslateOverTimeComponent.movingLeft();
    xUnitsPerMillisecond = flatTranslateOverTimeComponent.xUnitsPerMillisecond();
    leftLimit = flatTranslateOverTimeComponent.leftLimit();
    rightLimit = flatTranslateOverTimeComponent.rightLimit();
    
    movingDown = flatTranslateOverTimeComponent.movingDown();
    yUnitsPerMillisecond = flatTranslateOverTimeComponent.yUnitsPerMillisecond();
    lowerLimit = flatTranslateOverTimeComponent.lowerLimit();
    upperLimit = flatTranslateOverTimeComponent.upperLimit();
    
    movingForward = flatTranslateOverTimeComponent.movingForward();
    zUnitsPerMillisecond = flatTranslateOverTimeComponent.zUnitsPerMillisecond();
    forwardLimit = flatTranslateOverTimeComponent.forwardLimit();
    backwardLimit = flatTranslateOverTimeComponent.backwardLimit();
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
    setMovingLeftAction.setTargetUID(gameObject.getUID());
    setMovingLeftAction.setMovingLeft(movingLeft);
    
    //actionBuffer.add(setMovingLeftAction);
  }
  
  private void addSetMovingDownAction()
  {
    SetMovingDownAction setMovingDownAction = new SetMovingDownAction();
    setMovingDownAction.setTargetUID(gameObject.getUID());
    setMovingDownAction.setMovingDown(movingDown);
    
    //actionBuffer.add(setMovingDownAction);
  }
  
  private void addSetMovingForwardAction()
  {
    SetMovingForwardAction setMovingForwardAction = new SetMovingForwardAction();
    setMovingForwardAction.setTargetUID(gameObject.getUID());
    setMovingForwardAction.setMovingForward(movingForward);
    
    //actionBuffer.add(setMovingForwardAction);
  }
  
  private void addTranslateAction(PVector translation)
  {
    TranslateAction translateAction = new TranslateAction();
    translateAction.setTargetUID(gameObject.getUID());
    translateAction.setTranslation(translation);
    
    //actionBuffer.add(translateAction);
  }
  
  @Override public String toString()
  {
    String stringTranslateOverTimeComponent = new String();
    stringTranslateOverTimeComponent += "=========== TranslateOverTimeComponent ===========\n";
    stringTranslateOverTimeComponent += "\tmovingLeft: " + movingLeft + "\n";
    stringTranslateOverTimeComponent += "\txUnitsPerMillisecond: " + xUnitsPerMillisecond + "\n";
    stringTranslateOverTimeComponent += "\tleftLimit: " + leftLimit + "\n";
    stringTranslateOverTimeComponent += "\trightLimit: " + rightLimit + "\n";
    stringTranslateOverTimeComponent += "\tmovingDown: " + movingDown + "\n";
    stringTranslateOverTimeComponent += "\tyUnitsPerMillisecond: " + yUnitsPerMillisecond + "\n";
    stringTranslateOverTimeComponent += "\tlowerLimit: " + lowerLimit + "\n";
    stringTranslateOverTimeComponent += "\tupperLimit: " + upperLimit + "\n";
    stringTranslateOverTimeComponent += "\tmovingForward: " + movingForward + "\n";
    stringTranslateOverTimeComponent += "\tzUnitsPerMillisecond: " + zUnitsPerMillisecond + "\n";
    stringTranslateOverTimeComponent += "\tforwardLimit: " + forwardLimit + "\n";
    stringTranslateOverTimeComponent += "\tbackwardLimit: " + backwardLimit + "\n";
    return stringTranslateOverTimeComponent;
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
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    FlatRotateOverTimeComponent.startFlatRotateOverTimeComponent(builder);
    FlatRotateOverTimeComponent.addXRadiansPerMillisecond(builder, xRadiansPerMillisecond);
    FlatRotateOverTimeComponent.addYRadiansPerMillisecond(builder, yRadiansPerMillisecond);
    FlatRotateOverTimeComponent.addZRadiansPerMillisecond(builder, zRadiansPerMillisecond);
    int flatRotateOverTimeComponentOffset = FlatRotateOverTimeComponent.endFlatRotateOverTimeComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatRotateOverTimeComponent);
    FlatComponentTable.addComponent(builder, flatRotateOverTimeComponentOffset);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatRotateOverTimeComponent flatRotateOverTimeComponent = (FlatRotateOverTimeComponent)componentTable;
    
    xRadiansPerMillisecond = flatRotateOverTimeComponent.xRadiansPerMillisecond();
    yRadiansPerMillisecond = flatRotateOverTimeComponent.yRadiansPerMillisecond();
    zRadiansPerMillisecond = flatRotateOverTimeComponent.zRadiansPerMillisecond();
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
    rotateAction.setTargetUID(gameObject.getUID());
    rotateAction.setRotation(rotation);
    
    //actionBuffer.add(rotateAction);
  }
  
  @Override public String toString()
  {
    String stringRotateOverTimeComponent = new String();
    stringRotateOverTimeComponent += "======= RotateOverTimeComponent =======\n";
    stringRotateOverTimeComponent += "\txRadiansPerMillisecond: " + xRadiansPerMillisecond + "\n";
    stringRotateOverTimeComponent += "\tyRadiansPerMillisecond: " + yRadiansPerMillisecond + "\n";
    stringRotateOverTimeComponent += "\tzRadiansPerMillisecond: " + zRadiansPerMillisecond + "\n";
    return stringRotateOverTimeComponent;
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
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    FlatScaleOverTimeComponent.startFlatScaleOverTimeComponent(builder);
    FlatScaleOverTimeComponent.addXScalingUp(builder, xScalingUp);
    FlatScaleOverTimeComponent.addXScalePerMillisecond(builder, xScalePerMillisecond);
    FlatScaleOverTimeComponent.addXLowerLimit(builder, xLowerLimit);
    FlatScaleOverTimeComponent.addXUpperLimit(builder, xUpperLimit);
    FlatScaleOverTimeComponent.addYScalingUp(builder, yScalingUp);
    FlatScaleOverTimeComponent.addYScalePerMillisecond(builder, yScalePerMillisecond);
    FlatScaleOverTimeComponent.addYLowerLimit(builder, yLowerLimit);
    FlatScaleOverTimeComponent.addYUpperLimit(builder, yUpperLimit);
    FlatScaleOverTimeComponent.addZScalingUp(builder, zScalingUp);
    FlatScaleOverTimeComponent.addZScalePerMillisecond(builder, zScalePerMillisecond);
    FlatScaleOverTimeComponent.addZLowerLimit(builder, zLowerLimit);
    FlatScaleOverTimeComponent.addZUpperLimit(builder, zUpperLimit);
    int flatScaleOverTimeComponentOffset = FlatScaleOverTimeComponent.endFlatScaleOverTimeComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatScaleOverTimeComponent);
    FlatComponentTable.addComponent(builder, flatScaleOverTimeComponentOffset);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatScaleOverTimeComponent flatScaleOverTimeComponent = (FlatScaleOverTimeComponent)componentTable;
    
    xScalingUp = flatScaleOverTimeComponent.xScalingUp();
    xScalePerMillisecond = flatScaleOverTimeComponent.xScalePerMillisecond();
    xLowerLimit = flatScaleOverTimeComponent.xLowerLimit();
    xUpperLimit = flatScaleOverTimeComponent.xUpperLimit();
    
    yScalingUp = flatScaleOverTimeComponent.yScalingUp();
    yScalePerMillisecond = flatScaleOverTimeComponent.yScalePerMillisecond();
    yLowerLimit = flatScaleOverTimeComponent.yLowerLimit();
    yUpperLimit = flatScaleOverTimeComponent.yUpperLimit();
    
    zScalingUp = flatScaleOverTimeComponent.zScalingUp();
    zScalePerMillisecond = flatScaleOverTimeComponent.zScalePerMillisecond();
    zLowerLimit = flatScaleOverTimeComponent.zLowerLimit();
    zUpperLimit = flatScaleOverTimeComponent.zUpperLimit();
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
    setXScalingUpAction.setTargetUID(gameObject.getUID());
    setXScalingUpAction.setXScalingUp(xScalingUp);
    
    //actionBuffer.add(setXScalingUpAction);
  }
  
  private void addSetYScalingUpAction()
  {
    SetYScalingUpAction setYScalingUpAction = new SetYScalingUpAction();
    setYScalingUpAction.setTargetUID(gameObject.getUID());
    setYScalingUpAction.setYScalingUp(yScalingUp);
    
    //actionBuffer.add(setYScalingUpAction);
  }
  
  private void addSetZScalingUpAction()
  {
    SetZScalingUpAction setZScalingUpAction = new SetZScalingUpAction();
    setZScalingUpAction.setTargetUID(gameObject.getUID());
    setZScalingUpAction.setZScalingUp(zScalingUp);
    
    //actionBuffer.add(setZScalingUpAction);
  }
  
  private void addScaleAction(PVector scale)
  {
    ScaleAction scaleAction = new ScaleAction();
    scaleAction.setTargetUID(gameObject.getUID());
    scaleAction.setScale(scale);
    
    //actionBuffer.add(scaleAction);
  }
  
  @Override public String toString()
  {
    String stringScaleOverTimeComponent = new String();
    stringScaleOverTimeComponent += "======= ScaleOverTimeComponent =======\n";
    stringScaleOverTimeComponent += "\txScalingUp: " + xScalingUp + "\n";
    stringScaleOverTimeComponent += "\txScalePerMillisecond: " + xScalePerMillisecond + "\n";
    stringScaleOverTimeComponent += "\txLowerLimit: " + xLowerLimit + "\n";
    stringScaleOverTimeComponent += "\txUpperLimit: " + xUpperLimit + "\n";
    stringScaleOverTimeComponent += "\tyScalingUp: " + yScalingUp + "\n";
    stringScaleOverTimeComponent += "\tyScalePerMillisecond: " + yScalePerMillisecond + "\n";
    stringScaleOverTimeComponent += "\tyLowerLimit: " + yLowerLimit + "\n";
    stringScaleOverTimeComponent += "\tyUpperLimit: " + yUpperLimit + "\n";
    stringScaleOverTimeComponent += "\tzScalingUp: " + zScalingUp + "\n";
    stringScaleOverTimeComponent += "\tzScalePerMillisecond: " + zScalePerMillisecond + "\n";
    stringScaleOverTimeComponent += "\tzLowerLimit: " + zLowerLimit + "\n";
    stringScaleOverTimeComponent += "\tzUpperLimit: " + zUpperLimit + "\n";
    return stringScaleOverTimeComponent;
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
      
    case "PerspectiveCamera":
      component = new PerspectiveCameraComponent(gameObject);
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

public IComponent deserializeComponent(GameObject gameObject, FlatComponentTable flatComponentTable)
{
  IComponent component = null;
  com.google.flatbuffers.Table componentTable = null;
  
  switch (flatComponentTable.componentType())
  {
    case FlatComponentUnion.FlatRenderComponent:
      component = new RenderComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatRenderComponent());
      break;
      
    case FlatComponentUnion.FlatTranslateOverTimeComponent:
      component = new TranslateOverTimeComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatTranslateOverTimeComponent());
      break;
      
    case FlatComponentUnion.FlatRotateOverTimeComponent:
      component = new RotateOverTimeComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatRotateOverTimeComponent());
      break;
      
    case FlatComponentUnion.FlatScaleOverTimeComponent:
      component = new ScaleOverTimeComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatScaleOverTimeComponent());
      break;
      
    default:
      assert(false);
  }
  
  if (component != null && componentTable != null)
  {
    component.deserialize(componentTable);
  }
  
  return component;
}