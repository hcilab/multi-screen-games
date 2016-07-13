//===============================================================================================================
// Author: David Hanna
//
// Classes embodying clients and servers for networking.
//===============================================================================================================

//----------------------------------------------------------------
// INTERFACE
//----------------------------------------------------------------

IClient mainClient = null;
IServer mainServer = null;

public interface IClient
{
  public boolean connect();
  public void update();
  public void disconnect();
  public boolean isConnected();
  public void write(ByteBuffer message);
}

public interface IClientCallbackHandler
{
  public void handleServerMessage(ByteBuffer serverMessage);
}

public interface IServer
{
  public boolean begin();
  public void update();
  public void end();
  public boolean isActive();
  public void write(ByteBuffer message);
  public void handleServerEvent(Server p_pServer, Client p_pClient);
}

public interface IServerCallbackHandler
{
  public void handleClientMessage(ByteBuffer clientMessage);
}

//----------------------------------------------------------------
// IMPLEMENTATION
//----------------------------------------------------------------

public final String MAIN_SERVER_IP = "127.0.0.1";
public final int MAIN_SERVER_PORT = 5204;

public final byte[] BEGIN_SEQUENCE = { 55, -45, 95, -44, 28, -74, -65, -66 };
public final byte[] END_SEQUENCE = { -72, 107, -85, -117, 45, -123, 69, 20 };
public final byte[] SUB_SERVER_CONNECT_SEQUENCE = { 108, 85, 57, 60, 93, 0, -15, -113 };
public final int TIME_OUT_LIMIT = 6000;


public class CircularByteBuffer
{
  protected byte[] buffer;
  protected int bufferHead;
  protected int bufferTail;
  
  public CircularByteBuffer(int size)
  {
    buffer = new byte[size];
    bufferHead = 0;
    bufferTail = 0;
  }
  
  synchronized public void append(byte[] bytes, int length)
  {
    for (int i = 0; i < length; i++)
    {
      buffer[bufferTail] = bytes[i];
      bufferTail = (bufferTail + 1) % buffer.length;
      assert(bufferTail != bufferHead);
    }
  }
  
  synchronized public void advanceHead(int length)
  {
    bufferHead = (bufferHead + length) % buffer.length;
  }
  
  synchronized public void clear()
  {
    bufferHead = bufferTail;
  }
  
  synchronized public int size()
  {
    if (bufferTail >= bufferHead)
    {
      return bufferTail - bufferHead;
    }
    else
    {
      return buffer.length + bufferTail - bufferHead;
    }
  }
  
  synchronized public byte[] getCurrentContents()
  {
    return getCurrentContents(size());
  }
  
  synchronized public byte[] getCurrentContents(int maxLength)
  {
    int contentsLength = min(size(), maxLength);
    byte[] contents = new byte[contentsLength];
    
    for (int i = 0; i < contentsLength; i++)
    {
      contents[i] = buffer[(bufferHead + i) % buffer.length];
    }
    
    return contents;
  }
  
  synchronized public boolean beginsWith(byte[] sequence)
  {
    for (int i = 0; i < sequence.length; i++)
    {
      int pos = (bufferHead + i) % buffer.length;
      
      if ((pos == (bufferTail + 1) % buffer.length) || buffer[pos] != sequence[i])
      {
        return false;
      }
    }
    
    return true;
  }
  
  synchronized public int indexOf(byte[] sequence)
  {
    int sequenceIndex = -1;
    
    byte[] contents = getCurrentContents();
    
    int i = 0;
    
    while (sequenceIndex == -1 && i <= contents.length - sequence.length)
    {
      if (contents[i] == sequence[0])
      {
        int j = 1;
        
        while (sequenceIndex == -1 && i + j < contents.length && contents[i + j] == sequence[j])
        {
          j++;
          
          if (j == sequence.length)
          {
            sequenceIndex = i;
          }
        }
      }
      
      i++;
    }
    
    return sequenceIndex;
  }
}


