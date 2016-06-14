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
  private IGameObject target;
  private PVector translation;
  
  public TranslateAction()
  {
    super();
    
    target = null;
    translation = new PVector();
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.TRANSLATE;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public IGameObject getTarget()
  {
    return target;
  }
  
  public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  public PVector getTranslation()
  {
    return translation;
  }
  
  @Override public void apply()
  {
    target.translate(translation);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonTranslateAction = new JSONObject();
    
    jsonTranslateAction.setString("ActionType", actionTypeEnumToString(ActionType.TRANSLATE));
    jsonTranslateAction.setInt("uid", target.getUID());
    jsonTranslateAction.setFloat("x", translation.x);
    jsonTranslateAction.setFloat("y", translation.y);
    jsonTranslateAction.setFloat("z", translation.z);
    
    return jsonTranslateAction;
  }
  
  @Override public void deserialize(JSONObject jsonTranslateAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonTranslateAction.getInt("uid"));
    translation.x = jsonTranslateAction.getFloat("x");
    translation.y = jsonTranslateAction.getFloat("y");
    translation.z = jsonTranslateAction.getFloat("z");
  }
}

public class SetMovingLeftAction extends Action
{
  private IGameObject target;
  private boolean movingLeft;
  
  public SetMovingLeftAction()
  {
    super();
    
    target = null;
    movingLeft = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_MOVING_LEFT;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public void setMovingLeft(boolean _movingLeft)
  {
    movingLeft = _movingLeft;
  }
  
  @Override public void apply()
  {
    ((TranslateOverTimeComponent)target.getComponent(ComponentType.TRANSLATE_OVER_TIME)).setMovingLeft(movingLeft);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetMovingLeftAction = new JSONObject();
    
    jsonSetMovingLeftAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_MOVING_LEFT));
    jsonSetMovingLeftAction.setInt("uid", target.getUID());
    jsonSetMovingLeftAction.setBoolean("movingLeft", movingLeft);
    
    return jsonSetMovingLeftAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetMovingLeftAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonSetMovingLeftAction.getInt("uid"));
    movingLeft = jsonSetMovingLeftAction.getBoolean("movingLeft");
  }
}

public class SetMovingDownAction extends Action
{
  private IGameObject target;
  private boolean movingDown;
  
  public SetMovingDownAction()
  {
    super();
    
    target = null;
    movingDown = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_MOVING_DOWN;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public void setMovingDown(boolean _movingDown)
  {
    movingDown = _movingDown;
  }
  
  @Override public void apply()
  {
    ((TranslateOverTimeComponent)target.getComponent(ComponentType.TRANSLATE_OVER_TIME)).setMovingDown(movingDown);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetMovingDownAction = new JSONObject();
    
    jsonSetMovingDownAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_MOVING_DOWN));
    jsonSetMovingDownAction.setInt("uid", target.getUID());
    jsonSetMovingDownAction.setBoolean("movingDown", movingDown);
    
    return jsonSetMovingDownAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetMovingDownAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonSetMovingDownAction.getInt("uid"));
    movingDown = jsonSetMovingDownAction.getBoolean("movingDown");
  }
}

public class SetMovingForwardAction extends Action
{
  private IGameObject target;
  private boolean movingForward;
  
  public SetMovingForwardAction()
  {
    super();
    
    target = null;
    movingForward = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_MOVING_FORWARD;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public void setMovingForward(boolean _movingForward)
  {
    movingForward = _movingForward;
  }
  
  @Override public void apply()
  {
    ((TranslateOverTimeComponent)target.getComponent(ComponentType.TRANSLATE_OVER_TIME)).setMovingForward(movingForward);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetMovingForwardAction = new JSONObject();
    
    jsonSetMovingForwardAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_MOVING_FORWARD));
    jsonSetMovingForwardAction.setInt("uid", target.getUID());
    jsonSetMovingForwardAction.setBoolean("movingForward", movingForward);
    
    return jsonSetMovingForwardAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetMovingForwardAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonSetMovingForwardAction.getInt("uid"));
    movingForward = jsonSetMovingForwardAction.getBoolean("movingForward");
  }
}

public class RotateAction extends Action
{
  private IGameObject target;
  private PVector rotation;
  
  public RotateAction()
  {
    super();
    
    target = null;
    rotation = new PVector();
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.ROTATE;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public IGameObject getTarget()
  {
    return target;
  }
  
  public void setRotation(PVector _rotation)
  {
    rotation = _rotation;
  }
  
  public PVector getRotation()
  {
    return rotation;
  }
  
  @Override public void apply()
  {
    target.rotate(rotation);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonRotateAction = new JSONObject();
    
    jsonRotateAction.setString("ActionType", actionTypeEnumToString(ActionType.ROTATE));
    jsonRotateAction.setInt("uid", target.getUID());
    jsonRotateAction.setFloat("x", rotation.x);
    jsonRotateAction.setFloat("y", rotation.y);
    jsonRotateAction.setFloat("z", rotation.z);
    
    return jsonRotateAction;
  }
  
  @Override public void deserialize(JSONObject jsonRotateAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonRotateAction.getInt("uid"));
    rotation.x = jsonRotateAction.getFloat("x");
    rotation.y = jsonRotateAction.getFloat("y");
    rotation.z = jsonRotateAction.getFloat("z");
  }
}

