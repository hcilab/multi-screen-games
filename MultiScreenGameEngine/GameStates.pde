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
      if (key == 's' || key == 'S')
      {
        gameStateController.pushState(new GameState_ServerState());
      }
      else if (key == 'c' || key == 'C')
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
  private JSONArray jsonGameWorld;
  private int waitCount;
  private boolean cursorVisible;
  private Robot robot;
  
  public GameState_ClientState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    sharedGameObjectManager.fromXML("levels/sample_level.xml");
    
    myClient = new Client(mainObject, "131.202.105.30", 5204);
    println("Client started.");
    
    jsonGameWorld = null;
    waitCount = 0;
    cursorVisible = true;
    
    try
    {
      robot = new Robot();
    }
    catch (AWTException e) 
    {
      println(e);
      robot = null;
    }
  }
  
  @Override public void update(int deltaTime)
  {
    if (myClient.active() && myClient.available() > 0)
    {
      String jsonGameWorldString = new String();
      while (myClient.available() > 0)
      {
        jsonGameWorldString += myClient.readString();
      }
      try
      {
        jsonGameWorld = JSONArray.parse(jsonGameWorldString);
        if (jsonGameWorld != null)
        {
          IGameObjectManager attempt = new GameObjectManager();
          attempt.deserialize(jsonGameWorld);
          sharedGameObjectManager = attempt;
        }
      }
      catch (Exception e)
      {
        println("caught");
      }
      sharedGameObjectManager.update(deltaTime);
    }
    else if (waitCount > 20)
    {
      sharedGameObjectManager.update(deltaTime);
      jsonGameWorld = sharedGameObjectManager.serialize();
      if (myClient.active())
      {
        myClient.write(jsonGameWorld.toString());
      }
      waitCount = 0;
    }
    else
    {
      sharedGameObjectManager.update(deltaTime);
      waitCount++;
    }
    
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
  }
  
  @Override public void onExit()
  {
  }
}

public class GameState_ServerState extends GameState
{
  private Server myServer;
  
  public GameState_ServerState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    try
    {
      myServer = new Server(mainObject, 5204);
      println("Server started.");
    }
    catch (Exception e)
    {
      println(e);
    }
  }
  
  @Override public void update(int deltaTime)
  {
    Client client = myServer.available();
    
    if (client != null)
    {
      String message = client.readString();
      println("message: " + message);
      myServer.write(message);
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