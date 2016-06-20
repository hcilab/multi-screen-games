import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.ArrayList; 
import java.util.LinkedList; 
import java.util.Map; 
import java.awt.Robot; 
import java.awt.AWTException; 
import java.awt.MouseInfo; 
import processing.net.Client; 
import processing.net.Server; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MultiScreenGameEngine extends PApplet {

//======================================================================================================
// Author: David Hanna
//
// A Game Engine that provides the utility to enable multiple screens of gameplay and interaction.
//======================================================================================================










MultiScreenGameEngine mainObject;
IEventManager eventManager;
ArrayList<IAction> actionBuffer;
ITextureManager textureManager;
IMaterialLibManager materialLibManager;
IScene scene;
IGameStateController gameStateController;

int lastFrameTime;

public void setup()
{
  
  surface.setResizable(true);
  
  mainObject = this;
  eventManager = new EventManager();
  actionBuffer = new ArrayList<IAction>();
  textureManager = new TextureManager();
  materialLibManager = new MaterialLibManager(); 
  scene = new Scene();
  gameStateController = new GameStateController();
  gameStateController.pushState(new GameState_ChooseClientServerState());
  
  lastFrameTime = millis();
}

public void draw()
{
  background(80);
  
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  //if (deltaTime > 100)
  //{
  //  deltaTime = 32;
  //}
  println(deltaTime);
  
  //println(((com.jogamp.newt.opengl.GLWindow)surface.getNative()).getLocationOnScreen(null));
  //if (robot != null)
  //{
  //  if (focused)
  //  {
  //    if (cursorVisible)
  //    {
  //      noCursor();
  //      cursorVisible = false;
  //    }
  //    robot.mouseMove(0, 0);
  //  }
  //  else
  //  {
  //    if (!cursorVisible)
  //    {
  //      cursor(ARROW);
  //      cursorVisible = true;
  //    }
  //  }
  //}
  //println(MouseInfo.getPointerInfo().getLocation());
  
  gameStateController.update(deltaTime);
  eventManager.update();
}

public void exit()
{
  while (gameStateController.getCurrentState() != null)
  {
    gameStateController.popState();
  }
  super.exit();
}
//======================================================================================================
// Author: David Hanna
//
// Actions are serializeable captures of changes to the game state and the time that change takes place.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public enum ActionType
{
  // TranslateOverTimeComponent
  TRANSLATE,
  SET_MOVING_LEFT,
  SET_MOVING_DOWN,
  SET_MOVING_FORWARD,
  
  // RotateOverTimeComponent
  ROTATE,
  
  // ScaleOverTimeComponent
  SCALE,
  SET_X_SCALING_UP,
  SET_Y_SCALING_UP,
  SET_Z_SCALING_UP,
}

public interface IAction
{
  public int getTimeStamp();
  public ActionType getActionType();
  
  public void apply();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonAction);
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public String actionTypeEnumToString(ActionType actionType)
{
  switch(actionType)
  {
    case TRANSLATE:
      return "translate";
      
    case SET_MOVING_LEFT:
      return "setMovingLeft";
      
    case SET_MOVING_DOWN:
      return "setMovingDown";
      
    case SET_MOVING_FORWARD:
      return "setMovingForward";
      
    case ROTATE:
      return "rotate";
      
    case SCALE:
      return "scale";
      
    case SET_X_SCALING_UP:
      return "setXScalingUp";
      
    case SET_Y_SCALING_UP:
      return "setYScalingUp";
      
    case SET_Z_SCALING_UP:
      return "setZScalingUp";
      
    default:
      println("Assertion: ActionType not added to EnumToString.");
      assert(false);
      return null;
  }
}

public ActionType actionTypeStringToEnum(String actionType)
{
  switch(actionType)
  {
    case "translate":
      return ActionType.TRANSLATE;
      
    case "setMovingLeft":
      return ActionType.SET_MOVING_LEFT;
      
    case "setMovingDown":
      return ActionType.SET_MOVING_DOWN;
      
    case "setMovingForward":
      return ActionType.SET_MOVING_FORWARD;
      
    case "rotate":
      return ActionType.ROTATE;
      
    case "scale":
      return ActionType.SCALE;
      
    case "setXScalingUp":
      return ActionType.SET_X_SCALING_UP;
      
    case "setYScalingUp":
      return ActionType.SET_Y_SCALING_UP;
      
    case "setZScalingUp":
      return ActionType.SET_Z_SCALING_UP;
      
    default:
      println("Assertion: String not mapped to an ActionType.");
      assert(false);
      return null;
  }
}

public abstract class Action implements IAction
{
  protected int timeStamp;
  
  public Action()
  {
    timeStamp = millis();
  }
  
  @Override public int getTimeStamp()
  {
    return timeStamp;
  }
}

public class TranslateAction extends Action
{
  private int uid;
  private PVector translation;
  
  public TranslateAction()
  {
    super();
    
    uid = -1;
    translation = new PVector();
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.TRANSLATE;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: TranslateAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: TranslateAction.apply() - target was null.");
      }
      else
      {
        target.translate(translation);
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonTranslateAction = new JSONObject();
    
    jsonTranslateAction.setString("ActionType", actionTypeEnumToString(ActionType.TRANSLATE));
    jsonTranslateAction.setInt("uid", uid);
    jsonTranslateAction.setFloat("x", translation.x);
    jsonTranslateAction.setFloat("y", translation.y);
    jsonTranslateAction.setFloat("z", translation.z);
    
    return jsonTranslateAction;
  }
  
  @Override public void deserialize(JSONObject jsonTranslateAction)
  {
    uid = jsonTranslateAction.getInt("uid");
    translation.x = jsonTranslateAction.getFloat("x");
    translation.y = jsonTranslateAction.getFloat("y");
    translation.z = jsonTranslateAction.getFloat("z");
  }
}

public class SetMovingLeftAction extends Action
{
  private int uid;
  private boolean movingLeft;
  
  public SetMovingLeftAction()
  {
    super();
    
    uid = -1;
    movingLeft = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_MOVING_LEFT;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setMovingLeft(boolean _movingLeft)
  {
    movingLeft = _movingLeft;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: SetMovingLeftAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: SetMovingLeftAction.apply() - target was null.");
      }
      else
      {
        IComponent component = target.getComponent(ComponentType.TRANSLATE_OVER_TIME);
        if (component == null)
        {
          println("WARNING: SetMovingLeftAction.apply() - translateOverTimeComponent was null.");
        }
        else
        {
          TranslateOverTimeComponent translateOverTimeComponent = (TranslateOverTimeComponent)component;
          translateOverTimeComponent.setMovingLeft(movingLeft);
        }
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetMovingLeftAction = new JSONObject();
    
    jsonSetMovingLeftAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_MOVING_LEFT));
    jsonSetMovingLeftAction.setInt("uid", uid);
    jsonSetMovingLeftAction.setBoolean("movingLeft", movingLeft);
    
    return jsonSetMovingLeftAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetMovingLeftAction)
  {
    uid = jsonSetMovingLeftAction.getInt("uid");
    movingLeft = jsonSetMovingLeftAction.getBoolean("movingLeft");
  }
}

public class SetMovingDownAction extends Action
{
  private int uid;
  private boolean movingDown;
  
  public SetMovingDownAction()
  {
    super();
    
    uid = -1;
    movingDown = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_MOVING_DOWN;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setMovingDown(boolean _movingDown)
  {
    movingDown = _movingDown;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: SetMovingDownAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: SetMovingDownAction.apply() - target was null.");
      }
      else
      {
        IComponent component = target.getComponent(ComponentType.TRANSLATE_OVER_TIME);
        if (component == null)
        {
          println("WARNING: SetMovingDownAction.apply() - TranslateOverTimeComponent was null.");
        }
        else
        {
          TranslateOverTimeComponent translateOverTimeComponent = (TranslateOverTimeComponent)component;
          translateOverTimeComponent.setMovingDown(movingDown);
        }
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetMovingDownAction = new JSONObject();
    
    jsonSetMovingDownAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_MOVING_DOWN));
    jsonSetMovingDownAction.setInt("uid", uid);
    jsonSetMovingDownAction.setBoolean("movingDown", movingDown);
    
