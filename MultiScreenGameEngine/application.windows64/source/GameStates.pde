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

public class GameState_ClientState extends GameState
{
  private Client myClient;
  private String serverString;
  private ArrayList<IAction> actionBuffer;
  
  public GameState_ClientState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    sharedGameObjectManager.fromXML("levels/sample_level.xml");
    
    myClient = new Client(mainObject, "131.202.105.28", 5204);
    println("Client started.");
    
    serverString = "";
    
    actionBuffer = new ArrayList<IAction>();
  }
  
  @Override public void update(int deltaTime)
  {
    if (myClient.active())
    {
      for (IEvent event : eventManager.getEvents(EventType.ACTION))
      {
        actionBuffer.add(event.getRequiredActionParameter("action"));
      }
      
      if (myClient.available() > 0)
      {
        serverString += myClient.readString();
        JSONArray jsonGameWorld = JSONArray.parse(serverString);
        if (jsonGameWorld != null)
        {
          IGameObjectManager attempt = new GameObjectManager();
          attempt.deserialize(jsonGameWorld);
          sharedGameObjectManager = attempt;
          //for (IAction action : actionBuffer)
          //{
          //  action.apply();
          //}
          serverString = "";
        }
      }
    }
    
    sharedGameObjectManager.update(deltaTime);
    scene.render();
    
    if (myClient.active())
    {
      JSONArray jsonActions = new JSONArray();
      for (IAction action : actionBuffer)
      {
        jsonActions.append(action.serialize());
      }
      if (jsonActions.size() > 0)
      {
        myClient.write(jsonActions.toString());
      }
      actionBuffer.clear();
    }
  }
  
  @Override public void onExit()
  {
  }
}

public class GameState_ServerState extends GameState
{
  private Server myServer;
  private String clientString;
  private int timePassed;
  private final int TIME_TO_SEND;
  
  public GameState_ServerState()
  {
    super();
    
    TIME_TO_SEND = 100;
  }
  
  @Override public void onEnter()
  {
    sharedGameObjectManager.fromXML("levels/sample_level.xml");
    
    myServer = new Server(mainObject, 5204);
    println("Server started.");
    
    clientString = "";
    timePassed = 0;
  }
  
  @Override public void update(int deltaTime)
  {
    Client client = myServer.available();
    
    if (client != null)
    {
      clientString += client.readString();
      JSONArray jsonActionList = new JSONArray();
      while (jsonActionList != null)
      {
        JSONArrayParseResult parseResult = parseJSONArrayFromString(clientString);
        jsonActionList = parseResult.jsonArray;
        if (jsonActionList != null)
        {
          for (int i = 0; i < jsonActionList.size(); i++)
          {
            IAction action = deserializeAction(jsonActionList.getJSONObject(i));
            action.apply();
          }
          clientString = parseResult.remainingString;
        }
      }
    }
    
    timePassed += deltaTime;
    if (timePassed > TIME_TO_SEND)
    {
      myServer.write(sharedGameObjectManager.serialize().toString());
      
      timePassed = 0;
    }
  }
  
  @Override public void onExit()
  {
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
    if (stateStack.isEmpty())
    {
      exit();
    }
  }
  
  @Override public IGameState getCurrentState()
  {
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