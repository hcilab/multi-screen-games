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
  //Choose to become Server or Client
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
  private int nextClientID;
  private int physicsTime;
  //What the Serve does
  public GameState_ServerState()
  {
    super();
    //When each new client joins
    nextClientID = 1;
    physicsTime = 0;
  }
  
  @Override public void onEnter()
  {
    frameRate(20);
    sharedGameObjectManager.fromXML("levels/pong/server_level.xml");
    //sharedGameObjectManager.fromXML("levels/box_example/shared_level.xml");
    //sharedGameObjectManager.fromXML("levels/pong/small_level.xml");
    
    mainServer = new MSServer(this);
    mainServer.begin();
  }
  
  @Override public void update(int deltaTime)
  {
    physicsTime += deltaTime;
    while (physicsTime >= 30)
    {
      physicsWorld.step(0.030f, velocityIterations, positionIterations);
      physicsTime -= 30;
    }
    
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
    } //<>//
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
} //<>//

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