    return jsonSetMovingDownAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetMovingDownAction)
  {
    uid = jsonSetMovingDownAction.getInt("uid");
    movingDown = jsonSetMovingDownAction.getBoolean("movingDown");
  }
}

public class SetMovingForwardAction extends Action
{
  private int uid;
  private boolean movingForward;
  
  public SetMovingForwardAction()
  {
    super();
    
    uid = -1;
    movingForward = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_MOVING_FORWARD;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setMovingForward(boolean _movingForward)
  {
    movingForward = _movingForward;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: SetMovingForwardAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING - SetMovingForwardAction.apply() - target was null.");
      }
      else
      {
        IComponent component = target.getComponent(ComponentType.TRANSLATE_OVER_TIME);
        if (component == null)
        {
          println("WARNING - SetMovingForwardAction.apply() - TranslateOverTimeComponent was null.");
        }
        else
        {
          TranslateOverTimeComponent translateOverTimeComponent = (TranslateOverTimeComponent)component;
          translateOverTimeComponent.setMovingForward(movingForward);
        }
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetMovingForwardAction = new JSONObject();
    
    jsonSetMovingForwardAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_MOVING_FORWARD));
    jsonSetMovingForwardAction.setInt("uid", uid);
    jsonSetMovingForwardAction.setBoolean("movingForward", movingForward);
    
    return jsonSetMovingForwardAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetMovingForwardAction)
  {
    uid = jsonSetMovingForwardAction.getInt("uid");
    movingForward = jsonSetMovingForwardAction.getBoolean("movingForward");
  }
}

public class RotateAction extends Action
{
  private int uid;
  private PVector rotation;
  
  public RotateAction()
  {
    super();
    
    uid = -1;
    rotation = new PVector();
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.ROTATE;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setRotation(PVector _rotation)
  {
    rotation = _rotation;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: RotateOverTimeAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: RotateOverTimeAction.apply() - target was null");
      }
      else
      {
        target.rotate(rotation);
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonRotateAction = new JSONObject();
    
    jsonRotateAction.setString("ActionType", actionTypeEnumToString(ActionType.ROTATE));
    jsonRotateAction.setInt("uid", uid);
    jsonRotateAction.setFloat("x", rotation.x);
    jsonRotateAction.setFloat("y", rotation.y);
    jsonRotateAction.setFloat("z", rotation.z);
    
    return jsonRotateAction;
  }
  
  @Override public void deserialize(JSONObject jsonRotateAction)
  {
    uid = jsonRotateAction.getInt("uid");
    rotation.x = jsonRotateAction.getFloat("x");
    rotation.y = jsonRotateAction.getFloat("y");
    rotation.z = jsonRotateAction.getFloat("z");
  }
}

public class ScaleAction extends Action
{
  private int uid;
  private PVector scale;
  
  public ScaleAction()
  {
    super();
    
    uid = -1;
    scale = new PVector();
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SCALE;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: ScaleOverTimeAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: ScaleOverTimeAction.apply() - target was null.");
      }
      else
      {
        target.scale(scale);
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonScaleAction = new JSONObject();
    
    jsonScaleAction.setString("ActionType", actionTypeEnumToString(ActionType.SCALE));
    jsonScaleAction.setInt("uid", uid);
    jsonScaleAction.setFloat("x", scale.x);
    jsonScaleAction.setFloat("y", scale.y);
    jsonScaleAction.setFloat("z", scale.z);
    
    return jsonScaleAction;
  }
  
  @Override public void deserialize(JSONObject jsonScaleAction)
  {
    uid = jsonScaleAction.getInt("uid");
    scale.x = jsonScaleAction.getFloat("x");
    scale.y = jsonScaleAction.getFloat("y");
    scale.z = jsonScaleAction.getFloat("z");
  }
}

public class SetXScalingUpAction extends Action
{
  private int uid;
  private boolean xScalingUp;
  
  public SetXScalingUpAction()
  {
    super();
    
    uid = -1;
    xScalingUp = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_X_SCALING_UP;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setXScalingUp(boolean _xScalingUp)
  {
    xScalingUp = _xScalingUp;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: SetXScalingUpAction.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: SetXScalingUpAction.apply() - target was null");
      }
      else
      {
        IComponent component = target.getComponent(ComponentType.SCALE_OVER_TIME);
        if (component == null)
        {
          println("WARNING: SetXScalingUpAction.apply() - ScaleOverTimeComponent was null");
        }
        else
        {
          ScaleOverTimeComponent scaleOverTimeComponent = (ScaleOverTimeComponent)component;
          scaleOverTimeComponent.setXScalingUp(xScalingUp);
        }
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetXScalingUpAction = new JSONObject();
    
    jsonSetXScalingUpAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_X_SCALING_UP));
    jsonSetXScalingUpAction.setInt("uid", uid);
    jsonSetXScalingUpAction.setBoolean("xScalingUp", xScalingUp);
    
    return jsonSetXScalingUpAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetXScalingUpAction)
  {
    uid = jsonSetXScalingUpAction.getInt("uid");
    xScalingUp = jsonSetXScalingUpAction.getBoolean("xScalingUp");
  }
}

public class SetYScalingUpAction extends Action
{
  private int uid;
  private boolean yScalingUp;
  
  public SetYScalingUpAction()
  {
    super();
    
    uid = -1;
    yScalingUp = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_Y_SCALING_UP;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setYScalingUp(boolean _yScalingUp)
  {
    yScalingUp = _yScalingUp;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: SetYScalingUp.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: SetYScalingUp.apply() - target was null");
      }
      else
      {
        IComponent component = target.getComponent(ComponentType.SCALE_OVER_TIME);
        if (component == null)
        {
          println("WARNING: SetYScalingUp.apply() - ScaleOverTimeComponent was null");
        }
        else
        {
          ScaleOverTimeComponent scaleOverTimeComponent = (ScaleOverTimeComponent)component;
          scaleOverTimeComponent.setYScalingUp(yScalingUp);
        }
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetYScalingUpAction = new JSONObject();
    
    jsonSetYScalingUpAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_Y_SCALING_UP));
    jsonSetYScalingUpAction.setInt("uid", uid);
    jsonSetYScalingUpAction.setBoolean("yScalingUp", yScalingUp);
    
    return jsonSetYScalingUpAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetYScalingUpAction)
  {
    uid = jsonSetYScalingUpAction.getInt("uid");
    yScalingUp = jsonSetYScalingUpAction.getBoolean("yScalingUp");
  }
}

public class SetZScalingUpAction extends Action
{
  private int uid;
  private boolean zScalingUp;
  
  public SetZScalingUpAction()
  {
    super();
    
    uid = -1;
    zScalingUp = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_Y_SCALING_UP;
  }
  
  public void setTargetUID(int _uid)
  {
    uid = _uid;
  }
  
  public void setZScalingUp(boolean _zScalingUp)
  {
    zScalingUp = _zScalingUp;
  }
  
  @Override public void apply()
  {
    if (uid == -1)
    {
      println("WARNING: SetZScalingUp.apply() - target uid was not set.");
    }
    else
    {
      IGameObject target = gameStateController.getSharedGameObjectManager().getGameObject(uid);
      if (target == null)
      {
        println("WARNING: SetZScalingUp.apply() - target was null");
      }
      else
      {
        IComponent component = target.getComponent(ComponentType.SCALE_OVER_TIME);
        if (component == null)
        {
          println("WARNING: SetZScalingUp.apply() - ScaleOverTimeComponent was null.");
        }
        else
        {
          ScaleOverTimeComponent scaleOverTimeComponent = (ScaleOverTimeComponent)component;
          scaleOverTimeComponent.setZScalingUp(zScalingUp);
        }
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetZScalingUpAction = new JSONObject();
    
    jsonSetZScalingUpAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_Z_SCALING_UP));
    jsonSetZScalingUpAction.setInt("uid", uid);
    jsonSetZScalingUpAction.setBoolean("zScalingUp", zScalingUp);
    
    return jsonSetZScalingUpAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetZScalingUpAction)
  {
    uid = jsonSetZScalingUpAction.getInt("uid");
    zScalingUp = jsonSetZScalingUpAction.getBoolean("zScalingUp");
  }
}

