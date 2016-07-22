import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.ArrayList; 
import java.util.LinkedList; 
import java.util.Map; 
import processing.net.Client; 
import processing.net.Server; 
import com.google.flatbuffers.FlatBufferBuilder; 
import java.nio.ByteBuffer; 
import msge.std.*; 
import java.awt.Robot; 
import java.awt.AWTException; 
import java.awt.MouseInfo; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.contacts.Contact; 
import org.jbox2d.collision.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.callbacks.ContactListener; 
import org.jbox2d.callbacks.ContactImpulse; 

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
Vec2 gravity;
World physicsWorld;
PhysicsContactListener contactListener;
int velocityIterations;    // Fewer iterations increases performance but accuracy suffers.
int positionIterations;    // More iterations decreases performance but improves accuracy.
                           // Box2D recommends 8 for velocity and 3 for position.
IMaterialManager materialManager;
ISpriteManager spriteManager;
IModelManager modelManager;
IFontManager fontManager;
IScene scene;
IGameStateController gameStateController;

int lastFrameTime;

public void setup()
{
  
  surface.setResizable(true);
  
  mainObject = this;
  eventManager = new EventManager();
  gravity = new Vec2(0.0f, 10.0f);
  physicsWorld = new World(gravity); // gravity
  contactListener = new PhysicsContactListener();
  physicsWorld.setContactListener(contactListener);
  velocityIterations = 3;  // Our simple games probably don't need as much iteration.
  positionIterations = 1;
  materialManager = new MaterialManager();
  spriteManager = new SpriteManager();
  modelManager = new ModelManager();
  fontManager = new FontManager();
  scene = new Scene();
  gameStateController = new GameStateController();
  
  spriteManager.loadAllSprites();
  //modelManager.loadAllModels();
  gameStateController.pushState(new GameState_ChooseClientServerState());
  
  lastFrameTime = millis();
}

