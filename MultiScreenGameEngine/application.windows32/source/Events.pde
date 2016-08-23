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
  
  SPACEBAR_PRESSED,
  
  UP_BUTTON_RELEASED,
  DOWN_BUTTON_RELEASED,
  LEFT_BUTTON_RELEASED,
  RIGHT_BUTTON_RELEASED,
  
  W_BUTTON_RELEASED,
  A_BUTTON_RELEASED,
  S_BUTTON_RELEASED,
  D_BUTTON_RELEASED,
  
  SPACEBAR_RELEASED,
  
  CLIENT_ID_SET,
  
  CLIENT_CONTROLS,
  GOAL_SCORED,
  BALL_PLAYER_COLLISION,
  
  BALL_BLOCK_COLLISION,
  BALL_TANK_COLLISION,
  BALL_DELETED,
  CURRENT_TURN,
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
    
    addEventTypeToMaps(EventType.SPACEBAR_PRESSED);
    
    addEventTypeToMaps(EventType.UP_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.DOWN_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_RELEASED);
    
    addEventTypeToMaps(EventType.W_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.A_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.S_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.D_BUTTON_RELEASED);
    
    addEventTypeToMaps(EventType.SPACEBAR_RELEASED);
    
    addEventTypeToMaps(EventType.CLIENT_ID_SET);
    
    addEventTypeToMaps(EventType.CLIENT_CONTROLS);
    addEventTypeToMaps(EventType.GOAL_SCORED);
    addEventTypeToMaps(EventType.BALL_PLAYER_COLLISION);
    
    addEventTypeToMaps(EventType.BALL_BLOCK_COLLISION);
    addEventTypeToMaps(EventType.BALL_TANK_COLLISION);
    addEventTypeToMaps(EventType.BALL_DELETED);
    addEventTypeToMaps(EventType.CURRENT_TURN);
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