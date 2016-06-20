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
  public void write(String message);
  public void handleClientEvent(String serverBytes);
}

public interface IClientCallbackHandler
{
  public void handleServerMessage(String serverMessage);
}

public interface IServer
{
  public boolean begin();
  public void update();
  public void end();
  public boolean isActive();
  public void write(String message);
  public void handleServerEvent(Client pClient);
}

public interface IServerCallbackHandler
{
  public String getInitializationMessage();
  public void handleClientMessage(String clientMessage);
}

//----------------------------------------------------------------
// IMPLEMENTATION
//----------------------------------------------------------------

public final String BEGIN_TOKEN = ":::B:::";
public final String END_TOKEN = ":::E:::";

public void clientEvent(Client pClient)
{
  if (mainClient != null)
  {
    while (pClient.available() > 0)
    {
      mainClient.handleClientEvent(pClient.readString());
    }
  }
}

public class MSClient implements IClient
{
  private String ipAddress;
  private int port;
  private IClientCallbackHandler handler;
  private Client pClient;
  private String buffer;
  private int clientID;
  private int messageID;
  
  public MSClient(String _ipAddress, int _port, IClientCallbackHandler _handler)
  {
    ipAddress = _ipAddress;
    port = _port;
    handler = _handler;
    pClient = null;
    buffer = "";
    clientID = 0;
    messageID = 0;
  }
  
  @Override public boolean connect()
  {
    pClient = new Client(mainObject, ipAddress, port);
    if (isConnected())
    {
      return true;
    }
    else
    {
      pClient = null;
      return false;
    }
  }
  
  @Override public void update()
  {
    if (isConnected())
    {
      synchronized(this)
      {
        if (!buffer.startsWith(BEGIN_TOKEN) && buffer.length() > BEGIN_TOKEN.length())
        {
          int beginTokenIndex = buffer.indexOf(BEGIN_TOKEN);
          if (beginTokenIndex != -1)
          {
            buffer = buffer.substring(beginTokenIndex, buffer.length());
          }
        }
        
        while (buffer.startsWith(BEGIN_TOKEN))
        {
          int endTokenIndex = buffer.indexOf(END_TOKEN);
          if (endTokenIndex == -1)
          {
            break;
          }
          else
          {
            handler.handleServerMessage(buffer.substring(BEGIN_TOKEN.length(), endTokenIndex));
            buffer = buffer.substring(endTokenIndex + END_TOKEN.length(), buffer.length());
          }
        }
      }
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
  
  @Override public void write(String message)
  {
    JSONObject jsonMessageHeader = new JSONObject();
    jsonMessageHeader.setInt("clientID", clientID);
    jsonMessageHeader.setInt("messageID", messageID++);
    
    JSONObject jsonMessage = new JSONObject();
    jsonMessage.setJSONObject("header", jsonMessageHeader);
    jsonMessage.setString("body", message);
    
    if (isConnected())
    {
      pClient.write(BEGIN_TOKEN + jsonMessage.toString() + END_TOKEN);
    }
  }
  
  @Override public void handleClientEvent(String serverBytes)
  {
    synchronized(this)
    {
      buffer += serverBytes;
    }
  }
}

public void serverEvent(Server pServer, Client pClient)
{
  if (mainServer != null)
  {
    mainServer.handleServerEvent(pClient);
  }
}

public class MSServer implements IServer
{
  private int port;
  private IServerCallbackHandler handler;
  private Server pServer;
  private String buffer;
  
  public MSServer(int _port, IServerCallbackHandler _handler)
  {
    port = _port;
    handler = _handler;
    pServer = null;
    buffer = "";
  }
  
  @Override public boolean begin()
  {
    if (pServer == null)
    {
      pServer = new Server(mainObject, port);
      
      if (isActive())
      {
        return true;
      }
      else
      {
        pServer = null;
        return false;
      }
    }
    else
    {
      println("WARNING: Trying to begin a server that is already active.");
      return false;
    }
  }
  
  @Override public void update()
  {
    if (isActive())
    {
      Client pClient = pServer.available();
      
      if (pClient != null)
      {
        buffer += pClient.readString();
        
        if (!buffer.startsWith(BEGIN_TOKEN) && buffer.length() > BEGIN_TOKEN.length())
        {
          println("WARNING: There has been a protocol error: " + buffer);
          end();
        }
        
        while (buffer.startsWith(BEGIN_TOKEN))
        {
          int endTokenIndex = buffer.indexOf(END_TOKEN);
          if (endTokenIndex == -1)
          {
            break;
          }
          else
          {
            String clientMessage = buffer.substring(BEGIN_TOKEN.length(), endTokenIndex);
            
            JSONObject jsonClientMessage = JSONObject.parse(clientMessage);
            JSONObject jsonHeader = jsonClientMessage.getJSONObject("header");
            
            int clientID = jsonHeader.getInt("clientID");
            int messageID = jsonHeader.getInt("messageID");
            //println("clientID: " + clientID);
            //println("messageID: " + messageID);
            
            handler.handleClientMessage(jsonClientMessage.getString("body"));
            
            buffer = buffer.substring(endTokenIndex + END_TOKEN.length(), buffer.length());
          }
        }
      }
    }
  }
  
  @Override public void end()
  {
    if (isActive())
    {
      pServer.stop();
      pServer = null;
    }
  }
  
  @Override public boolean isActive()
  {
    return pServer != null && pServer.active();
  }
  
  @Override public void write(String message)
  {
    if (isActive())
    {
      pServer.write(BEGIN_TOKEN + message + END_TOKEN);
    }
  }
  
  @Override public void handleServerEvent(Client pClient)
  {
    pClient.write(BEGIN_TOKEN + handler.getInitializationMessage() + END_TOKEN);
  }
}