public IAction deserializeAction(JSONObject jsonAction)
{
  IAction action = null;
  
  ActionType actionType = actionTypeStringToEnum(jsonAction.getString("ActionType"));
  
  switch(actionType)
  {
    case TRANSLATE:
      action = new TranslateAction();
      break;
      
    case SET_MOVING_LEFT:
      action = new SetMovingLeftAction();
      break;
      
    case SET_MOVING_DOWN:
      action = new SetMovingDownAction();
      break;
      
    case SET_MOVING_FORWARD:
      action = new SetMovingForwardAction();
      break;
      
    case ROTATE:
      action = new RotateAction();
      break;
      
    case SCALE:
      action = new ScaleAction();
      break;
      
    case SET_X_SCALING_UP:
      action = new SetXScalingUpAction();
      break;
      
    case SET_Y_SCALING_UP:
      action = new SetYScalingUpAction();
      break;
      
    case SET_Z_SCALING_UP:
      action = new SetZScalingUpAction();
      break;
      
    default:
      println("Assertion: ActionType not added to deserializeAction.");
      assert(false);
  }
  
  if (action != null)
  {
    action.deserialize(jsonAction);
  }
  
  return action;
}
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
    destroy();
    
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
    setMovingLeftAction.setTargetUID(gameObject.getUID());
    setMovingLeftAction.setMovingLeft(movingLeft);
    
    actionBuffer.add(setMovingLeftAction);
  }
  
  private void addSetMovingDownAction()
  {
    SetMovingDownAction setMovingDownAction = new SetMovingDownAction();
    setMovingDownAction.setTargetUID(gameObject.getUID());
    setMovingDownAction.setMovingDown(movingDown);
    
    actionBuffer.add(setMovingDownAction);
  }
  
  private void addSetMovingForwardAction()
  {
    SetMovingForwardAction setMovingForwardAction = new SetMovingForwardAction();
    setMovingForwardAction.setTargetUID(gameObject.getUID());
    setMovingForwardAction.setMovingForward(movingForward);
    
    actionBuffer.add(setMovingForwardAction);
  }
  
  private void addTranslateAction(PVector translation)
  {
    TranslateAction translateAction = new TranslateAction();
    translateAction.setTargetUID(gameObject.getUID());
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
    rotateAction.setTargetUID(gameObject.getUID());
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
    setXScalingUpAction.setTargetUID(gameObject.getUID());
    setXScalingUpAction.setXScalingUp(xScalingUp);
    
    actionBuffer.add(setXScalingUpAction);
  }
  
  private void addSetYScalingUpAction()
  {
    SetYScalingUpAction setYScalingUpAction = new SetYScalingUpAction();
    setYScalingUpAction.setTargetUID(gameObject.getUID());
    setYScalingUpAction.setYScalingUp(yScalingUp);
    
    actionBuffer.add(setYScalingUpAction);
  }
  
  private void addSetZScalingUpAction()
  {
    SetZScalingUpAction setZScalingUpAction = new SetZScalingUpAction();
    setZScalingUpAction.setTargetUID(gameObject.getUID());
    setZScalingUpAction.setZScalingUp(zScalingUp);
    
    actionBuffer.add(setZScalingUpAction);
  }
  
  private void addScaleAction(PVector scale)
  {
    ScaleAction scaleAction = new ScaleAction();
    scaleAction.setTargetUID(gameObject.getUID());
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
//=========================================================================================================
// Author: David Hanna
//
// A re-usable game event system.
//=========================================================================================================

//----------------------------------------------------------------
// INTERFACE
//----------------------------------------------------------------

// The supported types of events. When adding a new event type, also add to the
// EventManager constructor a new collection for the type. 
public enum EventType
{
}

// This is the actual event that is created by the sender and sent to all listeners.
// Events must have a type, and may specify additional context parameters.
public interface IEvent
{
  // Use this to differentiate if your object is listening for multiple event types.
  public EventType   getEventType();
  
  // Adds a new context parameter of a certain type to this event.
  public void        addStringParameter(String name, String value);
  public void        addFloatParameter(String name, float value);
  public void        addIntParameter(String name, int value);
  public void        addGameObjectParameter(String name, IGameObject value);
  
  // Use these to get a parameter, but it does not have to have been set by the sender. A default value is required.
  public String      getOptionalStringParameter(String name, String defaultValue);
  public float       getOptionalFloatParameter(String name, float defaultValue);
  public int         getOptionalIntParameter(String name, int defaultValue);
  public IGameObject getOptionalGameObjectParameter(String name, IGameObject defaultValue);
  
  // Use these to get a parameter that must have been set by the sender. If the sender did not set it, this is an error
  // and the game will halt.
  public String      getRequiredStringParameter(String name);
  public float       getRequiredFloatParameter(String name);
  public int         getRequiredIntParameter(String name);
  public IGameObject getRequiredGameObjectParameter(String name);
}

// The Event Manager keeps track of listeners and forwards events to them.
public interface IEventManager
{
  // Use queueEvent to send out an event you have created to all listeners.
  // It will be received by listeners next frame.
  public void queueEvent(IEvent event);
  
  // Returns the events of a given type that were queued last frame.
  public ArrayList<IEvent> getEvents(EventType eventType);
  
  // Only the main loop should call this. Clears ready events from last frame and 
  // moves the queued events to the ready events for this frame.
  public void update();
}

//-------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------

public class Event implements IEvent
{
  private EventType eventType;
  
  private HashMap<String, String> stringParameters;
  private HashMap<String, Float> floatParameters;
  private HashMap<String, Integer> intParameters;
  private HashMap<String, IGameObject> gameObjectParameters;
  
  public Event(EventType _eventType)
  {
    eventType = _eventType;
    stringParameters = new HashMap<String, String>();
    floatParameters = new HashMap<String, Float>();
    intParameters = new HashMap<String, Integer>();
    gameObjectParameters = new HashMap<String, IGameObject>();
  }
  
  @Override public EventType getEventType()
  {
    return eventType;
  }
  
  @Override public void addStringParameter(String name, String value)
  {
    stringParameters.put(name, value);
  }
  
  @Override public void addFloatParameter(String name, float value)
  {
    floatParameters.put(name, value);
  }
  
  @Override public void addIntParameter(String name, int value)
  {
    intParameters.put(name, value);
  }
  
  @Override public void addGameObjectParameter(String name, IGameObject value)
  {
    gameObjectParameters.put(name, value);
  }
  
  @Override public String getOptionalStringParameter(String name, String defaultValue)
  {
    if (stringParameters.containsKey(name))
    {
      return stringParameters.get(name);
    }
    
     return defaultValue;
  }
  
  @Override public float getOptionalFloatParameter(String name, float defaultValue)
  {
    if (floatParameters.containsKey(name))
    {
      return floatParameters.get(name);
    }
     
     return defaultValue;
  }
  
  @Override public int getOptionalIntParameter(String name, int defaultValue)
  {
    if (intParameters.containsKey(name))
    {
      return intParameters.get(name);
    }
    
    return defaultValue;
  }
  
  @Override public IGameObject getOptionalGameObjectParameter(String name, IGameObject defaultValue)
  {
    if (gameObjectParameters.containsKey(name))
    {
      return gameObjectParameters.get(name);
    }
    
    return defaultValue;
  }
  
 @Override  public String getRequiredStringParameter(String name)
  {
    assert(stringParameters.containsKey(name));
    return stringParameters.get(name);
  }
  
  @Override public float getRequiredFloatParameter(String name)
  {
    assert(floatParameters.containsKey(name));
    return floatParameters.get(name);
  }
  
  @Override public int getRequiredIntParameter(String name)
  {
    assert(intParameters.containsKey(name));
    return intParameters.get(name);
  }
  
  @Override public IGameObject getRequiredGameObjectParameter(String name)
  {
    assert(gameObjectParameters.containsKey(name));
    return gameObjectParameters.get(name);
  }
}

public class EventManager implements IEventManager
{
  // queued events will be ready and received by listeners next frame. cleared each frame.
  private HashMap<EventType, ArrayList<IEvent>> queuedEvents;
  
  // ready events are cleared and added to from queued events each frame.
  private HashMap<EventType, ArrayList<IEvent>> readyEvents;
  
  public EventManager()
  {
    queuedEvents = new HashMap<EventType, ArrayList<IEvent>>();
    readyEvents = new HashMap<EventType, ArrayList<IEvent>>();
    
    //addEventTypeToMaps(EventType.ACTION);
  }
  
  private void addEventTypeToMaps(EventType eventType)
  {
    queuedEvents.put(eventType, new ArrayList<IEvent>());
    readyEvents.put(eventType, new ArrayList<IEvent>());
  }
  
  @Override public void queueEvent(IEvent event)
  {
    queuedEvents.get(event.getEventType()).add(event);
  }
  
  @Override public ArrayList<IEvent> getEvents(EventType eventType)
  {
    return readyEvents.get(eventType);
  }
  
  @Override public void update()
  {
    for (Map.Entry entry : queuedEvents.entrySet())
    {
      EventType eventType = (EventType)entry.getKey();
      ArrayList<IEvent> queuedEventsList = (ArrayList<IEvent>)entry.getValue();
      
      ArrayList<IEvent> readyEventsList = readyEvents.get(eventType);
      readyEventsList.clear();
      
      for (IEvent event : queuedEventsList)
      {
        readyEventsList.add(event);
      }
      
      queuedEventsList.clear();
    }
  }
}
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
  public HashMap<Integer, IGameObject> getGameObjects();
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
}
 //========================================================================================