public void draw()
{
  background(200);
  
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  //if (deltaTime > 100)
  //{
  //  deltaTime = 32;
  //}
  //println(deltaTime);
  
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

public void keyPressed()
{
  Event event;
  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case UP:
        event = new Event(EventType.UP_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case LEFT:
        event = new Event(EventType.LEFT_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case RIGHT:
        event = new Event(EventType.RIGHT_BUTTON_PRESSED);
        eventManager.queueEvent(event); 
        return;
      case DOWN:
        event = new Event(EventType.DOWN_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
    }
  }
  else
  {
    switch (key)
    {
      case 'w':
        event = new Event(EventType.W_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case 'a':
        event = new Event(EventType.A_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case 's':
        event = new Event(EventType.S_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case 'd':
        event = new Event(EventType.D_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
    }
  }
}

public void keyReleased()
{
  Event event;
  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case UP:
        event = new Event(EventType.UP_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case LEFT:
        event = new Event(EventType.LEFT_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case RIGHT:
        event = new Event(EventType.RIGHT_BUTTON_RELEASED);
        eventManager.queueEvent(event); 
        return;
      case DOWN:
        event = new Event(EventType.DOWN_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
    }
  }
  else
  {
    switch (key)
    {
      case 'w':
        event = new Event(EventType.W_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case 'a':
        event = new Event(EventType.A_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case 's':
        event = new Event(EventType.S_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case 'd':
        event = new Event(EventType.D_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
    }
  }
}

class PhysicsContactListener implements ContactListener
{
  @Override public void beginContact(Contact contact)
  {
    IGameObject objectA = (IGameObject)contact.getFixtureA().getUserData();
    IGameObject objectB = (IGameObject)contact.getFixtureB().getUserData();
    
    RigidBodyComponent rigidBodyA = (RigidBodyComponent)objectA.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyB = (RigidBodyComponent)objectB.getComponent(ComponentType.RIGID_BODY);
    
    rigidBodyA.onCollisionEnter(objectB);
    rigidBodyB.onCollisionEnter(objectA);
  }
  
  @Override public void endContact(Contact contact)
  {
  }
  
  @Override public void preSolve(Contact contact, Manifold oldManifold)
  {
  }
  
  @Override public void postSolve(Contact contact, ContactImpulse impulse)
  {
  }
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
  // GENERAL
  RENDER,               // server/client
  RIGID_BODY,           // server
  PERSPECTIVE_CAMERA,   // client
  ORTHOGRAPHIC_CAMERA,  // client
  
  // BOX EXAMPLE
  TRANSLATE_OVER_TIME,  // server/client(testing only)
  ROTATE_OVER_TIME,     // server/client(testing only)
  SCALE_OVER_TIME,      // server/client(testing only)
  
  // PONG
  CLIENT_PADDLE_CONTROLLER,    // client
  SERVER_PADDLE_CONTROLLER,    // server
  BALL_CONTROLLER,      // server
  GOAL_LISTENER,        // server
}

public interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
  public String          toString();
}

public interface INetworkComponent extends IComponent
{
  public int             serialize(FlatBufferBuilder builder);
  public void            deserialize(com.google.flatbuffers.Table componentTable);
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
      
    case RIGID_BODY:
      return "rigidBody";
       
    case PERSPECTIVE_CAMERA:
      return "perspectiveCamera";
      
    case ORTHOGRAPHIC_CAMERA:
      return "orthographicCamera";
      
    case TRANSLATE_OVER_TIME:
      return "translateOverTime";
      
    case ROTATE_OVER_TIME:
      return "rotateOverTime";
      
    case SCALE_OVER_TIME:
      return "scaleOverTime";
      
    case CLIENT_PADDLE_CONTROLLER:
      return "clientPaddleController";
      
    case SERVER_PADDLE_CONTROLLER:
      return "serverPaddleController";
      
    case BALL_CONTROLLER:
      return "ballController";
      
    case GOAL_LISTENER:
      return "goalListener";
      
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
      
    case "rigidBody":
      return ComponentType.RIGID_BODY;
      
    case "perspectiveCamera":
      return ComponentType.PERSPECTIVE_CAMERA;
      
    case "orthographicCamera":
      return ComponentType.ORTHOGRAPHIC_CAMERA;
      
    case "translateOverTime":
      return ComponentType.TRANSLATE_OVER_TIME;
      
    case "rotateOverTime":
      return ComponentType.ROTATE_OVER_TIME;
      
    case "scaleOverTime":
      return ComponentType.SCALE_OVER_TIME;
    
    case "clientPaddleController":
      return ComponentType.CLIENT_PADDLE_CONTROLLER;
      
    case "serverPaddleController":
      return ComponentType.SERVER_PADDLE_CONTROLLER;
      
    case "ballController":
      return ComponentType.BALL_CONTROLLER;
      
    case "goalListener":
      return ComponentType.GOAL_LISTENER;
      
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


public abstract class NetworkComponent extends Component implements INetworkComponent
{
  public NetworkComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
}


public class RenderComponent extends NetworkComponent
{
  ArrayList<Integer> spriteHandles;
  ArrayList<PVector> spriteTranslationOffsets;
  ArrayList<PVector> spriteRotationOffsets;
  ArrayList<PVector> spriteScaleOffsets;
  
  ArrayList<Integer> modelHandles;
  ArrayList<PVector> modelTranslationOffsets;
  ArrayList<PVector> modelRotationOffsets;
  ArrayList<PVector> modelScaleOffsets;
  
  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    spriteHandles = new ArrayList<Integer>();
    spriteTranslationOffsets = new ArrayList<PVector>();
    spriteRotationOffsets = new ArrayList<PVector>();
    spriteScaleOffsets = new ArrayList<PVector>();
    
    modelHandles = new ArrayList<Integer>();
    modelTranslationOffsets = new ArrayList<PVector>();
    modelRotationOffsets = new ArrayList<PVector>();
    modelScaleOffsets = new ArrayList<PVector>();
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
    spriteTranslationOffsets.clear();
    spriteRotationOffsets.clear();
    spriteScaleOffsets.clear();
    
    modelHandles.clear();
    modelTranslationOffsets.clear();
    modelRotationOffsets.clear();
    modelScaleOffsets.clear();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlSubComponent : xmlComponent.getChildren())
    {
      if (xmlSubComponent.getName().equals("Sprite"))
      {
        ISpriteInstance sprite = new SpriteInstance(xmlSubComponent.getString("name"));
        
        XML xmlTranslationOffset = xmlSubComponent.getChild("Translation");
        spriteTranslationOffsets.add(new PVector(xmlTranslationOffset.getFloat("x"), xmlTranslationOffset.getFloat("y"), xmlTranslationOffset.getFloat("z")));
        
        XML xmlRotationOffset = xmlSubComponent.getChild("Rotation");
        spriteRotationOffsets.add(new PVector(xmlRotationOffset.getFloat("x"), xmlRotationOffset.getFloat("y"), xmlRotationOffset.getFloat("z")));
        
        XML xmlScaleOffset = xmlSubComponent.getChild("Scale");
        spriteScaleOffsets.add(new PVector(xmlScaleOffset.getFloat("x"), xmlScaleOffset.getFloat("y"), xmlScaleOffset.getFloat("z")));
        
        XML xmlTint = xmlSubComponent.getChild("Tint");
        sprite.setTint(new PVector(xmlTint.getFloat("r"), xmlTint.getFloat("g"), xmlTint.getFloat("b")));
        sprite.setAlpha(xmlTint.getFloat("a"));
        
        spriteHandles.add(scene.addSpriteInstance(sprite));
      }
      else if (xmlSubComponent.getName().equals("Model"))
      {
        IModelInstance modelInstance = new ModelInstance(xmlSubComponent.getString("name"));
        
        XML xmlTranslationOffset = xmlSubComponent.getChild("Translation");
        modelTranslationOffsets.add(new PVector(xmlTranslationOffset.getFloat("x"), xmlTranslationOffset.getFloat("y"), xmlTranslationOffset.getFloat("z")));
        
        XML xmlRotationOffset = xmlSubComponent.getChild("Rotation");
        modelRotationOffsets.add(new PVector(xmlRotationOffset.getFloat("x"), xmlRotationOffset.getFloat("y"), xmlRotationOffset.getFloat("z")));
        
        XML xmlScaleOffset = xmlSubComponent.getChild("Scale");
        modelScaleOffsets.add(new PVector(xmlScaleOffset.getFloat("x"), xmlScaleOffset.getFloat("y"), xmlScaleOffset.getFloat("z")));
        
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
    
    FlatRenderComponent.startSpriteTranslationOffsetsVector(builder, spriteTranslationOffsets.size());
    for (int i = 0; i < spriteTranslationOffsets.size(); i++)
    {
      PVector translation = spriteTranslationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z);
    }
    int flatSpriteTranslationOffsets = builder.endVector();
    
    FlatRenderComponent.startSpriteRotationOffsetsVector(builder, spriteRotationOffsets.size());
    for (int i = 0; i < spriteRotationOffsets.size(); i++)
    {
      PVector rotation = spriteRotationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z);
    }
    int flatSpriteRotationOffsets = builder.endVector();
    
    FlatRenderComponent.startSpriteScaleOffsetsVector(builder, spriteScaleOffsets.size());
    for (int i = 0; i < spriteScaleOffsets.size(); i++)
    {
      PVector scale = spriteScaleOffsets.get(i);
      FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z);
    }
    int flatSpriteScaleOffsets = builder.endVector();
    
    int[] flatModels = new int[modelHandles.size()];
    for (int i = 0; i < modelHandles.size(); i++)
    {
      flatModels[i] = scene.getModelInstance(modelHandles.get(i)).serialize(builder);
    }
    int flatModelsVector = FlatRenderComponent.createModelsVector(builder, flatModels);
    
    FlatRenderComponent.startModelTranslationOffsetsVector(builder, modelTranslationOffsets.size());
    for (int i = 0; i < modelTranslationOffsets.size(); i++)
    {
      PVector translation = modelTranslationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z);
    }
    int flatModelTranslationOffsets = builder.endVector();
    
    FlatRenderComponent.startModelRotationOffsetsVector(builder, modelRotationOffsets.size());
    for (int i = 0; i < modelRotationOffsets.size(); i++)
    {
      PVector rotation = modelRotationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z);
    }
    int flatModelRotationOffsets = builder.endVector();
    
    FlatRenderComponent.startModelScaleOffsetsVector(builder, modelScaleOffsets.size());
    for (int i = 0; i < modelScaleOffsets.size(); i++)
    {
      PVector scale = modelScaleOffsets.get(i);
      FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z);
    }
    int flatModelScaleOffsets = builder.endVector();
    
    FlatRenderComponent.startFlatRenderComponent(builder);
    
    FlatRenderComponent.addSprites(builder, flatSpritesVector);
    FlatRenderComponent.addSpriteTranslationOffsets(builder, flatSpriteTranslationOffsets);
    FlatRenderComponent.addSpriteRotationOffsets(builder, flatSpriteRotationOffsets);
    FlatRenderComponent.addSpriteScaleOffsets(builder, flatSpriteScaleOffsets);
    
    FlatRenderComponent.addModels(builder, flatModelsVector);
    FlatRenderComponent.addModelTranslationOffsets(builder, flatModelTranslationOffsets);
    FlatRenderComponent.addModelRotationOffsets(builder, flatModelRotationOffsets);
    FlatRenderComponent.addModelScaleOffsets(builder, flatModelScaleOffsets);
    
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
    
    for (int i = 0; i < flatRenderComponent.spriteTranslationOffsetsLength(); i++)
    {
      FlatVec3 flatSpriteTranslationOffset = flatRenderComponent.spriteTranslationOffsets(i);
      spriteTranslationOffsets.add(new PVector(flatSpriteTranslationOffset.x(), flatSpriteTranslationOffset.y(), flatSpriteTranslationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.spriteRotationOffsetsLength(); i++)
    {
      FlatVec3 flatSpriteRotationOffset = flatRenderComponent.spriteRotationOffsets(i);
      spriteRotationOffsets.add(new PVector(flatSpriteRotationOffset.x(), flatSpriteRotationOffset.y(), flatSpriteRotationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.spriteScaleOffsetsLength(); i++)
    {
      FlatVec3 flatSpriteScaleOffset = flatRenderComponent.spriteScaleOffsets(i);
      spriteScaleOffsets.add(new PVector(flatSpriteScaleOffset.x(), flatSpriteScaleOffset.y(), flatSpriteScaleOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.modelsLength(); i++)
    {
      FlatModel flatModel = flatRenderComponent.models(i);
      IModelInstance modelInstance = new ModelInstance(flatModel.modelName());
      modelInstance.deserialize(flatModel);
      modelHandles.add(scene.addModelInstance(modelInstance));
    }
    
    for (int i = 0; i < flatRenderComponent.modelTranslationOffsetsLength(); i++)
    {
      FlatVec3 flatModelTranslationOffset = flatRenderComponent.modelTranslationOffsets(i);
      modelTranslationOffsets.add(new PVector(flatModelTranslationOffset.x(), flatModelTranslationOffset.y(), flatModelTranslationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.modelRotationOffsetsLength(); i++)
    {
      FlatVec3 flatModelRotationOffset = flatRenderComponent.modelRotationOffsets(i);
      modelRotationOffsets.add(new PVector(flatModelRotationOffset.x(), flatModelRotationOffset.y(), flatModelRotationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.modelScaleOffsetsLength(); i++)
    {
      FlatVec3 flatModelScaleOffset = flatRenderComponent.modelScaleOffsets(i);
      modelScaleOffsets.add(new PVector(flatModelScaleOffset.x(), flatModelScaleOffset.y(), flatModelScaleOffset.z()));
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (int i = 0; i < spriteHandles.size(); i++)
    {
      ISpriteInstance spriteInstance = scene.getSpriteInstance(spriteHandles.get(i));
      
      PVector translation = gameObject.getTranslation();
      PVector translationOffset = spriteTranslationOffsets.get(i);
      PVector adjustedTranslation = new PVector(translation.x + translationOffset.x, translation.y + translationOffset.y, translation.z + translationOffset.z);
      spriteInstance.setTranslation(adjustedTranslation);
      
      PVector rotation = gameObject.getRotation();
      PVector rotationOffset = spriteRotationOffsets.get(i);
      PVector adjustedRotation = new PVector(rotation.x + rotationOffset.x, rotation.y + rotationOffset.y, rotation.z + rotationOffset.z);
      spriteInstance.setRotation(adjustedRotation);
      
      PVector scale = gameObject.getScale();
      PVector scaleOffset = spriteScaleOffsets.get(i);
      PVector adjustedScale = new PVector(scale.x * scaleOffset.x, scale.y * scaleOffset.y, scale.z * scaleOffset.z);
      spriteInstance.setScale(adjustedScale);
    }
    
    for (int i = 0; i < modelHandles.size(); i++)
    {
      IModelInstance modelInstance = scene.getModelInstance(modelHandles.get(i));
      
      PVector translation = gameObject.getTranslation();
      PVector translationOffset = modelTranslationOffsets.get(i);
      PVector adjustedTranslation = new PVector(translation.x + translationOffset.x, translation.y + translationOffset.y, translation.z + translationOffset.z);
      modelInstance.setTranslation(adjustedTranslation);
      
      PVector rotation = gameObject.getRotation();
      PVector rotationOffset = modelRotationOffsets.get(i);
      PVector adjustedRotation = new PVector(rotation.x + rotationOffset.x, rotation.y + rotationOffset.y, rotation.z + rotationOffset.z);
      modelInstance.setRotation(adjustedRotation);
      
      PVector scale = gameObject.getScale();
      PVector scaleOffset = modelScaleOffsets.get(i);
      PVector adjustedScale = new PVector(scale.x * scaleOffset.x, scale.y * scaleOffset.y, scale.z * scaleOffset.z);
      modelInstance.setScale(adjustedScale);
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
  
  public ArrayList<Integer> getSpriteHandles()
  {
    return spriteHandles;
  }
  
  public ArrayList<Integer> getModelHandles()
  {
    return modelHandles;
  }
}


public class RigidBodyComponent extends Component
{
  private class OnCollideEvent
  {
    public String collidedWith; 
    public EventType eventType; 
    public HashMap<String, String> eventParameters;
  } 
   
  private Body body; 
  public PVector latestForce; 
  private ArrayList<OnCollideEvent> onCollideEvents; 
 
  public RigidBodyComponent(IGameObject _gameObject) 
  { 
    super(_gameObject); 
 
    latestForce = new PVector(); 
    onCollideEvents = new ArrayList<OnCollideEvent>(); 
  } 
 
  @Override public void destroy() 
  { 
    physicsWorld.destroyBody(body); 
  }  
  
  @Override public void fromXML(XML xmlComponent)  
  {  
    BodyDef bodyDefinition = new BodyDef();
  
    String bodyType = xmlComponent.getString("type");  
    if (bodyType.equals("static")) 
    { 
      bodyDefinition.type = BodyType.STATIC;
    }  
    else if (bodyType.equals("kinematic"))  
    {  
      bodyDefinition.type = BodyType.KINEMATIC;  
    }  
    else if (bodyType.equals("dynamic"))  
    {  
      bodyDefinition.type = BodyType.DYNAMIC; 
    } 
    else  
    {
      print("Unknown rigid body type: " + bodyType);  
      assert(false);  
    }  
  
    bodyDefinition.position.set(pixelsToMeters(gameObject.getTranslation().x), pixelsToMeters(gameObject.getTranslation().y));  
    bodyDefinition.angle = gameObject.getRotation().z;
    bodyDefinition.linearDamping = xmlComponent.getFloat("linearDamping");  
    bodyDefinition.angularDamping = xmlComponent.getFloat("angularDamping");  
    bodyDefinition.gravityScale = xmlComponent.getFloat("gravityScale");  
    bodyDefinition.allowSleep = xmlComponent.getString("allowSleep").equals("true") ? true : false;  
    bodyDefinition.awake = xmlComponent.getString("awake").equals("true") ? true : false;  
    bodyDefinition.fixedRotation = xmlComponent.getString("fixedRotation").equals("true") ? true : false;  
    bodyDefinition.bullet = xmlComponent.getString("bullet").equals("true") ? true : false;  
    bodyDefinition.active = xmlComponent.getString("active").equals("true") ? true : false;  
    bodyDefinition.userData = gameObject;
    
 
    body = physicsWorld.createBody(bodyDefinition); 

    for (XML rigidBodyComponent : xmlComponent.getChildren())
    { 
      if (rigidBodyComponent.getName().equals("Fixture")) 
      {
        FixtureDef fixtureDef = new FixtureDef(); 
        fixtureDef.density = rigidBodyComponent.getFloat("density"); 
        fixtureDef.friction = rigidBodyComponent.getFloat("friction");
        fixtureDef.restitution = rigidBodyComponent.getFloat("restitution");
        fixtureDef.isSensor = rigidBodyComponent.getString("isSensor").equals("true") ? true : false;
        fixtureDef.filter.categoryBits = rigidBodyComponent.getInt("categoryBits");
        fixtureDef.filter.maskBits = rigidBodyComponent.getInt("maskBits");
        fixtureDef.userData = gameObject;

        for (XML xmlShape : rigidBodyComponent.getChildren()) 
        {  
          if (xmlShape.getName().equals("Shape"))  
          {  
            String shapeType = xmlShape.getString("type");  
  
            if (shapeType.equals("circle")) 
            { 
              CircleShape circleShape = new CircleShape(); 
              circleShape.m_p.set(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y")));
              circleShape.m_radius = pixelsToMeters(xmlShape.getFloat("radius")) * gameObject.getScale().x; 
                
              fixtureDef.shape = circleShape; 
            } 
            else if (shapeType.equals("box"))  
            {  
              PolygonShape boxShape = new PolygonShape();  
              boxShape.m_centroid.set(new Vec2(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y")))); 
              boxShape.setAsBox(
                pixelsToMeters(xmlShape.getFloat("halfWidth")) * gameObject.getScale().x,
                pixelsToMeters(xmlShape.getFloat("halfHeight")) * gameObject.getScale().y
              ); 
 
              fixtureDef.shape = boxShape;
            } 
            else 
            {
              print("Unknown fixture shape type: " + shapeType);
              assert(false);
            }
          }
        }
         
        body.createFixture(fixtureDef); 
      } 
      else if (rigidBodyComponent.getName().equals("OnCollideEvents")) 
      { 
        for (XML xmlOnCollideEvent : rigidBodyComponent.getChildren()) 
        { 
          if (xmlOnCollideEvent.getName().equals("Event")) 
          {
            OnCollideEvent onCollideEvent = new OnCollideEvent();
            onCollideEvent.collidedWith = xmlOnCollideEvent.getString("collidedWith"); 
             
            String stringEventType = xmlOnCollideEvent.getString("eventType"); 
            if (stringEventType.equals("GOAL_SCORED"))  
            {
              onCollideEvent.eventType = EventType.GOAL_SCORED; 
              onCollideEvent.eventParameters = new HashMap<String, String>(); 
              onCollideEvent.eventParameters.put("ballParameterName", xmlOnCollideEvent.getString("ballParameterName"));
            }
            else if (stringEventType.equals("BALL_PLAYER_COLLISION"))
            {
              onCollideEvent.eventType = EventType.BALL_PLAYER_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("clientIDParameterName", xmlOnCollideEvent.getString("clientIDParameterName"));
              onCollideEvent.eventParameters.put("rParameterName", xmlOnCollideEvent.getString("rParameterName"));
              onCollideEvent.eventParameters.put("gParameterName", xmlOnCollideEvent.getString("gParameterName"));
              onCollideEvent.eventParameters.put("bParameterName", xmlOnCollideEvent.getString("bParameterName"));
            }
            //else if (stringEventType.equals("GAME_OVER"))
            //{
            //  onCollideEvent.eventType = EventType.GAME_OVER;
            //}
            //else if (stringEventType.equals("DESTROY_COIN"))
            //{
            //  onCollideEvent.eventType = EventType.DESTROY_COIN;
            //  onCollideEvent.eventParameters = new HashMap<String, String>();
            //  onCollideEvent.eventParameters.put("coinParameterName", xmlOnCollideEvent.getString("coinParameterName"));
            //}
            //else if (stringEventType.equals("PLAYER_PLATFORM_COLLISION"))
            //{
            //  onCollideEvent.eventType = EventType.PLAYER_PLATFORM_COLLISION;
            //  onCollideEvent.eventParameters = new HashMap<String, String>();
            //  onCollideEvent.eventParameters.put("platformParameterName", xmlOnCollideEvent.getString("platformParameterName"));
            //}
            
            onCollideEvents.add(onCollideEvent); 
          }  
        }  
      }  
    }  
  }
    
  @Override public ComponentType getComponentType() 
  {
    return ComponentType.RIGID_BODY;
  } 
    
  @Override public void update(int deltaTime)  
  {  
    // Reverse sync the physically simulated position to the Game Object position.  
    gameObject.setTranslation(new PVector(metersToPixels(body.getPosition().x), metersToPixels(body.getPosition().y)));  
  }
 
  public void onCollisionEnter(IGameObject collider)
  {
    for (OnCollideEvent onCollideEvent : onCollideEvents)
    {
      if (onCollideEvent.collidedWith.equals(collider.getTag()))  
      {
        if (onCollideEvent.eventType == EventType.GOAL_SCORED)  
        {
          Event event = new Event(EventType.GOAL_SCORED);  
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("ballParameterName"), collider);  
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.BALL_PLAYER_COLLISION)
        {
          Event event = new Event(EventType.BALL_PLAYER_COLLISION);
          
          IComponent component = collider.getComponent(ComponentType.SERVER_PADDLE_CONTROLLER);
          if (component != null)
          {
            ServerPaddleControllerComponent serverPaddleController = (ServerPaddleControllerComponent)component;
            
            event.addIntParameter(onCollideEvent.eventParameters.get("clientIDParameterName"), serverPaddleController.getClientID());
            
            PVector paddleColor = serverPaddleController.getPaddleColor();
            event.addFloatParameter(onCollideEvent.eventParameters.get("rParameterName"), paddleColor.x);
            event.addFloatParameter(onCollideEvent.eventParameters.get("gParameterName"), paddleColor.y);
            event.addFloatParameter(onCollideEvent.eventParameters.get("bParameterName"), paddleColor.z);
          }
          
          eventManager.queueEvent(event);
        }
        //else if (onCollideEvent.eventType == EventType.GAME_OVER)  
        //{  
        //  eventManager.queueEvent(new Event(EventType.GAME_OVER));  
        //}  
        //else if (onCollideEvent.eventType == EventType.DESTROY_COIN)  
        //{   
        //  Event event = new Event(EventType.DESTROY_COIN);  
        //  event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);  
        //  eventManager.queueEvent(event);  
  
        //} 
        //else if (onCollideEvent.eventType == EventType.PLAYER_PLATFORM_COLLISION) 
        //{  
        //  Event event = new Event(EventType.PLAYER_PLATFORM_COLLISION);  
        //  event.addGameObjectParameter(onCollideEvent.eventParameters.get("platformParameterName"), collider);  
        //  eventManager.queueEvent(event);  
        //}  
      }  
    } 
  }
  
  public PVector getLinearVelocity() 
  {
    return new PVector(metersToPixels(body.getLinearVelocity().x), metersToPixels(body.getLinearVelocity().y)); 
  } 

  public float getSpeed()
  {
    PVector linearVelocity = getLinearVelocity(); 
    return sqrt((linearVelocity.x * linearVelocity.x) + (linearVelocity.y * linearVelocity.y)); 
  }
  
  public PVector getAcceleration() 
  { 
    return new PVector(metersToPixels(latestForce.x), metersToPixels(latestForce.y));  
  }
  
  public void setPosition(PVector position)
  {
    body.setTransform(new Vec2(position.x, position.y), body.getAngle());
  }
  
  public void setLinearVelocity(PVector linearVelocity)  
  {  
    body.setLinearVelocity(new Vec2(pixelsToMeters(linearVelocity.x), pixelsToMeters(linearVelocity.y)));  
  }  
    
  public void applyForce(PVector force, PVector position)  
  {  
    latestForce = force;  
    body.applyForce(new Vec2(pixelsToMeters(force.x), pixelsToMeters(force.y)), new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)));  
  }  
  
  public void applyLinearImpulse(PVector impulse, PVector position, boolean wakeUp)  
  {  
    body.applyLinearImpulse( 
      new Vec2(pixelsToMeters(impulse.x), pixelsToMeters(impulse.y)),
      new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)), 
      wakeUp 
    );
  }
 
  private float pixelsToMeters(float pixels) 
  {  
    return pixels / 50.0f;  
  }

  private float metersToPixels(float meters)
  { 
    return meters * 50.0f;  
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
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PERSPECTIVE_CAMERA;
  }
  
  @Override public void update(int deltaTime)
  {
  }
}

public class OrthographicCameraComponent extends Component
{
  private IOrthographicCamera camera;
  
  public OrthographicCameraComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    camera = new OrthographicCamera();
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
      else if (xmlParameter.getName().equals("Left"))
      {
        camera.setLeft(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Right"))
      {
        camera.setRight(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Bottom"))
      {
        camera.setBottom(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Top"))
      {
        camera.setTop(xmlParameter.getFloat("value"));
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
    
    scene.setOrthographicCamera(camera);
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ORTHOGRAPHIC_CAMERA;
  }
  
  @Override public void update(int deltaTime)
  {
  }
}

public class TranslateOverTimeComponent extends NetworkComponent
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


public class RotateOverTimeComponent extends NetworkComponent
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


public class ScaleOverTimeComponent extends NetworkComponent
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


public class ClientPaddleControllerComponent extends Component
{
  public int clientID;
  
  public boolean leftButtonDown;
  public boolean rightButtonDown;
  public boolean upButtonDown;
  public boolean downButtonDown;
  
  public boolean wButtonDown;
  public boolean aButtonDown;
  public boolean sButtonDown;
  public boolean dButtonDown;
  
  public ClientPaddleControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    clientID = -1;
    
    leftButtonDown = false;
    rightButtonDown = false;
    upButtonDown = false;
    downButtonDown = false;
    
    wButtonDown = false;
    aButtonDown = false;
    sButtonDown = false;
    dButtonDown = false;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.CLIENT_PADDLE_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if (clientID == -1)
    {
      for (IEvent event : eventManager.getEvents(EventType.CLIENT_ID_SET))
      {
        clientID = event.getRequiredIntParameter("clientID");
      }
    }
    else
    {    
      if (eventManager.getEvents(EventType.LEFT_BUTTON_PRESSED).size() > 0)
      {
        leftButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.RIGHT_BUTTON_PRESSED).size() > 0)
      {
        rightButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.UP_BUTTON_PRESSED).size() > 0)
      {
        upButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.DOWN_BUTTON_PRESSED).size() > 0)
      {
        downButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.W_BUTTON_PRESSED).size() > 0)
      {
        wButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.A_BUTTON_PRESSED).size() > 0)
      {
        aButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.S_BUTTON_PRESSED).size() > 0)
      {
        sButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.D_BUTTON_PRESSED).size() > 0)
      {
        dButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.LEFT_BUTTON_RELEASED).size() > 0)
      {
        leftButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.RIGHT_BUTTON_RELEASED).size() > 0)
      {
        rightButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.UP_BUTTON_RELEASED).size() > 0)
      {
        upButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.DOWN_BUTTON_RELEASED).size() > 0)
      {
        downButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.W_BUTTON_RELEASED).size() > 0)
      {
        wButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.A_BUTTON_RELEASED).size() > 0)
      {
        aButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.S_BUTTON_RELEASED).size() > 0)
      {
        sButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.D_BUTTON_RELEASED).size() > 0)
      {
        dButtonDown = false;
      }
      
      if (mainClient != null && mainClient.isConnected())
      {
        FlatBufferBuilder builder = new FlatBufferBuilder(0);
        
        FlatPaddleControllerState.startFlatPaddleControllerState(builder);
        FlatPaddleControllerState.addLeftButtonDown(builder, leftButtonDown);
        FlatPaddleControllerState.addRightButtonDown(builder, rightButtonDown);
        FlatPaddleControllerState.addUpButtonDown(builder, upButtonDown);
        FlatPaddleControllerState.addDownButtonDown(builder, downButtonDown);
        FlatPaddleControllerState.addWButtonDown(builder, wButtonDown);
        FlatPaddleControllerState.addAButtonDown(builder, aButtonDown);
        FlatPaddleControllerState.addSButtonDown(builder, sButtonDown);
        FlatPaddleControllerState.addDButtonDown(builder, dButtonDown);
        int flatPaddleControllerStateOffset = FlatPaddleControllerState.endFlatPaddleControllerState(builder);
        
        FlatMessageHeader.startFlatMessageHeader(builder);
        FlatMessageHeader.addTimeStamp(builder, System.currentTimeMillis());
        FlatMessageHeader.addClientID(builder, clientID);
        int flatMessageHeader = FlatMessageHeader.endFlatMessageHeader(builder);
        
        FlatMessageBodyTable.startFlatMessageBodyTable(builder);
        FlatMessageBodyTable.addBodyType(builder, FlatMessageBodyUnion.FlatPaddleControllerState);
        FlatMessageBodyTable.addBody(builder, flatPaddleControllerStateOffset);
        int flatMessageBodyTable = FlatMessageBodyTable.endFlatMessageBodyTable(builder);
        
        FlatMessage.startFlatMessage(builder);
        FlatMessage.addHeader(builder, flatMessageHeader);
        FlatMessage.addBodyTable(builder, flatMessageBodyTable);
        FlatMessage.finishFlatMessageBuffer(builder, FlatMessage.endFlatMessage(builder));
        
        mainClient.write(builder.dataBuffer());
      }
    }
  }
}


public class ServerPaddleControllerComponent extends Component
{
  private int direction;
  private float speed;
  private int clientID;
  private PVector paddleColor;
  
  public ServerPaddleControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    String strDirection = xmlComponent.getString("direction");
    switch (strDirection)
    {
      case "all":
        direction = 0;
        break;
      
      case "vertical":
        direction = 1;
        break;
        
      case "horizontal":
        direction = 2;
        break;
        
      default:
        println("Unrecognized direction: " + strDirection);
        assert(false);
    }
    
    speed = xmlComponent.getFloat("speed");
    clientID = xmlComponent.getInt("clientID");
    paddleColor = new PVector(xmlComponent.getFloat("r"), xmlComponent.getFloat("g"), xmlComponent.getFloat("b"));
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.SERVER_PADDLE_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (IEvent event : eventManager.getEvents(EventType.CLIENT_PADDLE_CONTROLS))
    {
      if (event.getRequiredIntParameter("clientID") == clientID)
      {
        PVector velocity = new PVector(0.0f, 0.0f);
      
        switch (direction)
        {
          case 0:
            if (event.getRequiredBooleanParameter("wButtonDown"))
            {
              velocity.y += 1.0f;
            }
            if (event.getRequiredBooleanParameter("aButtonDown"))
            {
              velocity.x -= 1.0f;
            }
            if (event.getRequiredBooleanParameter("sButtonDown"))
            {
              velocity.y -= 1.0f;
            }
            if (event.getRequiredBooleanParameter("dButtonDown"))
            {
              velocity.x += 1.0f;
            }
            break;
            
          case 1:
            if (event.getRequiredBooleanParameter("upButtonDown"))
            {
              velocity.y += 1.0f;
            }
            if (event.getRequiredBooleanParameter("downButtonDown"))
            {
              velocity.y -= 1.0f;
            }
            break;
            
          case 2:
            if (event.getRequiredBooleanParameter("leftButtonDown"))
            {
              velocity.x -= 1.0f;
            }
            if (event.getRequiredBooleanParameter("rightButtonDown"))
            {
              velocity.x += 1.0f;
            }
            break;
        }
        
        IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
        if (component != null)
        {
          RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
          rigidBodyComponent.setLinearVelocity(velocity.normalize().mult(speed));
        }
      }
    }
  }
  
  public int getClientID()
  {
    return clientID;
  }
  
  public PVector getPaddleColor()
  {
    return paddleColor;
  }
}


public class BallControllerComponent extends Component
{
  private float speed;
  private int waitTime;
  private boolean waiting;
  private int timePassed;
  private int currentClientID;
  private boolean resetNextFrame;
  
  private String clientIDParameterName;
  private String rParameterName;
  private String gParameterName;
  private String bParameterName;
  
  public BallControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    waiting = true;
    timePassed = 0;
    currentClientID = -1;
    resetNextFrame = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    speed = xmlComponent.getFloat("speed");
    waitTime = xmlComponent.getInt("waitTime");
    
    clientIDParameterName = xmlComponent.getString("clientIDParameterName");
    rParameterName = xmlComponent.getString("rParameterName");
    gParameterName = xmlComponent.getString("gParameterName");
    bParameterName = xmlComponent.getString("bParameterName");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.BALL_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if (resetNextFrame)
    {
      reset();
      resetNextFrame = false;
    }
    
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      PVector velocity = rigidBodyComponent.getLinearVelocity();
      
      if (waiting)
      {
        timePassed += deltaTime;
        if (timePassed > waitTime)
        {
          velocity.x = random(-1.0f, 1.0f);
          velocity.y = random(-1.0f, 1.0f);
          
          waiting = false;
        }
      }
      
      rigidBodyComponent.setLinearVelocity(velocity.normalize().mult(speed));
    }
    
    for (IEvent event : eventManager.getEvents(EventType.BALL_PLAYER_COLLISION))
    {
      currentClientID = event.getRequiredIntParameter(clientIDParameterName);
      
      component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        ISpriteInstance spriteInstance = scene.getSpriteInstance(renderComponent.getSpriteHandles().get(0));
        PVector tint = new PVector(
          event.getRequiredFloatParameter(rParameterName), 
          event.getRequiredFloatParameter(gParameterName), 
          event.getRequiredFloatParameter(bParameterName)
        );
        spriteInstance.setTint(tint);
      }
    }
    
    if (eventManager.getEvents(EventType.GOAL_SCORED).size() > 0)
    {
      resetNextFrame = true;
    }
  }
  
  public int getCurrentClientID()
  {
    return currentClientID;
  }
  
  private void reset()
  {
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setPosition(new PVector(0.0f, 0.0f));
      rigidBodyComponent.setLinearVelocity(new PVector(0.0f, 0.0f));
      waiting = true;
      timePassed = 0;
      
      currentClientID = -1;
      
      component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        ISpriteInstance spriteInstance = scene.getSpriteInstance(renderComponent.getSpriteHandles().get(0));
        spriteInstance.setTint(new PVector(255.0f, 255.0f, 255.0f));
      }
    }
  }
}


