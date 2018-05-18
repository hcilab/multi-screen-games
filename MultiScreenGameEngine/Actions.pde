//======================================================================================================
// Author: David Hanna
//
// Actions are serializeable captures of changes to the game state and the time that change takes place.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public enum ActionType //enum = special Java type to define collections of constants
{
  //TranslateOverTimeComponent
  TRANSLATE,
  SET_MOVING_LEFT,
  SET_MOVING_DOWN,
  SET_MOVING_FORWARD,
  
  //RotateOverTimeComponent
  ROTATE,
  
  //ScaleOverTimeComponent
  SCALE,
  SET_X_SCALING_UP,
  SET_Y_SCALING_UP,
  SET_Z_SCALING_UP,
}

public interface IAction //do not know yet
{
  public int getTimeStamp();
  public ActionType getActionType();
  
  public void apply();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonAction); //end
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

//enum to string
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

//string to enum
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

//don't know yet
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