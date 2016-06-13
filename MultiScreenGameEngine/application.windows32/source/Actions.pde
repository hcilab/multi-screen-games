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
  
  public JSONObject serialize();
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
  @Override public JSONObject serialize()
  {
    return new JSONObject();
  }
}

public class RotateAction extends Action
{
  @Override public JSONObject serialize()
  {
    return new JSONObject();
  }
}

public class ScaleAction extends Action
{
  @Override public JSONObject serialize()
  {
    return new JSONObject();
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
  
  return action;
}