public class NetworkCircularByteBuffer extends CircularByteBuffer
{
  private static final int TEMP_BUFFER_SIZE = 1024;
  
  private byte[] tempBuffer;
  private boolean beginSequenceChecked;
  
  public NetworkCircularByteBuffer(int size)
  {
    super(size);
    
    tempBuffer = new byte[TEMP_BUFFER_SIZE];
    beginSequenceChecked = false;
  }
  
  synchronized public byte[] parseMessageLoop(Client pClient)
  {
    if (pClient.available() > 0)
    {
      int length = pClient.readBytes(tempBuffer);
      
      append(tempBuffer, length);
    }
    
    if (!beginSequenceChecked)
    {
      if (size() >= BEGIN_SEQUENCE.length)
      {
        beginSequenceChecked = beginsWith(BEGIN_SEQUENCE);
        
        if (beginSequenceChecked)
        {
          advanceHead(BEGIN_SEQUENCE.length);
        }
        else
        {
          byte[] firstByteOfBeginSequence = { BEGIN_SEQUENCE[0] };
          int indexOfFirstByteOfBeginSequence = indexOf(firstByteOfBeginSequence);
          
          if (indexOfFirstByteOfBeginSequence == -1)
          {
            clear();
          }
          else
          {
            advanceHead(indexOfFirstByteOfBeginSequence);
          }
        }
      }
    }
    
    if (beginSequenceChecked)
    {
      int endSequenceIndex = indexOf(END_SEQUENCE);
      
      if (endSequenceIndex != -1)
      {
        byte[] message = getCurrentContents(endSequenceIndex);
        advanceHead(message.length + END_SEQUENCE.length);
        beginSequenceChecked = false;
        
        return message;
      }
    }
    
    return null;
  }
}


public class MSClient implements IClient
{
  private static final int BUFFER_SIZE = 102400;
  
  private Client pClient;
  private NetworkCircularByteBuffer circularBuffer;
  private IClientCallbackHandler handler;
  
  
  public MSClient(IClientCallbackHandler _handler)
  {
    pClient = null;
    circularBuffer = new NetworkCircularByteBuffer(BUFFER_SIZE);
    handler = _handler;
  }
  
  @Override public boolean connect()
  {
    pClient = new Client(mainObject, MAIN_SERVER_IP, MAIN_SERVER_PORT);
    
    if (!pClient.active())
    {
      println("Failed to connect to main server.");
      pClient = null;
      return false;
    }
    
    boolean connected = redirectConnectionToSubServer();
    
    if (!connected)
    {
      println("Failed to connect to sub server.");
      return false;
    }
    
    println("Client connected.");
    return true;
  }
  
  private boolean redirectConnectionToSubServer()
  {
    int initialTime = millis();
    int currentTime = initialTime;
    
    while (currentTime - initialTime < TIME_OUT_LIMIT)
    {
      byte[] message = circularBuffer.parseMessageLoop(pClient);
      
      if (message != null && connectToSubServerMessageCheck(message))
      {
        int subServerPort = parsePort(message);
        
        pClient.stop();
        pClient = new Client(mainObject, MAIN_SERVER_IP, subServerPort);
        
        if (pClient.active())
        {
          return true;
        }
        else
        {
          println("Failed to connect to given sub server port.");
          pClient = null;
          return false;
        }
      }
      
      currentTime = millis();
    }
    
    pClient = null;
    return false;
  }
  
  private boolean connectToSubServerMessageCheck(byte[] message)
  {
    if (message.length < SUB_SERVER_CONNECT_SEQUENCE.length)
    {
      return false;
    }
    
    for (int i = 0; i < SUB_SERVER_CONNECT_SEQUENCE.length; i++)
    {
      if (message[i] != SUB_SERVER_CONNECT_SEQUENCE[i])
      {
        return false;
      }
    }
    
    return true;
  }
  