public class GoalListenerComponent extends Component
{
  private String ballParameterName;
  private int clientID;
  private String scoreFullSpriteName;
  private PVector colorVector;
  private int currentScore;
  
  public GoalListenerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    currentScore = 0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    ballParameterName = xmlComponent.getString("ballParameterName");    
    clientID = xmlComponent.getInt("clientID");
    scoreFullSpriteName = xmlComponent.getString("scoreFullSpriteName");
    colorVector = new PVector(xmlComponent.getFloat("r"), xmlComponent.getFloat("g"), xmlComponent.getFloat("b"));
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.GOAL_LISTENER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (IEvent event : eventManager.getEvents(EventType.GOAL_SCORED))
    {
      IGameObject ball = event.getRequiredGameObjectParameter(ballParameterName);
      IComponent component = ball.getComponent(ComponentType.BALL_CONTROLLER);
      if (component != null)
      {
        BallControllerComponent ballControllerComponent = (BallControllerComponent)component;
        
        if (currentScore < 9 && ballControllerComponent.getCurrentClientID() == clientID)
        {
          component = gameObject.getComponent(ComponentType.RENDER);
          if (component != null)
          {
            RenderComponent renderComponent = (RenderComponent)component;
            
            ArrayList<Integer> spriteHandles = renderComponent.getSpriteHandles();
            scene.removeSpriteInstance(spriteHandles.get(currentScore));
            
            ISpriteInstance scoreFullSprite = new SpriteInstance(scoreFullSpriteName);
            scoreFullSprite.setTint(colorVector);
            scoreFullSprite.setAlpha(255.0f);
            
            spriteHandles.set(currentScore, scene.addSpriteInstance(scoreFullSprite));
            
            currentScore++;
          }
        }
      }
    }
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
      
