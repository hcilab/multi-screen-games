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
  TRANSLATE,
  ROTATE,
  SCALE,
}

public interface IAction
{
  public int getTimeStamp();
  public ActionType getActionType();
  
  public void apply();
  public void undo();
  
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
      
    case ROTATE:
      return "rotate";
      
    case SCALE:
      return "scale";
      
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
      
    case "rotate":
      return ActionType.ROTATE;
      
    case "scale":
      return ActionType.SCALE;
      
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
  
  @Override public void undo()
  {
    target.translate(new PVector(-translation.x, -translation.y, -translation.z));
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
  
  @Override public void undo()
  {
    target.rotate(new PVector(-rotation.x, -rotation.y, -rotation.z));
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
  
  @Override public void undo()
  {
    target.scale(new PVector(-scale.x, -scale.y, -scale.z));
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

public IAction deserializeAction(JSONObject jsonAction)
{
  IAction action = null;
  
  ActionType actionType = actionTypeStringToEnum(jsonAction.getString("ActionType"));
  
  switch(actionType)
  {
    case TRANSLATE:
      action = new TranslateAction();
      break;
      
    case ROTATE:
      action = new RotateAction();
      break;
      
    case SCALE:
      action = new ScaleAction();
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