// Author: David Hanna
//
// The abstraction of a game state.
//========================================================================================

//-------------------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------------------

public interface IGameState
{
  public void onEnter();
  public void update(int deltaTime);
  public void onExit();
  public IGameObjectManager getLocalGameObjectManager();  // holds Game Objects that belong only to the current screen, such as the camera.
  public IGameObjectManager getSharedGameObjectManager(); // holds Game Objects that need to be networked.
}

public abstract class GameState implements IGameState
{
  protected IGameObjectManager localGameObjectManager;
  protected IGameObjectManager sharedGameObjectManager;
  
  public GameState()
  {
    localGameObjectManager = new GameObjectManager();
    sharedGameObjectManager = new GameObjectManager();
  }
  
  @Override abstract public void onEnter();
  @Override abstract public void update(int deltaTime);
  @Override abstract public void onExit();
  
  @Override public IGameObjectManager getLocalGameObjectManager()
  {
    return localGameObjectManager;
  }
  
  @Override public IGameObjectManager getSharedGameObjectManager()
  {
    return sharedGameObjectManager;
  }
}

public interface IGameStateController
{
  public void update(int deltaTime);
  public void pushState(GameState nextState);
  public void popState();
  public IGameState getCurrentState();
  public IGameState getPreviousState();
  public IGameObjectManager getLocalGameObjectManager();
  public IGameObjectManager getSharedGameObjectManager();
}


//-------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------

public class GameState_ChooseClientServerState extends GameState
{
  public GameState_ChooseClientServerState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
  }
  
  @Override public void update(int deltaTime)
  {
    if (keyPressed)
    {
      if (key == 's')
      {
        gameStateController.pushState(new GameState_ServerState());
      }
      else if (key == 'c')
      {
        gameStateController.pushState(new GameState_ClientState());
      }
    }
  }
  
  @Override public void onExit()
  {
  }
}

public class GameState_ClientState extends GameState implements IClientCallbackHandler
{
  public GameState_ClientState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    mainClient = new MSClient("127.0.0.1", 5204, this);
    if (mainClient.connect())
    {
      println("Client connected.");
    }
    else
    {
      println("Client failed to connect.");
    }
  }
  
  @Override public void update(int deltaTime)
  {
    mainClient.update();
    synchronized(sharedGameObjectManager)
    {
      //sharedGameObjectManager.update(deltaTime);
      for (Map.Entry entrySet : sharedGameObjectManager.getGameObjects().entrySet())
      {
        IGameObject gameObject = (IGameObject)entrySet.getValue();
        gameObject.getComponent(ComponentType.RENDER).update(deltaTime);
      }
      scene.render();
      //if (actionBuffer.size() > 0)
      //{
      //  writeToServer();
      //}
    } //<>//
  }
  
  @Override public void onExit()
  {
    mainClient.disconnect();
    mainClient = null;
  }
  
  @Override public void handleServerMessage(String serverMessage)
  {
    JSONArray jsonGameWorld = JSONArray.parse(serverMessage);
    if (jsonGameWorld != null)
    {
      synchronized(sharedGameObjectManager)
      {
        sharedGameObjectManager.deserialize(jsonGameWorld);
        //for (IAction action : actionBuffer)
        //{
        //  action.apply();
        //}
      }
    }
    else
    {
      println("Failed to parse server message into JSON form: " + serverMessage);
    }
  }
  
  private void writeToServer()
  {
    if (mainClient.isConnected())
    {
      JSONArray jsonActions = new JSONArray();
      for (IAction action : actionBuffer)
      {
        jsonActions.append(action.serialize());
      }
      if (jsonActions.size() > 0)
      {
        mainClient.write(jsonActions.toString());
      }
      actionBuffer.clear();
    }
    else
    {
      println("mainClient no longer connected.");
    }
  }
}

public class GameState_ServerState extends GameState implements IServerCallbackHandler
{
  private ServerStateThread serverStateThread;
  
  public GameState_ServerState()
  {
    super();
    
    serverStateThread = new ServerStateThread();
  }
  
  @Override public void onEnter()
  {
    sharedGameObjectManager.fromXML("levels/sample_level.xml");
    
    mainServer = new MSServer(5204, this);
    if (mainServer.begin())
    {
      println("Server started.");
    }
    else
    {
      println("WARNING: Failed to start server.");
    }
  }
  
  @Override public void update(int deltaTime)
  {
    sharedGameObjectManager.update(deltaTime);
    scene.render();
    if (!serverStateThread.isAlive())
    {
      serverStateThread.setMessage(sharedGameObjectManager.serialize().toString());
      serverStateThread.start();
    } //<>//
  }
  
  @Override public void onExit()
  {
    mainServer.end();
  }
  
  @Override public String getInitializationMessage()
  {
    return "";
  }
  
  @Override public void handleClientMessage(String clientMessage)
  {
    JSONArray jsonActionList = parseJSONArray(clientMessage);
    
    if (jsonActionList != null)
    {
      for (int i = 0; i < jsonActionList.size(); i++)
      {
        IAction action = deserializeAction(jsonActionList.getJSONObject(i));
        action.apply();
      }
    }
    else
    {
      println("Failed to parse into JSONArray: " + clientMessage);
    }
  }
}

public class ServerStateThread extends Thread
{
  private String message;
  
  public ServerStateThread()
  {
  }
  
  public void setMessage(String _message)
  {
    message = _message;
  }
  
  @Override public void start()
  {
    mainServer.update();
    mainServer.write(message);
  }
}

public class GameStateController implements IGameStateController
{
  private LinkedList<GameState> stateStack;
  
  public GameStateController()
  {
    stateStack = new LinkedList<GameState>();
  }
  
  @Override public void update(int deltaTime)
  {
    if (!stateStack.isEmpty())
    {
      stateStack.peekLast().update(deltaTime);
    }
  }
  
  @Override public void pushState(GameState nextState)
  {
    stateStack.addLast(nextState);
    nextState.onEnter();
  }
  