  private int parsePort(byte[] message)
  {
    byte[] portBytes = new byte[4];
    
    portBytes[0] = message[SUB_SERVER_CONNECT_SEQUENCE.length];
    portBytes[1] = message[SUB_SERVER_CONNECT_SEQUENCE.length + 1];
    portBytes[2] = message[SUB_SERVER_CONNECT_SEQUENCE.length + 2];
    portBytes[3] = message[SUB_SERVER_CONNECT_SEQUENCE.length + 3];
    
    ByteBuffer portByteBuffer = ByteBuffer.wrap(portBytes);
    
    return portByteBuffer.getInt();
  }
  
  @Override public void update()
  {
    byte[] message = null;
    ArrayList<byte[]> messageList = new ArrayList<byte[]>();
    
    do
    {
      message = circularBuffer.parseMessageLoop(pClient);
      
      if (message != null)
      {
        messageList.add(message);
      }
    }
    while (message != null);
    
    if (messageList.size() > 0)
    {
      handler.handleServerMessage(ByteBuffer.wrap(messageList.get(messageList.size() - 1)));
    }
  }
  
  @Override public void disconnect()
  {
    if (isConnected())
    {
      pClient.stop();
      pClient = null;
    }
  }
  
  @Override public boolean isConnected()
  {
    return pClient != null && pClient.active();
  }
  
  @Override public void write(ByteBuffer message)
  {
    if (isConnected())
    {
      byte[] bytes = new byte[message.remaining() + BEGIN_SEQUENCE.length + END_SEQUENCE.length];
      for (int i = 0; i < BEGIN_SEQUENCE.length; i++)
      {
        bytes[i] = BEGIN_SEQUENCE[i];
      }
      message.get(bytes, BEGIN_SEQUENCE.length, message.remaining());
      for (int i = 0; i < END_SEQUENCE.length; i++)
      {
        bytes[bytes.length - i - 1] = END_SEQUENCE[END_SEQUENCE.length - i - 1];
      }
      
      pClient.write(bytes);
    }
  }
}

public void serverEvent(Server p_pServer, Client p_pClient)
{
  mainServer.handleServerEvent(p_pServer, p_pClient);
}

public class MSServer implements IServer
{
  private Server pServer;
  private HashMap<Server, SubServer> subServers;
  private IServerCallbackHandler handler;
  
  private int nextSubServerPort;
  
  
  public MSServer(IServerCallbackHandler _handler)
  {
    pServer = null;
    subServers = new HashMap<Server, SubServer>();
    handler = _handler;
    
    nextSubServerPort = MAIN_SERVER_PORT + 1;
  }
  
  @Override public boolean begin()
  {
    if (pServer == null)
    {
      pServer = new Server(mainObject, MAIN_SERVER_PORT);
      
      if (isActive())
      {
        println("Server started.");
      }
      else
      {
        println("Server failed to start.");
        pServer = null;
        return false;
      }
    }
    
    return true;
  }
  
  @Override public void update()
  {
    if (isActive())
    {
      for (Map.Entry entry : subServers.entrySet())
      {
        SubServer subServer = (SubServer)entry.getValue();
        subServer.update();
      }
    }
  }
  
  @Override public void end()
  {
    if (isActive())
    {
      for (Map.Entry entry : subServers.entrySet())
      {
        SubServer subServer = (SubServer)entry.getValue();
        subServer.stop();
      }
      pServer.stop();
      pServer = null;
    }
  }
  
  @Override public boolean isActive()
  {
    return pServer != null && pServer.active();
  }
  
  @Override public void write(ByteBuffer message)
  {
    if (isActive())
    {
      byte[] bytes = new byte[message.remaining()];
      message.get(bytes);
      byte[] completeMessage = attachBeginAndEndSequencesToMessage(bytes);
      
      synchronized(this)
      {
        for (Map.Entry entry : subServers.entrySet())
        {
          SubServer subServer = (SubServer)entry.getValue();
          subServer.write(completeMessage);
        }
      }
    }
  }
  