    case "RigidBody":
      component = new RigidBodyComponent(gameObject);
      break;
      
    case "PerspectiveCamera":
      component = new PerspectiveCameraComponent(gameObject);
      break;
      
    case "OrthographicCamera":
      component = new OrthographicCameraComponent(gameObject);
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
      
    case "ClientPaddleController":
      component = new ClientPaddleControllerComponent(gameObject);
      break;
      
    case "ServerPaddleController":
      component = new ServerPaddleControllerComponent(gameObject);
      break;
      
    case "BallController":
      component = new BallControllerComponent(gameObject);
      break;
      
    case "GoalListener":
      component = new GoalListenerComponent(gameObject);
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
  INetworkComponent component = null;
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
  UP_BUTTON_PRESSED,
  DOWN_BUTTON_PRESSED,
  LEFT_BUTTON_PRESSED,
  RIGHT_BUTTON_PRESSED,
  
  W_BUTTON_PRESSED,
  A_BUTTON_PRESSED,
  S_BUTTON_PRESSED,
  D_BUTTON_PRESSED,
  
  UP_BUTTON_RELEASED,
  DOWN_BUTTON_RELEASED,
  LEFT_BUTTON_RELEASED,
  RIGHT_BUTTON_RELEASED,
  
  W_BUTTON_RELEASED,
  A_BUTTON_RELEASED,
  S_BUTTON_RELEASED,
  D_BUTTON_RELEASED,
  