  @Override public void popState()
  {
    IGameState poppedState = stateStack.peekLast();
    poppedState.onExit();
    stateStack.removeLast();
  }
  
  @Override public IGameState getCurrentState()
  {
    if (stateStack.size() < 1)
    {
      return null;
    }
    return stateStack.peekLast();
  }
  
  @Override public IGameState getPreviousState()
  {
    if (stateStack.size() < 2)
    {
      return null;
    }
    return stateStack.get(stateStack.size() - 2);
  }
  
  @Override public IGameObjectManager getLocalGameObjectManager()
  {
    return stateStack.peekLast().getLocalGameObjectManager();
  }
  
  @Override public IGameObjectManager getSharedGameObjectManager()
  {
    return stateStack.peekLast().getSharedGameObjectManager();
  }
}
//======================================================================================================
// Author: David Hanna
//
// A collection of material libs. Each material lib is a .mtl file containing material definitions.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface IMaterial
{
  public int        fromMTL(String[] mtlFile, int lineIndex);
  public JSONObject serialize();
  public void       deserialize(JSONObject jsonMaterial);
  public String     getName();
  public PVector    getAmbientReflect();
  public PVector    getDiffuseReflect();
  public PVector    getSpecularReflect();
  public float      getSpecularExponent();
  public float      getDissolve();
  public PImage     getTexture();
}

public interface IMaterialLib
{
  public void      fromMTL(String mtlFileName);
  public String    getName();
  public IMaterial getMaterial(String name);
}

public interface IMaterialLibManager
{
  public IMaterialLib getMaterialLib(String mtlFileName);
}


//----------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//----------------------------------------------------------------------------------------------------

public class Material implements IMaterial
{
  private String name;
  
  private PVector ambientReflect;
  private PVector diffuseReflect;
  private PVector specularReflect;
  private float specularExponent;
  
  private float dissolve; // transparency
  
  private String textureFileName;
  private PImage texture;
  
  public Material()
  {
    ambientReflect = new PVector();
    diffuseReflect = new PVector();
    specularReflect = new PVector();
  }
  
  public Material(JSONObject jsonMaterial)
  {
    deserialize(jsonMaterial);
  }
  
  // Returns the line index this method stopped parsing (the end of the material).
  @Override public int fromMTL(String[] mtlFile, int lineIndex)
  {
    String[] firstLineWords = mtlFile[lineIndex].split(" ");
    assert(firstLineWords[0].equals("newmtl"));
    name = firstLineWords[1];
    ++lineIndex;
    
    for (String line; lineIndex < mtlFile.length; ++lineIndex)
    {
      line = mtlFile[lineIndex];
      String[] words = line.split(" ");
      
      switch(words[0])
      {
        case "Ka":
          ambientReflect = new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3]));
          break;
          
        case "Kd":
          diffuseReflect = new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3]));
          break;
          
        case "Ks":
          specularReflect = new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3]));
          break;
          
        case "Ns":
          specularExponent = Float.parseFloat(words[1]);
          break;
          
        case "d":
          dissolve = Float.parseFloat(words[1]);
          break;
          
        case "Tr":
          dissolve = 1.0f - Float.parseFloat(words[1]);
          break;
          
        case "map_Kd":
          textureFileName = words[1];
          texture = textureManager.getTexture(textureFileName);
          break;
          
        case "newmtl":
          return lineIndex;
      }
    }
    
    return lineIndex;
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonMaterial = new JSONObject();
    
    jsonMaterial.setString("name", name);
    
    JSONObject jsonAmbientReflect = new JSONObject();
    jsonAmbientReflect.setFloat("r", ambientReflect.x);
    jsonAmbientReflect.setFloat("g", ambientReflect.y);
    jsonAmbientReflect.setFloat("b", ambientReflect.z);
    jsonMaterial.setJSONObject("ambientReflect", jsonAmbientReflect);
    
    JSONObject jsonDiffuseReflect = new JSONObject();
    jsonDiffuseReflect.setFloat("r", diffuseReflect.x);
    jsonDiffuseReflect.setFloat("g", diffuseReflect.y);
    jsonDiffuseReflect.setFloat("b", diffuseReflect.z);
    jsonMaterial.setJSONObject("diffuseReflect", jsonDiffuseReflect);
    
    JSONObject jsonSpecularReflect = new JSONObject();
    jsonSpecularReflect.setFloat("r", specularReflect.x);
    jsonSpecularReflect.setFloat("g", specularReflect.y);
    jsonSpecularReflect.setFloat("b", specularReflect.z);
    jsonMaterial.setJSONObject("specularReflect", jsonSpecularReflect);
    
    jsonMaterial.setFloat("specularExponent", specularExponent);
    
    jsonMaterial.setFloat("dissolve", dissolve);
    
    jsonMaterial.setString("textureFileName", textureFileName);
    
    return jsonMaterial;
  }
  
  @Override public void deserialize(JSONObject jsonMaterial)
  {
    name = jsonMaterial.getString("name");
        
    JSONObject jsonAmbientReflect = jsonMaterial.getJSONObject("ambientReflect");
    ambientReflect = new PVector(jsonAmbientReflect.getFloat("r"), jsonAmbientReflect.getFloat("g"), jsonAmbientReflect.getFloat("b"));
    
    JSONObject jsonDiffuseReflect = jsonMaterial.getJSONObject("diffuseReflect");
    diffuseReflect = new PVector(jsonDiffuseReflect.getFloat("r"), jsonDiffuseReflect.getFloat("g"), jsonDiffuseReflect.getFloat("b"));
    
    JSONObject jsonSpecularReflect = jsonMaterial.getJSONObject("specularReflect");
    specularReflect = new PVector(jsonSpecularReflect.getFloat("r"), jsonSpecularReflect.getFloat("g"), jsonSpecularReflect.getFloat("b"));
    
    specularExponent = jsonMaterial.getFloat("specularExponent");
    
    dissolve = jsonMaterial.getFloat("dissolve");
    
    textureFileName = jsonMaterial.getString("textureFileName");
    
    texture = textureManager.getTexture(textureFileName);
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public PVector getAmbientReflect()
  {
    return ambientReflect;
  }
  
  @Override public PVector getDiffuseReflect()
  {
    return diffuseReflect;
  }
  
  @Override public PVector getSpecularReflect()
  {
    return specularReflect;
  }
  
  @Override public float getSpecularExponent()
  {
    return specularExponent;
  }
  
  @Override public float getDissolve()
  {
    return dissolve;
  }
  
  @Override public PImage getTexture()
  {
    return texture;
  }
}

public class MaterialLib implements IMaterialLib
{
  private String name;
  private HashMap<String, IMaterial> materials;
  
  public MaterialLib()
  {
    materials = new HashMap<String, IMaterial>();
  }
  
  @Override public void fromMTL(String mtlFileName)
  {
    name = mtlFileName;
    String[] mtlFile = loadStrings(mtlFileName);
    
    for (int lineIndex = 0; lineIndex < mtlFile.length;)
    {
      String[] words = mtlFile[lineIndex].split(" ");
      
      if (words[0].equals("newmtl"))
      {
        IMaterial material = new Material();
        lineIndex = material.fromMTL(mtlFile, lineIndex);
        materials.put(material.getName(), material);
      }
      else
      {
        ++lineIndex;
      }
    }
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public IMaterial getMaterial(String name)
  {
    return materials.get(name);
  }
}

public class MaterialLibManager implements IMaterialLibManager
{
  private HashMap<String, IMaterialLib> materialLibs;
  
  public MaterialLibManager()
  {
    materialLibs = new HashMap<String, IMaterialLib>();
  }
  
