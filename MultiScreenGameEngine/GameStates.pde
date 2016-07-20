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

public class GameState_TestState extends GameState
{
  public GameState_TestState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    localGameObjectManager.fromXML("levels/pong/pong_level.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
    localGameObjectManager.update(deltaTime);
    scene.render();
    text("hello", 0, 0);
  }
  
  @Override public void onExit()
  {
    localGameObjectManager.clearGameObjects();
  }
}

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
  public GameState_ServerState()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    sharedGameObjectManager.fromXML("levels/box_example/shared_level.xml");
    
    mainServer = new MSServer(this);
    mainServer.begin();
  }
  
  @Override public void update(int deltaTime)
  {
    sharedGameObjectManager.update(deltaTime);
    scene.render();
    //mainServer.update();
    sendWorldToAllClients();
  }
  
  @Override public void onExit()
  {
    mainServer.end();
    mainServer = null;
  }
  
  @Override public void handleClientMessage(ByteBuffer clientMessage)
  {
  }
  
  private void sendWorldToAllClients()
  {
    FlatBufferBuilder builder = new FlatBufferBuilder(0);
    
    int flatGameWorld = sharedGameObjectManager.serialize(builder);
    
    FlatMessageHeader.startFlatMessageHeader(builder);
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
    localGameObjectManager.fromXML("levels/box_example/client_level_1.xml");
    
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
      //sendClientActionsToServer();
    }
    
    synchronized(sharedGameObjectManager)
    {
      scene.render();
    } //<>// //<>//
  }
  
  @Override public void onExit()
  {
    if (mainClient != null)
    {
      mainClient.disconnect();
      mainClient = null;
    }
  }
  
  @Override public void handleServerMessage(ByteBuffer serverMessage)
  {
    FlatMessage flatServerMessage = FlatMessage.getRootAsFlatMessage(serverMessage);
    int messageTargetID = flatServerMessage.header().clientID();
    
    if (messageTargetID == 0 || messageTargetID == clientID)
    {
      if (flatServerMessage.bodyTable().bodyType() == FlatMessageBodyUnion.FlatGameWorld)
      {
        FlatGameWorld flatGameWorld = (FlatGameWorld)flatServerMessage.bodyTable().body(new FlatGameWorld());
        
        synchronized(sharedGameObjectManager)
        {
          sharedGameObjectManager.deserialize(flatGameWorld);
          //println(sharedGameObjectManager);
        }
      }
      //else if (flatServerMessage.bodyTable().bodyType() == FlatMessageBodyUnion.FlatServerInitMessage)
      //{
      //  FlatServerInitMessage flatServerInitMessage = (FlatServerInitMessage)flatServerMessage.body().body(new FlatServerInitMessage());
        
      //  outgoingClient = new MSClient(flatServerInitMessage.ip(), flatServerInitMessage.port(), this);
      //  if (outgoingClient.connect())
      //  {
      //    println("Outgoing Client connected.");
      //  }
      //  else
      //  {
      //    println("Outgoing Client failed to connect.");
      //  }
      //}
    }
  }
} //<>// //<>//

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