  private byte[] attachBeginAndEndSequencesToMessage(byte[] message)
  {
    byte[] bytes = new byte[message.length + BEGIN_SEQUENCE.length + END_SEQUENCE.length];
    
    for (int i = 0; i < BEGIN_SEQUENCE.length; i++)
    {
      bytes[i] = BEGIN_SEQUENCE[i];
    }
    
    for (int i = 0; i < message.length; i++)
    {
      bytes[BEGIN_SEQUENCE.length + i] = message[i];
    }
    
    for (int i = 0; i < END_SEQUENCE.length; i++)
    {
      bytes[bytes.length - i - 1] = END_SEQUENCE[END_SEQUENCE.length - i - 1];
    }
    
    return bytes;
  }
  
  @Override public void handleServerEvent(Server p_pServer, Client p_pClient)
  {
    if (p_pServer == pServer)
    {
      synchronized(this)
      {
        spawnNewSubServer(nextSubServerPort);
        sendConnectionRedirectMessage(p_pClient);
        nextSubServerPort++;
      }
    }
    else
    {
      SubServer subServer = subServers.get(p_pServer);
      if (subServer != null)
      {
        subServer.handleServerEvent(p_pClient);
      }
    }
  }
  
  private void spawnNewSubServer(int nextSubServerPort)
  {
    SubServer subServer = new SubServer(this, nextSubServerPort);
    subServers.put(subServer.pServer, subServer);
  }
  
  private void sendConnectionRedirectMessage(Client p_pClient)
  {
    byte[] connectToMessage = new byte[SUB_SERVER_CONNECT_SEQUENCE.length + 4];
    
    for (int i = 0; i < SUB_SERVER_CONNECT_SEQUENCE.length; i++)
    {
      connectToMessage[i] = SUB_SERVER_CONNECT_SEQUENCE[i];
    }
    
    byte[] portAsBytes = new byte[] {
            (byte)(nextSubServerPort >>> 24),
            (byte)(nextSubServerPort >>> 16),
            (byte)(nextSubServerPort >>> 8),
            (byte)nextSubServerPort
    };
    
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length] = portAsBytes[0];
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length + 1] = portAsBytes[1];
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length + 2] = portAsBytes[2];
    connectToMessage[SUB_SERVER_CONNECT_SEQUENCE.length + 3] = portAsBytes[3];
    
    p_pClient.write(attachBeginAndEndSequencesToMessage(connectToMessage));
  }
  
  public IServerCallbackHandler getHandler()
  {
    return handler;
  }
  
  private class SubServer
  {
    private static final int SUB_SERVER_BUFFER_SIZE = 10240;
    
    private MSServer mainServer;
    private Client pClient;
    private NetworkCircularByteBuffer circularBuffer;
    
    public Server pServer;
    
    
    public SubServer(MSServer _mainServer, int subServerPort)
    {
      mainServer = _mainServer;
      pClient = null;
      circularBuffer = new NetworkCircularByteBuffer(SUB_SERVER_BUFFER_SIZE);
      
      pServer = new Server(mainObject, subServerPort);
    }
    
    public void handleServerEvent(Client p_pClient)
    {
      assert(pClient == null);
      pClient = p_pClient;
    }
    
    public void update()
    {
      byte[] message = circularBuffer.parseMessageLoop(pClient);
      if (message != null)
      {
        mainServer.getHandler().handleClientMessage(ByteBuffer.wrap(message));
      }
    }
    
    public void write(byte[] message)
    {
      if (isConnected())
      {
        pClient.write(message);
      }
    }
    
    public boolean isConnected()
    {
      return pClient != null && pClient.active();
    }
    
    public void stop()
    {
      pServer.stop();
    }
  }
}