  @Override public IMaterialLib getMaterialLib(String mtlFileName)
  {
    if (!materialLibs.containsKey(mtlFileName))
    {
      IMaterialLib materialLib = new MaterialLib();
      materialLib.fromMTL(mtlFileName);
      materialLibs.put(materialLib.getName(), materialLib);
    }
    return materialLibs.get(mtlFileName);
  }
}
//===============================================================================================================
// Author: David Hanna
//
// Classes embodying clients and servers for networking.
//===============================================================================================================

//----------------------------------------------------------------
// INTERFACE
//----------------------------------------------------------------

IClient mainClient = null;
IServer mainServer = null;

public interface IClient
{
  public boolean connect();
  public void update();
  public void disconnect();
  public boolean isConnected();
  public void write(String message);
  public void handleClientEvent(String serverBytes);
}

public interface IClientCallbackHandler
{
  public void handleServerMessage(String serverMessage);
}

public interface IServer
{
  public boolean begin();
  public void update();
  public void end();
  public boolean isActive();
  public void write(String message);
  public void handleServerEvent(Client pClient);
}

public interface IServerCallbackHandler
{
  public String getInitializationMessage();
  public void handleClientMessage(String clientMessage);
}

//----------------------------------------------------------------
// IMPLEMENTATION
//----------------------------------------------------------------

public final String BEGIN_TOKEN = ":::B:::";
public final String END_TOKEN = ":::E:::";

public void clientEvent(Client pClient)
{
  if (mainClient != null)
  {
    while (pClient.available() > 0)
    {
      mainClient.handleClientEvent(pClient.readString());
    }
  }
}

public class MSClient implements IClient
{
  private String ipAddress;
  private int port;
  private IClientCallbackHandler handler;
  private Client pClient;
  private String buffer;
  private int clientID;
  private int messageID;
  
  public MSClient(String _ipAddress, int _port, IClientCallbackHandler _handler)
  {
    ipAddress = _ipAddress;
    port = _port;
    handler = _handler;
    pClient = null;
    buffer = "";
    clientID = 0;
    messageID = 0;
  }
  
  @Override public boolean connect()
  {
    pClient = new Client(mainObject, ipAddress, port);
    if (isConnected())
    {
      return true;
    }
    else
    {
      pClient = null;
      return false;
    }
  }
  
  @Override public void update()
  {
    if (isConnected())
    {
      synchronized(this)
      {
        if (!buffer.startsWith(BEGIN_TOKEN) && buffer.length() > BEGIN_TOKEN.length())
        {
          int beginTokenIndex = buffer.indexOf(BEGIN_TOKEN);
          if (beginTokenIndex != -1)
          {
            buffer = buffer.substring(beginTokenIndex, buffer.length());
          }
        }
        
        while (buffer.startsWith(BEGIN_TOKEN))
        {
          int endTokenIndex = buffer.indexOf(END_TOKEN);
          if (endTokenIndex == -1)
          {
            break;
          }
          else
          {
            handler.handleServerMessage(buffer.substring(BEGIN_TOKEN.length(), endTokenIndex));
            buffer = buffer.substring(endTokenIndex + END_TOKEN.length(), buffer.length());
          }
        }
      }
    }
  }
  
  @Override public void disconnect()
  {
    if (isConnected())
    {
      pClient.stop();
      pClient = null;
    }
  }
  
  @Override public boolean isConnected()
  {
    return pClient != null && pClient.active();
  }
  
  @Override public void write(String message)
  {
    JSONObject jsonMessageHeader = new JSONObject();
    jsonMessageHeader.setInt("clientID", clientID);
    jsonMessageHeader.setInt("messageID", messageID++);
    
    JSONObject jsonMessage = new JSONObject();
    jsonMessage.setJSONObject("header", jsonMessageHeader);
    jsonMessage.setString("body", message);
    
    if (isConnected())
    {
      pClient.write(BEGIN_TOKEN + jsonMessage.toString() + END_TOKEN);
    }
  }
  
  @Override public void handleClientEvent(String serverBytes)
  {
    synchronized(this)
    {
      buffer += serverBytes;
    }
  }
}

public void serverEvent(Server pServer, Client pClient)
{
  if (mainServer != null)
  {
    mainServer.handleServerEvent(pClient);
  }
}

public class MSServer implements IServer
{
  private int port;
  private IServerCallbackHandler handler;
  private Server pServer;
  private String buffer;
  
  public MSServer(int _port, IServerCallbackHandler _handler)
  {
    port = _port;
    handler = _handler;
    pServer = null;
    buffer = "";
  }
  
  @Override public boolean begin()
  {
    if (pServer == null)
    {
      pServer = new Server(mainObject, port);
      
      if (isActive())
      {
        return true;
      }
      else
      {
        pServer = null;
        return false;
      }
    }
    else
    {
      println("WARNING: Trying to begin a server that is already active.");
      return false;
    }
  }
  
  @Override public void update()
  {
    if (isActive())
    {
      Client pClient = pServer.available();
      
      if (pClient != null)
      {
        buffer += pClient.readString();
        
        if (!buffer.startsWith(BEGIN_TOKEN) && buffer.length() > BEGIN_TOKEN.length())
        {
          println("WARNING: There has been a protocol error: " + buffer);
          end();
        }
        
        while (buffer.startsWith(BEGIN_TOKEN))
        {
          int endTokenIndex = buffer.indexOf(END_TOKEN);
          if (endTokenIndex == -1)
          {
            break;
          }
          else
          {
            String clientMessage = buffer.substring(BEGIN_TOKEN.length(), endTokenIndex);
            
            JSONObject jsonClientMessage = JSONObject.parse(clientMessage);
            JSONObject jsonHeader = jsonClientMessage.getJSONObject("header");
            
            int clientID = jsonHeader.getInt("clientID");
            int messageID = jsonHeader.getInt("messageID");
            //println("clientID: " + clientID);
            //println("messageID: " + messageID);
            
            handler.handleClientMessage(jsonClientMessage.getString("body"));
            
            buffer = buffer.substring(endTokenIndex + END_TOKEN.length(), buffer.length());
          }
        }
      }
    }
  }
  
  @Override public void end()
  {
    if (isActive())
    {
      pServer.stop();
      pServer = null;
    }
  }
  
  @Override public boolean isActive()
  {
    return pServer != null && pServer.active();
  }
  
  @Override public void write(String message)
  {
    if (isActive())
    {
      pServer.write(BEGIN_TOKEN + message + END_TOKEN);
    }
  }
  
  @Override public void handleServerEvent(Client pClient)
  {
    pClient.write(BEGIN_TOKEN + handler.getInitializationMessage() + END_TOKEN);
  }
}
//======================================================================================================
// Author: David Hanna
//
// An module responsible for rendering a collection of objects to the screen.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface ICamera
{
  public PVector getPosition();
  public PVector getTarget();
  public PVector getUp();
  
  public void setPosition(PVector position);
  public void setTarget(PVector target);
  public void setUp(PVector up);
  
  public void setToDefaults();
  
  public void apply();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonCamera);
}

public interface IPerspectiveCamera extends ICamera
{
  public float getFieldOfView();
  public float getAspectRatio();
  public float getNear();
  public float getFar();
  
  public void setFieldOfView(float fieldOfView);
  public void setAspectRatio(float aspectRatio);
  public void setNear(float near);
  public void setFar(float far);
}

public interface IOrthographicCamera extends ICamera
{
  public float getLeft();
  public float getRight();
  public float getBottom();
  public float getTop();
  public float getNear();
  public float getFar();
  
  public void setLeft(float left);
  public void setRight(float right);
  public void setBottom(float bottom);
  public void setTop(float top);
  public void setNear(float near);
  public void setFar(float far);
}

public interface ISprite
{
  public String getName();
  
  public PVector getTranslation();
  public float getRotation();
  public PVector getScale();
  
  public void setTranslation(PVector translation);
  public void setRotation(float rotation);
  public void setScale(PVector scale);
  
  public void render();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonSprite);
}

public interface IModel
{
  public void fromOBJ(String objFileName);
  
  public String getName();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  
  public void render();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonModel);
}

public interface IScene
{
  public IOrthographicCamera getOrthographicCamera();
  public void setOrthographicCamera(IOrthographicCamera orthographicCamera);
  