public class ScaleAction extends Action
{
  private IGameObject target;
  private PVector scale;
  
  public ScaleAction()
  {
    super();
    
    target = null;
    scale = new PVector();
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SCALE;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public IGameObject getTarget()
  {
    return target;
  }
  
  public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  public PVector getScale()
  {
    return scale;
  }
  
  @Override public void apply()
  {
    target.scale(scale);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonScaleAction = new JSONObject();
    
    jsonScaleAction.setString("ActionType", actionTypeEnumToString(ActionType.SCALE));
    jsonScaleAction.setInt("uid", target.getUID());
    jsonScaleAction.setFloat("x", scale.x);
    jsonScaleAction.setFloat("y", scale.y);
    jsonScaleAction.setFloat("z", scale.z);
    
    return jsonScaleAction;
  }
  
  @Override public void deserialize(JSONObject jsonScaleAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonScaleAction.getInt("uid"));
    scale.x = jsonScaleAction.getFloat("x");
    scale.y = jsonScaleAction.getFloat("y");
    scale.z = jsonScaleAction.getFloat("z");
  }
}

public class SetXScalingUpAction extends Action
{
  private IGameObject target;
  private boolean xScalingUp;
  
  public SetXScalingUpAction()
  {
    super();
    
    target = null;
    xScalingUp = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_X_SCALING_UP;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public void setXScalingUp(boolean _xScalingUp)
  {
    xScalingUp = _xScalingUp;
  }
  
  @Override public void apply()
  {
    ((ScaleOverTimeComponent)target.getComponent(ComponentType.SCALE_OVER_TIME)).setXScalingUp(xScalingUp);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetXScalingUpAction = new JSONObject();
    
    jsonSetXScalingUpAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_X_SCALING_UP));
    jsonSetXScalingUpAction.setInt("uid", target.getUID());
    jsonSetXScalingUpAction.setBoolean("xScalingUp", xScalingUp);
    
    return jsonSetXScalingUpAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetXScalingUpAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonSetXScalingUpAction.getInt("uid"));
    xScalingUp = jsonSetXScalingUpAction.getBoolean("xScalingUp");
  }
}

public class SetYScalingUpAction extends Action
{
  private IGameObject target;
  private boolean yScalingUp;
  
  public SetYScalingUpAction()
  {
    super();
    
    target = null;
    yScalingUp = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_Y_SCALING_UP;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public void setYScalingUp(boolean _yScalingUp)
  {
    yScalingUp = _yScalingUp;
  }
  
  @Override public void apply()
  {
    ((ScaleOverTimeComponent)target.getComponent(ComponentType.SCALE_OVER_TIME)).setYScalingUp(yScalingUp);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetYScalingUpAction = new JSONObject();
    
    jsonSetYScalingUpAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_Y_SCALING_UP));
    jsonSetYScalingUpAction.setInt("uid", target.getUID());
    jsonSetYScalingUpAction.setBoolean("yScalingUp", yScalingUp);
    
    return jsonSetYScalingUpAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetYScalingUpAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonSetYScalingUpAction.getInt("uid"));
    yScalingUp = jsonSetYScalingUpAction.getBoolean("yScalingUp");
  }
}

public class SetZScalingUpAction extends Action
{
  private IGameObject target;
  private boolean zScalingUp;
  
  public SetZScalingUpAction()
  {
    super();
    
    target = null;
    zScalingUp = false;
  }
  
  @Override public ActionType getActionType()
  {
    return ActionType.SET_Y_SCALING_UP;
  }
  
  public void setTarget(IGameObject _target)
  {
    target = _target;
  }
  
  public void setZScalingUp(boolean _zScalingUp)
  {
    zScalingUp = _zScalingUp;
  }
  
  @Override public void apply()
  {
    ((ScaleOverTimeComponent)target.getComponent(ComponentType.SCALE_OVER_TIME)).setZScalingUp(zScalingUp);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonSetZScalingUpAction = new JSONObject();
    
    jsonSetZScalingUpAction.setString("ActionType", actionTypeEnumToString(ActionType.SET_Z_SCALING_UP));
    jsonSetZScalingUpAction.setInt("uid", target.getUID());
    jsonSetZScalingUpAction.setBoolean("zScalingUp", zScalingUp);
    
    return jsonSetZScalingUpAction;
  }
  
  @Override public void deserialize(JSONObject jsonSetZScalingUpAction)
  {
    target = gameStateController.getSharedGameObjectManager().getGameObject(jsonSetZScalingUpAction.getInt("uid"));
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