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