  public IPerspectiveCamera getPerspectiveCamera();
  public void setPerspectiveCamera(IPerspectiveCamera perspectiveCamera);
  
  public void addSprite(ISprite sprite);
  public ISprite getSprite(String name);
  public void removeSprite(String name);
  
  public void addModel(IModel model);
  public IModel getModel(String name);
  public void removeModel(String name);
  
  public void render();
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public abstract class Camera implements ICamera
{
  private PVector position;
  private PVector target;
  private PVector up;
  
  public Camera()
  {
    setToDefaults();
  }
  
  @Override public PVector getPosition()
  {
    return position;
  }
  
  @Override public PVector getTarget()
  {
    return target;
  }
  
  @Override public PVector getUp()
  {
    return up;
  }
  
  @Override public void setPosition(PVector _position)
  {
    position = _position;
  }
  
  @Override public void setTarget(PVector _target)
  {
    target = _target;
  }
  
  @Override public void setUp(PVector _up)
  {
    up = _up;
  }
  
  @Override public void setToDefaults()
  {
    position = new PVector(0.0f, 0.0f, 10.0f);
    target = new PVector(0.0f, 0.0f, 0.0f);
    up = new PVector(0.0f, -1.0f, 0.0f);
  }
  
  @Override public void apply()
  {
    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonPosition = new JSONObject();
    jsonPosition.setFloat("x", position.x);
    jsonPosition.setFloat("y", position.y);
    jsonPosition.setFloat("z", position.z);
    
    JSONObject jsonTarget = new JSONObject();
    jsonTarget.setFloat("x", target.x);
    jsonTarget.setFloat("y", target.y);
    jsonTarget.setFloat("z", target.z);
    
    JSONObject jsonUp = new JSONObject();
    jsonUp.setFloat("x", up.x);
    jsonUp.setFloat("y", up.y);
    jsonUp.setFloat("z", up.z);
    
    JSONObject jsonCamera = new JSONObject();
    jsonCamera.setJSONObject("position", jsonPosition);
    jsonCamera.setJSONObject("target", jsonTarget);
    jsonCamera.setJSONObject("up", jsonUp);
    
    return jsonCamera;
  }
  
  @Override public void deserialize(JSONObject jsonCamera)
  {
    JSONObject jsonPosition = jsonCamera.getJSONObject("position");
    JSONObject jsonTarget = jsonCamera.getJSONObject("target");
    JSONObject jsonUp = jsonCamera.getJSONObject("up");
    
    position.x = jsonPosition.getFloat("x");
    position.y = jsonPosition.getFloat("y");
    position.z = jsonPosition.getFloat("z");
    
    target.x = jsonTarget.getFloat("x");
    target.y = jsonTarget.getFloat("y");
    target.z = jsonTarget.getFloat("z");
    
    up.x = jsonUp.getFloat("x");
    up.y = jsonUp.getFloat("y");
    up.z = jsonUp.getFloat("z");
  }
}

public class PerspectiveCamera extends Camera implements IPerspectiveCamera
{
  private float fieldOfView;
  private float aspectRatio;
  private float near;
  private float far;
  
  public PerspectiveCamera()
  {
    setToDefaults();
  }
  
  @Override public float getFieldOfView()
  {
    return fieldOfView;
  }
  
  @Override public float getAspectRatio()
  {
    return aspectRatio;
  }
  
  @Override public float getNear()
  {
    return near;
  }
  
  @Override public float getFar()
  {
    return far;
  }
  
  @Override public void setFieldOfView(float _fieldOfView)
  {
    fieldOfView = _fieldOfView;
  }
  
  @Override public void setAspectRatio(float _aspectRatio)
  {
    aspectRatio = _aspectRatio;
  }
  
  @Override public void setNear(float _near)
  {
    near = _near;
  }
  
  @Override public void setFar(float _far)
  {
    far = _far;
  }
  
  @Override public void setToDefaults()
  {
    super.setToDefaults();
    
    fieldOfView = PI / 3.0f;
    aspectRatio = 4.0f / 3.0f;
    near = 0.1f;
    far = 1000.0f;
  }
  
  @Override public void apply()
  {
    super.apply();
    
    perspective(fieldOfView, aspectRatio, near, far);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonPerspectiveCamera = super.serialize();
    
    jsonPerspectiveCamera.setFloat("fieldOfView", fieldOfView);
    jsonPerspectiveCamera.setFloat("aspectRatio", aspectRatio);
    jsonPerspectiveCamera.setFloat("near", near);
    jsonPerspectiveCamera.setFloat("far", far);
    
    return jsonPerspectiveCamera;
  }
  
  @Override public void deserialize(JSONObject jsonPerspectiveCamera)
  {
    super.deserialize(jsonPerspectiveCamera);
    
    fieldOfView = jsonPerspectiveCamera.getFloat("fieldOfView");
    aspectRatio = jsonPerspectiveCamera.getFloat("aspectRatio");
    near = jsonPerspectiveCamera.getFloat("near");
    far = jsonPerspectiveCamera.getFloat("far");
  }
}

public class OrthographicCamera extends Camera implements IOrthographicCamera
{
  private float left;
  private float right;
  private float bottom;
  private float top;
  private float near;
  private float far;
  
  public OrthographicCamera()
  {
    setToDefaults();
  }
  
  @Override public float getLeft()
  {
    return left;
  }
  
  @Override public float getRight()
  {
    return right;
  }
  
  @Override public float getBottom()
  {
    return bottom;
  }
  
  @Override public float getTop()
  {
    return top;
  }
  
  @Override public float getNear()
  {
    return near;
  }
  
  @Override public float getFar()
  {
    return far;
  }
  
  @Override public void setLeft(float _left)
  {
    left = _left;
  }
  
  @Override public void setRight(float _right)
  {
    right = _right;
  }
  
  @Override public void setBottom(float _bottom)
  {
    bottom = _bottom;
  }
  
  @Override public void setTop(float _top)
  {
    top = _top;
  }
  
  @Override public void setNear(float _near)
  {
    near = _near;
  }
  
  @Override public void setFar(float _far)
  {
    far = _far;
  }
  
  @Override public void setToDefaults()
  {
    super.setToDefaults();
    
    left = -width / 2.0f;
    right = width / 2.0f;
    bottom = -height / 2.0f;
    top = height / 2.0f;
    float cameraZ = ((height / 2.0f) / tan(PI * 60.0f / 360.0f));
    near = cameraZ / 10.0f;
    far = cameraZ * 10.0f;
  }
  
  @Override public void apply()
  {
    super.apply();
    ortho(left, right, bottom, top, near, far);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonOrthographicCamera = super.serialize();
    
    jsonOrthographicCamera.setFloat("left", left);
    jsonOrthographicCamera.setFloat("right", right);
    jsonOrthographicCamera.setFloat("bottom", bottom);
    jsonOrthographicCamera.setFloat("top", top);
    jsonOrthographicCamera.setFloat("near", near);
    jsonOrthographicCamera.setFloat("far", far);
    
    return jsonOrthographicCamera;
  }
  
  @Override public void deserialize(JSONObject jsonOrthographicCamera)
  {
    super.deserialize(jsonOrthographicCamera);
    
    left = jsonOrthographicCamera.getFloat("left");
    right = jsonOrthographicCamera.getFloat("right");
    bottom = jsonOrthographicCamera.getFloat("bottom");
    top = jsonOrthographicCamera.getFloat("top");
    near = jsonOrthographicCamera.getFloat("near");
    far = jsonOrthographicCamera.getFloat("far");
  }
}

public class Sprite implements ISprite
{
  private String name;
  
  private PVector translation;
  private float rotation;
  private PVector scale;
  
  public Sprite(String _name)
  {
    name = _name;
    
    translation = new PVector();
    rotation = 0.0f;
    scale = new PVector(1.0f, 1.0f);
  }
  