  CLIENT_ID_SET,
  
  CLIENT_PADDLE_CONTROLS,
  GOAL_SCORED,
  BALL_PLAYER_COLLISION,
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
  public void        addBooleanParameter(String name, boolean value);
  public void        addGameObjectParameter(String name, IGameObject value);
  
  // Use these to get a parameter, but it does not have to have been set by the sender. A default value is required.
  public String      getOptionalStringParameter(String name, String defaultValue);
  public float       getOptionalFloatParameter(String name, float defaultValue);
  public int         getOptionalIntParameter(String name, int defaultValue);
  public boolean     getOptionalBooleanParameter(String name, boolean defaultValue);
  public IGameObject getOptionalGameObjectParameter(String name, IGameObject defaultValue);
  
  // Use these to get a parameter that must have been set by the sender. If the sender did not set it, this is an error
  // and the game will halt.
  public String      getRequiredStringParameter(String name);
  public float       getRequiredFloatParameter(String name);
  public int         getRequiredIntParameter(String name);
  public boolean     getRequiredBooleanParameter(String name);
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
  private HashMap<String, Boolean> booleanParameters;
  private HashMap<String, IGameObject> gameObjectParameters;
  
  public Event(EventType _eventType)
  {
    eventType = _eventType;
    stringParameters = new HashMap<String, String>();
    floatParameters = new HashMap<String, Float>();
    intParameters = new HashMap<String, Integer>();
    booleanParameters = new HashMap<String, Boolean>();
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
  
  @Override public void addBooleanParameter(String name, boolean value)
  {
    booleanParameters.put(name, value);
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
  
  @Override public boolean getOptionalBooleanParameter(String name, boolean defaultValue)
  {
    if (booleanParameters.containsKey(name))
    {
      return booleanParameters.get(name);
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
  
  @Override public boolean getRequiredBooleanParameter(String name)
  {
    assert(booleanParameters.containsKey(name));
    return booleanParameters.get(name);
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
    
    addEventTypeToMaps(EventType.UP_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.DOWN_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_PRESSED);
    
    addEventTypeToMaps(EventType.W_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.A_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.S_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.D_BUTTON_PRESSED);
    
    addEventTypeToMaps(EventType.UP_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.DOWN_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_RELEASED);
    
    addEventTypeToMaps(EventType.W_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.A_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.S_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.D_BUTTON_RELEASED);
    
    addEventTypeToMaps(EventType.CLIENT_ID_SET);
    
    addEventTypeToMaps(EventType.CLIENT_PADDLE_CONTROLS);
    addEventTypeToMaps(EventType.GOAL_SCORED);
    addEventTypeToMaps(EventType.BALL_PLAYER_COLLISION);
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

public class GameState_ServerState extends GameState implements IServerCallbackHandler
{
  private int nextClientID = 1;
  
  public GameState_ServerState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    sharedGameObjectManager.fromXML("levels/pong/server_level.xml");
    //sharedGameObjectManager.fromXML("levels/box_example/shared_level.xml");
    //sharedGameObjectManager.fromXML("levels/pong/small_level.xml");
    
    mainServer = new MSServer(this);
    mainServer.begin();
  }
  
  @Override public void update(int deltaTime)
  {
    physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
    sharedGameObjectManager.update(deltaTime);
    scene.render();
    mainServer.update();
    sendWorldToAllClients();
  }
  
  @Override public void onExit()
  {
    sharedGameObjectManager.clearGameObjects();
    mainServer.end();
    mainServer = null;
  }
  
  @Override public ByteBuffer getNewClientInitializationMessage()
  {
    FlatBufferBuilder builder = new FlatBufferBuilder(0);
    
    FlatInitializationMessage.startFlatInitializationMessage(builder);
    FlatInitializationMessage.addClientID(builder, nextClientID);
    int flatInitializationMessageOffset = FlatInitializationMessage.endFlatInitializationMessage(builder);
    nextClientID++;
    
    FlatMessageHeader.startFlatMessageHeader(builder);
    FlatMessageHeader.addTimeStamp(builder, System.currentTimeMillis());
    FlatMessageHeader.addClientID(builder, 0);
    int flatMessageHeader = FlatMessageHeader.endFlatMessageHeader(builder);
    
    FlatMessageBodyTable.startFlatMessageBodyTable(builder);
    FlatMessageBodyTable.addBodyType(builder, FlatMessageBodyUnion.FlatInitializationMessage);
    FlatMessageBodyTable.addBody(builder, flatInitializationMessageOffset);
    int flatMessageBodyTable = FlatMessageBodyTable.endFlatMessageBodyTable(builder);
    
    FlatMessage.startFlatMessage(builder);
    FlatMessage.addHeader(builder, flatMessageHeader);
    FlatMessage.addBodyTable(builder, flatMessageBodyTable);
    FlatMessage.finishFlatMessageBuffer(builder, FlatMessage.endFlatMessage(builder));
    
    return builder.dataBuffer();
  }
  
  @Override public void handleClientMessage(ByteBuffer clientMessage)
  {
    FlatMessage flatServerMessage = FlatMessage.getRootAsFlatMessage(clientMessage);
    
    FlatMessageHeader flatMessageHeader = flatServerMessage.header();
    int clientID = flatMessageHeader.clientID();
    
    FlatMessageBodyTable bodyTable = flatServerMessage.bodyTable();
    byte bodyType = bodyTable.bodyType();
    
    if (bodyType == FlatMessageBodyUnion.FlatPaddleControllerState)
    {
      FlatPaddleControllerState flatPaddleControllerState = (FlatPaddleControllerState)bodyTable.body(new FlatPaddleControllerState());
      
      IEvent event = new Event(EventType.CLIENT_PADDLE_CONTROLS);
      event.addIntParameter("clientID", clientID);
      event.addBooleanParameter("leftButtonDown", flatPaddleControllerState.leftButtonDown());
      event.addBooleanParameter("rightButtonDown", flatPaddleControllerState.rightButtonDown());
      event.addBooleanParameter("upButtonDown", flatPaddleControllerState.upButtonDown());
      event.addBooleanParameter("downButtonDown", flatPaddleControllerState.downButtonDown());
      event.addBooleanParameter("wButtonDown", flatPaddleControllerState.wButtonDown());
      event.addBooleanParameter("aButtonDown", flatPaddleControllerState.aButtonDown());
      event.addBooleanParameter("sButtonDown", flatPaddleControllerState.sButtonDown());
      event.addBooleanParameter("dButtonDown", flatPaddleControllerState.dButtonDown());
      eventManager.queueEvent(event);
    }
  }
  
  private void sendWorldToAllClients()
  {
    FlatBufferBuilder builder = new FlatBufferBuilder(0);
    
    int flatGameWorld = sharedGameObjectManager.serialize(builder);
    
    FlatMessageHeader.startFlatMessageHeader(builder);
    FlatMessageHeader.addTimeStamp(builder, System.currentTimeMillis());
    FlatMessageHeader.addClientID(builder, 0);
    int flatMessageHeader = FlatMessageHeader.endFlatMessageHeader(builder);
    
    FlatMessageBodyTable.startFlatMessageBodyTable(builder);
    FlatMessageBodyTable.addBodyType(builder, FlatMessageBodyUnion.FlatGameWorld);
    FlatMessageBodyTable.addBody(builder, flatGameWorld);
    int flatMessageBodyTable = FlatMessageBodyTable.endFlatMessageBodyTable(builder);
    
    FlatMessage.startFlatMessage(builder);
    FlatMessage.addHeader(builder, flatMessageHeader);
    FlatMessage.addBodyTable(builder, flatMessageBodyTable);
    FlatMessage.finishFlatMessageBuffer(builder, FlatMessage.endFlatMessage(builder));
    
    mainServer.write(builder.dataBuffer());
  }
}

public class GameState_ClientState extends GameState implements IClientCallbackHandler
{
  private int clientID;
  
  public GameState_ClientState()
  {
    super();
    
    clientID = -1;
  }
  
  @Override public void onEnter()
  {
    mainClient = new MSClient(this);
    
    if (!mainClient.connect())
    {
      println("Exiting.");
      exit();
    }
  }
  
  @Override public void update(int deltaTime)
  {
    if (mainClient != null && mainClient.isConnected())
    {
      mainClient.update();
    }
    
    localGameObjectManager.update(deltaTime);
    
    synchronized(sharedGameObjectManager)
    {
      scene.render();
    }
  }
  
  @Override public void onExit()
  {
    localGameObjectManager.clearGameObjects();
    
    if (mainClient != null)
    {
      mainClient.disconnect();
      mainClient = null;
    }
  }
  
  @Override public void handleServerMessage(ByteBuffer serverMessage)
  {
    FlatMessage flatServerMessage = FlatMessage.getRootAsFlatMessage(serverMessage);
    
    FlatMessageBodyTable bodyTable = flatServerMessage.bodyTable();
    byte bodyType = bodyTable.bodyType();
    
    if (bodyType == FlatMessageBodyUnion.FlatGameWorld)
    {
      FlatGameWorld flatGameWorld = (FlatGameWorld)bodyTable.body(new FlatGameWorld());
      
      synchronized(sharedGameObjectManager)
      {
        sharedGameObjectManager.deserialize(flatGameWorld);
      }
    }
    else if (bodyType == FlatMessageBodyUnion.FlatInitializationMessage)
    {
      FlatInitializationMessage flatInitializationMessage = (FlatInitializationMessage)bodyTable.body(new FlatInitializationMessage());
      
      clientID = flatInitializationMessage.clientID();
      
      switch (clientID)
      {
        case 1:
          localGameObjectManager.fromXML("levels/pong/client_level_blue.xml");
          break;
          
        case 2:
          localGameObjectManager.fromXML("levels/pong/client_level_green.xml");
          break;
          
        case 3:
          localGameObjectManager.fromXML("levels/pong/client_level_black.xml");
          break;
          
        case 4:
          localGameObjectManager.fromXML("levels/pong/client_level_red.xml");
          break;
          
        default:
          println("Invalid clientID received: " + clientID);
          assert(false);
      }
      
      IEvent event = new Event(EventType.CLIENT_ID_SET);
      event.addIntParameter("clientID", clientID);
      eventManager.queueEvent(event);
    }
  }
  
  public int getClientID()
  {
    return clientID;
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

public interface IMaterialManager
{
  public PImage getTexture(String name);
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
          texture = materialManager.getTexture(textureFileName);
          break;
          
        case "newmtl":
          return lineIndex;
      }
    }
    
    return lineIndex;
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

public class MaterialManager implements IMaterialManager
{
  private HashMap<String, PImage> textures;
  private HashMap<String, IMaterialLib> materialLibs;
  
  public MaterialManager()
  {
    textures = new HashMap<String, PImage>();
    materialLibs = new HashMap<String, IMaterialLib>();
  }
  
  @Override public PImage getTexture(String name)
  {
    if (!textures.containsKey(name))
    {
      textures.put(name, loadImage(name));
    }
    return textures.get(name);
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
  public void write(ByteBuffer message);
}

public interface IClientCallbackHandler
{
  public void handleServerMessage(ByteBuffer serverMessage);
}

public interface IServer
{
  public boolean begin();
  public void update();
  public void end();
  public boolean isActive();
  public void write(ByteBuffer message);
  public void handleServerEvent(Server p_pServer, Client p_pClient);
}

public interface IServerCallbackHandler
{
  public ByteBuffer getNewClientInitializationMessage();
  public void handleClientMessage(ByteBuffer clientMessage);
}

//----------------------------------------------------------------
// IMPLEMENTATION
//----------------------------------------------------------------

public final String MAIN_SERVER_IP = "127.0.0.1";
public final int MAIN_SERVER_PORT = 5204;

public final byte[] BEGIN_SEQUENCE = { 55, -45, 95, -44, 28, -74, -65, -66 };
public final byte[] END_SEQUENCE = { -72, 107, -85, -117, 45, -123, 69, 20 };
public final byte[] SUB_SERVER_CONNECT_SEQUENCE = { 108, 85, 57, 60, 93, 0, -15, -113 };
public final int TIME_OUT_LIMIT = 6000;


public class CircularByteBuffer
{
  protected byte[] buffer;
  protected int bufferHead;
  protected int bufferTail;
  
  public CircularByteBuffer(int size)
  {
    buffer = new byte[size];
    bufferHead = 0;
    bufferTail = 0;
  }
  
  synchronized public void append(byte[] bytes, int length)
  {
    for (int i = 0; i < length; i++)
    {
      buffer[bufferTail] = bytes[i];
      bufferTail = (bufferTail + 1) % buffer.length;
      assert(bufferTail != bufferHead);
    }
  }
  
  synchronized public void advanceHead(int length)
  {
    bufferHead = (bufferHead + length) % buffer.length;
  }
  
  synchronized public void clear()
  {
    bufferHead = bufferTail;
  }
  
  synchronized public int size()
  {
    if (bufferTail >= bufferHead)
    {
      return bufferTail - bufferHead;
    }
    else
    {
      return buffer.length + bufferTail - bufferHead;
    }
  }
  
  synchronized public byte[] getCurrentContents()
  {
    return getCurrentContents(size());
  }
  
  synchronized public byte[] getCurrentContents(int maxLength)
  {
    int contentsLength = min(size(), maxLength);
    byte[] contents = new byte[contentsLength];
    
    for (int i = 0; i < contentsLength; i++)
    {
      contents[i] = buffer[(bufferHead + i) % buffer.length];
    }
    
    return contents;
  }
  
  synchronized public boolean beginsWith(byte[] sequence)
  {
    for (int i = 0; i < sequence.length; i++)
    {
      int pos = (bufferHead + i) % buffer.length;
      
      if ((pos == (bufferTail + 1) % buffer.length) || buffer[pos] != sequence[i])
      {
        return false;
      }
    }
    
    return true;
  }
  
  synchronized public int indexOf(byte[] sequence)
  {
    int sequenceIndex = -1;
    
    byte[] contents = getCurrentContents();
    
    int i = 0;
    
    while (sequenceIndex == -1 && i <= contents.length - sequence.length)
    {
      if (contents[i] == sequence[0])
      {
        int j = 1;
        
        while (sequenceIndex == -1 && i + j < contents.length && contents[i + j] == sequence[j])
        {
          j++;
          
          if (j == sequence.length)
          {
            sequenceIndex = i;
          }
        }
      }
      
      i++;
    }
    
    return sequenceIndex;
  }
}


public class NetworkCircularByteBuffer extends CircularByteBuffer
{
  private static final int TEMP_BUFFER_SIZE = 1024;
  
  private byte[] tempBuffer;
  private boolean beginSequenceChecked;
  
  public NetworkCircularByteBuffer(int size)
  {
    super(size);
    
    tempBuffer = new byte[TEMP_BUFFER_SIZE];
    beginSequenceChecked = false;
  }
  
  synchronized public byte[] parseMessageLoop(Client pClient)
  {
    if (pClient != null && pClient.available() > 0)
    {
      int length = pClient.readBytes(tempBuffer);
      
      append(tempBuffer, length);
    }
    
    if (!beginSequenceChecked)
    {
      if (size() >= BEGIN_SEQUENCE.length)
      {
        beginSequenceChecked = beginsWith(BEGIN_SEQUENCE);
        
        if (beginSequenceChecked)
        {
          advanceHead(BEGIN_SEQUENCE.length);
        }
        else
        {
          byte[] firstByteOfBeginSequence = { BEGIN_SEQUENCE[0] };
          int indexOfFirstByteOfBeginSequence = indexOf(firstByteOfBeginSequence);
          
          if (indexOfFirstByteOfBeginSequence == -1)
          {
            clear();
          }
          else
          {
            advanceHead(indexOfFirstByteOfBeginSequence);
          }
        }
      }
    }
    
    if (beginSequenceChecked)
    {
      int endSequenceIndex = indexOf(END_SEQUENCE);
      
      if (endSequenceIndex != -1)
      {
        byte[] message = getCurrentContents(endSequenceIndex);
        advanceHead(message.length + END_SEQUENCE.length);
        beginSequenceChecked = false;
        
        return message;
      }
    }
    
    return null;
  }
}


public class MSClient implements IClient
{
  private static final int BUFFER_SIZE = 102400;
  
  private Client pClient;
  private NetworkCircularByteBuffer circularBuffer;
  private IClientCallbackHandler handler;
  
  
  public MSClient(IClientCallbackHandler _handler)
  {
    pClient = null;
    circularBuffer = new NetworkCircularByteBuffer(BUFFER_SIZE);
    handler = _handler;
  }
  
  @Override public boolean connect()
  {
    pClient = new Client(mainObject, MAIN_SERVER_IP, MAIN_SERVER_PORT);
    
    if (!pClient.active())
    {
      println("Failed to connect to main server.");
      pClient = null;
      return false;
    }
    
    boolean connected = redirectConnectionToSubServer();
    
    if (!connected)
    {
      println("Failed to connect to sub server.");
      return false;
    }
    
    println("Client connected.");
    return true;
  }
  
  private boolean redirectConnectionToSubServer()
  {
    int initialTime = millis();
    int currentTime = initialTime;
    
    while (currentTime - initialTime < TIME_OUT_LIMIT)
    {
      byte[] message = circularBuffer.parseMessageLoop(pClient);
      
      if (message != null && connectToSubServerMessageCheck(message))
      {
        int subServerPort = parsePort(message);
        
        pClient.stop();
        pClient = new Client(mainObject, MAIN_SERVER_IP, subServerPort);
        
        if (pClient.active())
        {
          return true;
        }
        else
        {
          println("Failed to connect to given sub server port.");
          pClient = null;
          return false;
        }
      }
      
      currentTime = millis();
    }
    
    pClient = null;
    return false;
  }
  
  private boolean connectToSubServerMessageCheck(byte[] message)
  {
    if (message.length < SUB_SERVER_CONNECT_SEQUENCE.length)
    {
      return false;
    }
    
    for (int i = 0; i < SUB_SERVER_CONNECT_SEQUENCE.length; i++)
    {
      if (message[i] != SUB_SERVER_CONNECT_SEQUENCE[i])
      {
        return false;
      }
    }
    
    return true;
  }
  
  private int parsePort(byte[] message)
  {
    byte[] portBytes = new byte[4];
    
    portBytes[0] = message[SUB_SERVER_CONNECT_SEQUENCE.length];
    portBytes[1] = message[SUB_SERVER_CONNECT_SEQUENCE.length + 1];
    portBytes[2] = message[SUB_SERVER_CONNECT_SEQUENCE.length + 2];
    portBytes[3] = message[SUB_SERVER_CONNECT_SEQUENCE.length + 3];
    
    ByteBuffer portByteBuffer = ByteBuffer.wrap(portBytes);
    
    return portByteBuffer.getInt();
  }
  
  @Override public void update()
  {
    byte[] message = null;
    ArrayList<byte[]> messageList = new ArrayList<byte[]>();
    
    do
    {
      message = circularBuffer.parseMessageLoop(pClient);
      
      if (message != null)
      {
        messageList.add(message);
      }
    }
    while (message != null);
    
    if (messageList.size() > 0)
    {
      handler.handleServerMessage(ByteBuffer.wrap(messageList.get(messageList.size() - 1)));
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
  
  @Override public void write(ByteBuffer message)
  {
    if (isConnected())
    {
      byte[] bytes = new byte[message.remaining() + BEGIN_SEQUENCE.length + END_SEQUENCE.length];
      for (int i = 0; i < BEGIN_SEQUENCE.length; i++)
      {
        bytes[i] = BEGIN_SEQUENCE[i];
      }
      message.get(bytes, BEGIN_SEQUENCE.length, message.remaining());
      for (int i = 0; i < END_SEQUENCE.length; i++)
      {
        bytes[bytes.length - i - 1] = END_SEQUENCE[END_SEQUENCE.length - i - 1];
      }
      
      pClient.write(bytes);
    }
  }
}

public void serverEvent(Server p_pServer, Client p_pClient)
{
  mainServer.handleServerEvent(p_pServer, p_pClient);
}

public class MSServer implements IServer
{
  private Server pServer;
  private HashMap<Server, SubServer> subServers;
  private IServerCallbackHandler handler;
  
  private int nextSubServerPort;
  
  
  public MSServer(IServerCallbackHandler _handler)
  {
    pServer = null;
    subServers = new HashMap<Server, SubServer>();
    handler = _handler;
    
    nextSubServerPort = MAIN_SERVER_PORT + 1;
  }
  
  @Override public boolean begin()
  {
    if (pServer == null)
    {
      pServer = new Server(mainObject, MAIN_SERVER_PORT);
      
      if (isActive())
      {
        println("Server started.");
      }
      else
      {
        println("Server failed to start.");
        pServer = null;
        return false;
      }
    }
    
    return true;
  }
  
  @Override public void update()
  {
    if (isActive())
    {
      for (Map.Entry entry : subServers.entrySet())
      {
        SubServer subServer = (SubServer)entry.getValue();
        subServer.update();
      }
    }
  }
  
  @Override public void end()
  {
    if (isActive())
    {
      for (Map.Entry entry : subServers.entrySet())
      {
        SubServer subServer = (SubServer)entry.getValue();
        subServer.stop();
      }
      pServer.stop();
      pServer = null;
    }
  }
  
  @Override public boolean isActive()
  {
    return pServer != null && pServer.active();
  }
  
  @Override public void write(ByteBuffer message)
  {
    if (isActive())
    {
      byte[] bytes = new byte[message.remaining()];
      message.get(bytes);
      byte[] completeMessage = attachBeginAndEndSequencesToMessage(bytes);
      println(completeMessage.length);
      synchronized(this)
      {
        for (Map.Entry entry : subServers.entrySet())
        {
          SubServer subServer = (SubServer)entry.getValue();
          subServer.write(completeMessage);
        }
      }
    }
  }
  
  private byte[] attachBeginAndEndSequencesToMessage(byte[] message)
  {
    byte[] bytes = new byte[message.length + BEGIN_SEQUENCE.length + END_SEQUENCE.length];
    
    for (int i = 0; i < BEGIN_SEQUENCE.length; i++)
    {
      bytes[i] = BEGIN_SEQUENCE[i];
    }
    
    for (int i = 0; i < message.length; i++)
    {
      bytes[BEGIN_SEQUENCE.length + i] = message[i];
    }
    
    for (int i = 0; i < END_SEQUENCE.length; i++)
    {
      bytes[bytes.length - i - 1] = END_SEQUENCE[END_SEQUENCE.length - i - 1];
    }
    
    return bytes;
  }
  
  @Override public void handleServerEvent(Server p_pServer, Client p_pClient)
  {
    if (p_pServer == pServer)
    {
      synchronized(this)
      {
        spawnNewSubServer(nextSubServerPort);
        sendConnectionRedirectMessage(p_pClient);
        nextSubServerPort++;
      }
    }
    else
    {
      SubServer subServer = subServers.get(p_pServer);
      if (subServer != null)
      {
        subServer.handleServerEvent(p_pClient);
      }
    }
  }
  
  private void spawnNewSubServer(int nextSubServerPort)
  {
    SubServer subServer = new SubServer(this, nextSubServerPort);
    subServers.put(subServer.pServer, subServer);
  }
  
  private void sendConnectionRedirectMessage(Client p_pClient)
  {
    byte[] connectToMessage = new byte[SUB_SERVER_CONNECT_SEQUENCE.length + 4];
    
    for (int i = 0; i < SUB_SERVER_CONNECT_SEQUENCE.length; i++)
    {
      connectToMessage[i] = SUB_SERVER_CONNECT_SEQUENCE[i];
    }
    
    byte[] portAsBytes = new byte[] {
            (byte)(nextSubServerPort >>> 24),
            (byte)(nextSubServerPort >>> 16),
            (byte)(nextSubServerPort >>> 8),
            (byte)nextSubServerPort
    };
    
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length] = portAsBytes[0];
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length + 1] = portAsBytes[1];
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length + 2] = portAsBytes[2];
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length + 3] = portAsBytes[3];
    
    p_pClient.write(attachBeginAndEndSequencesToMessage(connectToMessage));
  }
  
  public IServerCallbackHandler getHandler()
  {
    return handler;
  }
  
  private class SubServer
  {
    private static final int SUB_SERVER_BUFFER_SIZE = 10240;
    
    private MSServer mainServer;
    private Client pClient;
    private NetworkCircularByteBuffer circularBuffer;
    
    public Server pServer;
    
    
    public SubServer(MSServer _mainServer, int subServerPort)
    {
      mainServer = _mainServer;
      pClient = null;
      circularBuffer = new NetworkCircularByteBuffer(SUB_SERVER_BUFFER_SIZE);
      
      pServer = new Server(mainObject, subServerPort);
    }
    
    public void handleServerEvent(Client p_pClient)
    {
      assert(pClient == null);
      pClient = p_pClient;
      
      ByteBuffer initMessage = mainServer.getHandler().getNewClientInitializationMessage();
      if (initMessage != null)
      {
        byte[] bytes = new byte[initMessage.remaining()];
        initMessage.get(bytes);
        byte[] completeMessage = attachBeginAndEndSequencesToMessage(bytes);
        
        write(completeMessage);
      }
    }
    
    public void update()
    {
      byte[] message = null;
      
      do
      {
        message = circularBuffer.parseMessageLoop(pClient);
        
        if (message != null)
        {
          mainServer.getHandler().handleClientMessage(ByteBuffer.wrap(message));
        }
      }
      while (message != null);
    }
    
    public void write(byte[] message)
    { 
      if (isConnected())
      {
        pClient.write(message);
      }
    }
    
    public boolean isConnected()
    {
      return pClient != null && pClient.active();
    }
    
    public void stop()
    {
      pServer.stop();
    }
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
  public void fromFile(String fileName, float minU, float maxU, float minV, float maxV); // gif, jpg, tga, or png
  public void render();
}

public interface ISpriteManager
{
  public void loadAllSprites();
  public ISprite getSprite(String name);
  public void free();
}

public interface ISpriteInstance
{
  public ISprite getSprite();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  public PVector getTint();
  public float getAlpha();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  public void setTint(PVector pTint);
  public void setAlpha(float pAlpha);
  
  public void render();
  
  public int serialize(FlatBufferBuilder builder);
  public void deserialize(FlatSprite flatSprite);
}

public interface IModel
{
  public String getName();
  public void fromOBJ(String objFileName);
  public void render();
}

public interface IModelManager
{
  public void loadAllModels();
  public IModel getModel(String name);
  public void free();
}

public interface IModelInstance
{
  public IModel getModel();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  
  public void render();
  
  public int serialize(FlatBufferBuilder builder);
  public void deserialize(FlatModel flatModel);
}

public interface IFontManager
{
  public PFont getFont(String name);
}

public interface ITextInstance
{
  public String getName();
  
  public void fromXML(XML xmlTextLine);
  
  public void render();
  
  //public int serialize(FlatBufferBuilder builder);
  //public void deserialize(FlatText flatText);
}

public interface IScene
{
  public IOrthographicCamera getOrthographicCamera();
  public void setOrthographicCamera(IOrthographicCamera orthographicCamera);
  
  public IPerspectiveCamera getPerspectiveCamera();
  public void setPerspectiveCamera(IPerspectiveCamera perspectiveCamera);
  
  public int addSpriteInstance(ISpriteInstance sprite);
  public ISpriteInstance getSpriteInstance(int handle);
  public void removeSpriteInstance(int handle);
  
  public int addModelInstance(IModelInstance model);
  public IModelInstance getModelInstance(int handle);
  public void removeModelInstance(int handle);
  
  public void render();
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public abstract class Camera implements ICamera
{
  protected PVector position;
  protected PVector target;
  protected PVector up;
  
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
    position = new PVector(0.0f, 0.0f, -10.0f);
    target = new PVector(0.0f, 0.0f, 0.0f);
    up = new PVector(0.0f, 1.0f, 0.0f);
  }
  
  @Override public void apply()
  {
    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
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
}

public class Sprite implements ISprite
{
  private String name;
  private PShape pShape;
  
  public Sprite(String _name)
  {
    name = _name;
    pShape = null;
  }
    
  @Override public String getName()
  {
    return name;
  }
  
  @Override public void fromFile(String fileName, float minU, float maxU, float minV, float maxV)
  {
    pShape = createShape();
    pShape.beginShape();
    pShape.vertex(-0.5f, -0.5f, 0.0f, maxU, minV);
    pShape.vertex(0.5f, -0.5f, 0.0f, minU, minV);
    pShape.vertex(0.5f, 0.5f, 0.0f, minU, maxV);
    pShape.vertex(-0.5f, 0.5f, 0.0f, maxU, maxV);
    pShape.texture(materialManager.getTexture(fileName));
    pShape.endShape(CLOSE);
    pShape.disableStyle();
  }
  
  @Override public void render()
  {
    shape(pShape);
  }
}

public class SpriteManager implements ISpriteManager
{
  private static final String MANIFEST_FILE_NAME = "sprites/sprites-manifest.xml";
  
  private HashMap<String, ISprite> loadedSprites;
  private XML manifest;
  
  public SpriteManager()
  {
    loadedSprites = new HashMap<String, ISprite>();
    manifest = loadXML(MANIFEST_FILE_NAME);
    assert(manifest.getName().equals("Sprites"));
  }
  
  @Override public void loadAllSprites()
  {
    for (XML xmlSprite : manifest.getChildren("Sprite"))
    {
      loadSprite(xmlSprite.getString("name"), xmlSprite);
    }
  }
  
  @Override public ISprite getSprite(String name)
  {
    ISprite sprite = loadedSprites.get(name);
    
    if (sprite != null)
    {
      return sprite;
    }
    
    for (XML xmlSprite : manifest.getChildren("Sprite"))
    {
      if (xmlSprite.getString("name").equals(name))
      {
        return loadSprite(name, xmlSprite);
      }
    }
    
    println("WARNING: No such sprite by name: " + name + " found in sprites-manifest.");
    return null;
  }
  
  private ISprite loadSprite(String name, XML xmlSprite)
  {
    ISprite sprite = new Sprite(name);
    sprite.fromFile(xmlSprite.getString("file"), xmlSprite.getFloat("minU"), xmlSprite.getFloat("maxU"), xmlSprite.getFloat("minV"), xmlSprite.getFloat("maxV"));
    loadedSprites.put(sprite.getName(), sprite);
    return sprite;
  }
  
  @Override public void free()
  {
    loadedSprites.clear();
  }
}

public class SpriteInstance implements ISpriteInstance
{
  private ISprite sprite;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  private PVector tintColor;
  private float alpha;
  
  public SpriteInstance(String spriteName)
  {
    sprite = spriteManager.getSprite(spriteName);
    
    translation = new PVector(0.0f, 0.0f, 0.0f);
    rotation = new PVector(0.0f, 0.0f, 0.0f);
    scale = new PVector(1.0f, 1.0f, 1.0f);
    
    tintColor = new PVector(255.0f, 255.0f, 255.0f);
    alpha = 255.0f;
  }
  
  @Override public ISprite getSprite()
  {
    return sprite;
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
  
  @Override public PVector getTint()
  {
    return tintColor;
  }
  
  @Override public float getAlpha()
  {
    return alpha;
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
  
  @Override public void setTint(PVector pTint)
  {
    tintColor = pTint;
  }
  
  @Override public void setAlpha(float pAlpha)
  {
    alpha = pAlpha;
  }
  
  @Override public void render()
  {
    pushMatrix();
    
    translate(translation.x, translation.y, translation.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    
    noStroke();
    tint(tintColor.x, tintColor.y, tintColor.z, alpha);
    
    sprite.render();
    
    popMatrix();
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int spriteNameOffset = builder.createString(sprite.getName());
    
    FlatSprite.startFlatSprite(builder);
    FlatSprite.addSpriteName(builder, spriteNameOffset);
    FlatSprite.addTranslation(builder, FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z));
    FlatSprite.addRotation(builder, FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z));
    FlatSprite.addScale(builder, FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z));
    FlatSprite.addTint(builder, FlatVec4.createFlatVec4(builder, tintColor.x, tintColor.y, tintColor.z, alpha));
    
    return FlatSprite.endFlatSprite(builder);
  }
  
  @Override public void deserialize(FlatSprite flatSprite)
  {
    sprite = spriteManager.getSprite(flatSprite.spriteName());
    
    FlatVec3 flatTranslation = flatSprite.translation();
    translation = new PVector(flatTranslation.x(), flatTranslation.y(), flatTranslation.z());
    
    FlatVec3 flatRotation = flatSprite.rotation();
    rotation = new PVector(flatRotation.x(), flatRotation.y(), flatRotation.z());
    
    FlatVec3 flatScale = flatSprite.scale();
    scale = new PVector(flatScale.x(), flatScale.y(), flatScale.z());
    
    FlatVec4 flatTint = flatSprite.tint();
    tintColor = new PVector(flatTint.x(), flatTint.y(), flatTint.z());
    alpha = flatTint.w();
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
  
  public Model(String _name)
  {
    name = _name;
    
    faces = new ArrayList<PShapeExt>();
    material = new Material();
  }
  
  @Override public String getName()
  {
    return name;
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
          materialLib = materialManager.getMaterialLib(words[1]);
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
  
  @Override public void render()
  {
    for (PShapeExt face : faces)
    {
      shape(face.pshape);
    }
  }
}

public class ModelManager implements IModelManager
{
  private static final String MANIFEST_FILE_NAME = "models/models-manifest.xml";
  
  private HashMap<String, IModel> loadedModels;
  private XML manifest;
  
  public ModelManager()
  {
    loadedModels = new HashMap<String, IModel>();
    manifest = loadXML(MANIFEST_FILE_NAME);
    assert(manifest.getName().equals("Models"));
  }
  
  @Override public void loadAllModels()
  {
    for (XML xmlModel : manifest.getChildren("Model"))
    {
      IModel model = new Model(xmlModel.getString("name"));
      model.fromOBJ(xmlModel.getString("objFile"));
      loadedModels.put(model.getName(), model);
    }
  }
  
  @Override public IModel getModel(String name)
  {
    IModel model = loadedModels.get(name);
    
    if (model != null)
    {
      return model;
    }
    
    for (XML xmlModel : manifest.getChildren("Model"))
    {
      if (xmlModel.getString("name").equals(name))
      {
        model = new Model(name);
        model.fromOBJ(xmlModel.getString("objFile"));
        loadedModels.put(name, model);
        return model;
      }
    }
    
    println("WARNING: No such model by name: " + name + " found in models-manifest.");
    return null;
  }
  
  @Override public void free()
  {
    loadedModels.clear();
  }
}

public class ModelInstance implements IModelInstance
{
  private IModel model;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  public ModelInstance(String modelName)
  {
    model = modelManager.getModel(modelName);
    
    translation = new PVector();
    rotation = new PVector();
    scale = new PVector(1.0f, 1.0f, 1.0f);
  }
  
  @Override public IModel getModel()
  {
    return model;
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
    
    model.render();
    
    popMatrix();
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int modelNameOffset = builder.createString(model.getName());
    
    FlatModel.startFlatModel(builder);
    FlatModel.addModelName(builder, modelNameOffset);
    FlatModel.addTranslation(builder, FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z));
    FlatModel.addRotation(builder, FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z));
    FlatModel.addScale(builder, FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z));
    
    return FlatModel.endFlatModel(builder);
  }
  
  @Override public void deserialize(FlatModel flatModel)
  {
    model = modelManager.getModel(flatModel.modelName());
    
    FlatVec3 flatTranslation = flatModel.translation();
    translation = new PVector(flatTranslation.x(), flatTranslation.y(), flatTranslation.z());
    
    FlatVec3 flatRotation = flatModel.rotation();
    rotation = new PVector(flatRotation.x(), flatRotation.y(), flatRotation.z());
    
    FlatVec3 flatScale = flatModel.scale();
    scale = new PVector(flatScale.x(), flatScale.y(), flatScale.z());
  }
}

public class FontManager implements IFontManager
{
  private static final int DEFAULT_FONT_SIZE = 32;
  private static final boolean DEFAULT_ALIASING = true;
  
  private HashMap<String, PFont> fontMap;
  
  public FontManager()
  {
    fontMap = new HashMap<String, PFont>();
  }
  
  @Override public PFont getFont(String name)
  {
    PFont font = fontMap.get(name);
    
    if (font != null)
    {
      return font;
    }
    
    font = createFont(name, DEFAULT_FONT_SIZE, DEFAULT_ALIASING);
    return font;
  }
}


public class Text implements ITextInstance
{
  private String name;
  private String string;
  private PFont font;
  private int alignX;
  private int alignY;
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  private int tcolor;
  
  public Text(String _name)
  {
    name = _name;
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public void fromXML(XML xmlTextLine)
  {
    string = xmlTextLine.getString("string");
    font = fontManager.getFont(xmlTextLine.getString("font"));
    
    String strAlignX = xmlTextLine.getString("alignX");
    switch (strAlignX)
    {
      case "left":
        alignX = LEFT;
        break;
        
      case "right":
        alignX = RIGHT;
        break;
        
      case "center":
      default:
        alignX = CENTER;
        break;
    }
    
    String strAlignY = xmlTextLine.getString("alignY");
    switch (strAlignY)
    {
      case "top":
        alignY = TOP;
        break;
        
      case "center":
        alignY = CENTER;
        break;
        
      case "bottom":
        alignY = BOTTOM;
        break;
        
      case "baseline":
      default:
        alignY = BASELINE;
        break;
    }
    
    translation = new PVector(xmlTextLine.getFloat("x"), xmlTextLine.getFloat("y"));
    tcolor = color(xmlTextLine.getFloat("r"), xmlTextLine.getFloat("g"), xmlTextLine.getFloat("b"), xmlTextLine.getFloat("a"));
  }
  
  @Override public void render()
  {
    pushMatrix();
    
    translate(translation.x, translation.y, translation.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    
    textFont(font);
    textAlign(alignX, alignY);
    strokeWeight(0);
    fill(tcolor);
    text(string, 0.0f, 0.0f, 0.0f);
    
    popMatrix();
  }
  
  //@Override public int serialize(FlatBufferBuilder builder)
  //{
  //  return 0;
  //}
  
  //@Override public void deserialize(FlatText flatText)
  //{
  //}
}


public class Scene implements IScene
{
  private IOrthographicCamera orthographicCamera;
  private IPerspectiveCamera perspectiveCamera;
  private HashMap<Integer, ISpriteInstance> spriteInstances;
  private HashMap<Integer, IModelInstance> modelInstances;
  private int nextSpriteHandle;
  private int nextModelHandle;
  
  public Scene()
  {
    orthographicCamera = new OrthographicCamera();
    perspectiveCamera = new PerspectiveCamera();
    spriteInstances = new HashMap<Integer, ISpriteInstance>();
    modelInstances = new HashMap<Integer, IModelInstance>();
    nextSpriteHandle = 0;
    nextModelHandle = 0;
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
  
  @Override public int addSpriteInstance(ISpriteInstance sprite)
  {
    int spriteHandle = nextSpriteHandle;
    ++nextSpriteHandle;
    spriteInstances.put(spriteHandle, sprite);
    return spriteHandle;
  }
  
  @Override public ISpriteInstance getSpriteInstance(int handle)
  {
    return spriteInstances.get(handle);
  }
  
  @Override public void removeSpriteInstance(int handle)
  {
    spriteInstances.remove(handle);
  }
  
  @Override public int addModelInstance(IModelInstance model)
  {
    int modelHandle = nextModelHandle;
    ++nextModelHandle;
    modelInstances.put(modelHandle, model);
    return modelHandle;
  }
  
  @Override public IModelInstance getModelInstance(int handle)
  {
    return modelInstances.get(handle);
  }
  
  @Override public void removeModelInstance(int handle)
  {
    modelInstances.remove(handle);
  }
  
  @Override public void render()
  {
    orthographicCamera.apply();
    
    for (Map.Entry entry : spriteInstances.entrySet())
    {
      ((ISpriteInstance)entry.getValue()).render();
    }
    
    //perspectiveCamera.apply();
    
    //for (Map.Entry entry : modelInstances.entrySet())
    //{
    //  ((IModelInstance)entry.getValue()).render();
    //}
  }
}
  public void settings() {  size(500, 500, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MultiScreenGameEngine" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