  public Sprite(JSONObject jsonSprite)
  {
    deserialize(jsonSprite);
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public PVector getTranslation()
  {
    return translation;
  }
  
  @Override public float getRotation()
  {
    return rotation;
  }
  
  @Override public PVector getScale()
  {
    return scale;
  }
  
  @Override public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  @Override public void setRotation(float _rotation)
  {
    rotation = _rotation;
  }
  
  @Override public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  @Override public void render()
  {
  }
  
  @Override public JSONObject serialize()
  {
    return new JSONObject();
  }
  
  @Override public void deserialize(JSONObject jsonSprite)
  {
    name = jsonSprite.getString("name");
  }
}

public class Model implements IModel
{
  private class PShapeExt
  {
    PShape pshape;
    ArrayList<PVector> uvs;
  }
  
  private String name;
  
  private ArrayList<PShapeExt> faces;
  private IMaterial material;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  public Model(String _name)
  {
    name = _name;
    
    faces = new ArrayList<PShapeExt>();
    material = new Material();
    
    translation = new PVector();
    rotation = new PVector();
    scale = new PVector(1.0f, 1.0f, 1.0f);
  }
  
  public Model(JSONObject jsonModel)
  {
    deserialize(jsonModel);
  }
  
  @Override public void fromOBJ(String objFileName)
  {
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    ArrayList<PVector> uvs = new ArrayList<PVector>();
    IMaterialLib materialLib = null;
    
    // These are dummy inserts so we don't need to subtract all the indices in the .obj file by one.
    vertices.add(new PVector());
    uvs.add(new PVector());
    
    for (String line : loadStrings(objFileName))
    {
      String[] words = line.split(" ");
      
      switch(words[0])
      {
        case "mtllib":
          materialLib = materialLibManager.getMaterialLib(words[1]);
          break;
          
        case "v":
          vertices.add(new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3])));
          break;
          
        case "vt":
          uvs.add(new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2])));
          break;
          
        case "usemtl":
          if (materialLib != null)
          {
            material = materialLib.getMaterial(words[1]);
          }
          break;
          
        case "f":
          PShapeExt face = new PShapeExt();
          face.uvs = new ArrayList<PVector>();
          
          face.pshape = createShape();
          face.pshape.beginShape();
          face.pshape.noStroke();
          for (int i = 1; i < words.length; i++)
          {
            String[] vertexComponentsIndices = words[i].split("/");
            
            int vertexIndex = Integer.parseInt(vertexComponentsIndices[0]);
            int uvIndex = Integer.parseInt(vertexComponentsIndices[1]);
            
            face.pshape.vertex(vertices.get(vertexIndex).x, vertices.get(vertexIndex).y, vertices.get(vertexIndex).z, uvs.get(uvIndex).x, uvs.get(uvIndex).y);
            face.uvs.add(new PVector(uvs.get(uvIndex).x, uvs.get(uvIndex).y));
          }
          face.pshape.texture(material.getTexture());
          face.pshape.endShape();
          faces.add(face);
          break;
      }
    }
  }
  
  @Override public String getName()
  {
    return name;
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
  
  @Override public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  @Override public void setRotation(PVector _rotation)
  {
    rotation = _rotation;
  }
  
  @Override public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  @Override public void render()
  {
    pushMatrix();
    
    translate(translation.x, translation.y, translation.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    
    for (PShapeExt face : faces)
    {
      shape(face.pshape);
    }
    
    popMatrix();
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonModel = new JSONObject();
    
    jsonModel.setString("name", name);
    
    JSONArray jsonFaces = new JSONArray();
    for (PShapeExt face : faces)
    {
      JSONArray jsonFace = new JSONArray();
      for (int i = 0; i < face.pshape.getVertexCount(); i++)
      {
        PVector vertex = face.pshape.getVertex(i);
        JSONObject jsonVertex = new JSONObject();
        jsonVertex.setFloat("x", vertex.x);
        jsonVertex.setFloat("y", vertex.y);
        jsonVertex.setFloat("z", vertex.z);
        jsonVertex.setFloat("u", face.uvs.get(i).x);
        jsonVertex.setFloat("v", face.uvs.get(i).y);
        jsonFace.append(jsonVertex);
      }
      jsonFaces.append(jsonFace);
    }
    jsonModel.setJSONArray("faces", jsonFaces);
    
    jsonModel.setJSONObject("material", material.serialize());
    
    return jsonModel;
  }
  
  @Override public void deserialize(JSONObject jsonModel)
  {
    name = jsonModel.getString("name");
    
    material = new Material(jsonModel.getJSONObject("material"));
    
    faces = new ArrayList<PShapeExt>();
    JSONArray jsonFaces = jsonModel.getJSONArray("faces");
    for (int i = 0; i < jsonFaces.size(); i++)
    {
      PShapeExt face = new PShapeExt();
      face.uvs = new ArrayList<PVector>();
      
      face.pshape = createShape();
      face.pshape.beginShape();
      face.pshape.noStroke();
      
      JSONArray jsonFace = jsonFaces.getJSONArray(i);
      for (int j = 0; j < jsonFace.size(); j++)
      {
        PVector uv = new PVector();
        
        JSONObject jsonVertex = jsonFace.getJSONObject(j);
        uv.x = jsonVertex.getFloat("u");
        uv.y = jsonVertex.getFloat("v");
        face.pshape.vertex(jsonVertex.getFloat("x"), jsonVertex.getFloat("y"), jsonVertex.getFloat("z"), uv.x, uv.y);
        face.uvs.add(uv);
      }
      
      face.pshape.texture(material.getTexture());
      face.pshape.endShape();
      
      faces.add(face);
    }
  }
}


public class Scene implements IScene
{
  private IOrthographicCamera orthographicCamera;
  private IPerspectiveCamera perspectiveCamera;
  private HashMap<String, ISprite> sprites;
  private HashMap<String, IModel> models;
  
  public Scene()
  {
    orthographicCamera = new OrthographicCamera();
    perspectiveCamera = new PerspectiveCamera();
    sprites = new HashMap<String, ISprite>();
    models = new HashMap<String, IModel>();
  }
  
  @Override public IOrthographicCamera getOrthographicCamera()
  {
    return orthographicCamera;
  }
  
  @Override public void setOrthographicCamera(IOrthographicCamera _orthographicCamera)
  {
    orthographicCamera = _orthographicCamera;
  }
  
  @Override public IPerspectiveCamera getPerspectiveCamera()
  {
    return perspectiveCamera;
  }
  
  @Override public void setPerspectiveCamera(IPerspectiveCamera _perspectiveCamera)
  {
    perspectiveCamera = _perspectiveCamera;
  }
  
  @Override public void addSprite(ISprite sprite)
  {
    sprites.put(sprite.getName(), sprite);
  }
  
  @Override public ISprite getSprite(String name)
  {
    return sprites.get(name);
  }
  
  @Override public void removeSprite(String name)
  {
    sprites.remove(name);
  }
  
  @Override public void addModel(IModel model)
  {
    models.put(model.getName(), model);
  }
  
  @Override public IModel getModel(String name)
  {
    return models.get(name);
  }
  
  @Override public void removeModel(String name)
  {
    models.remove(name);
  }
  
  @Override public void render()
  {
    orthographicCamera.apply();
    
    for (Map.Entry entry : sprites.entrySet())
    {
      ((ISprite)entry.getValue()).render();
    }
    
    perspectiveCamera.apply();
    
    for (Map.Entry entry : models.entrySet())
    {
      ((IModel)entry.getValue()).render();
    }
  }
}
//======================================================================================================
// Author: David Hanna
//
// A collection of PImages used for texturing objects in the game world. Ensures once-only loading times.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface ITextureManager
{
  public PImage getTexture(String name);
}


//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public class TextureManager implements ITextureManager
{
  private HashMap<String, PImage> textures;
  
  public TextureManager()
  {
    textures = new HashMap<String, PImage>();
  }
  
  @Override public PImage getTexture(String name)
  {
    if (!textures.containsKey(name))
    {
      textures.put(name, loadImage(name));
    }
    return textures.get(name);
  }
}
  public void settings() {  size(800, 600, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MultiScreenGameEngine" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
