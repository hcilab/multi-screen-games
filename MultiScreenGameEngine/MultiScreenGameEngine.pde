//======================================================================================================
// Author: David Hanna
//
// A Game Engine that extends networked multiplayer gaming to also accomodate each player
// with multiple screens.
//======================================================================================================

import java.util.ArrayList;
import java.util.Map;
import processing.net.*;

int lastFrameTime;

ITextureManager textureManager;
IMaterialLibManager materialLibManager;
IGameObjectManager gameObjectManager;
Server myServer;
Client myClient;

JSONArray jsonGameWorld;
int k = 0;

void setup()
{
  size(800, 600, P3D);
  surface.setResizable(true);
  
  textureManager = new TextureManager();
  
  materialLibManager = new MaterialLibManager();
  
  gameObjectManager = new GameObjectManager();
  gameObjectManager.fromXML("levels/sample_level.xml");
  
  myServer = new Server(this, 5204);
  myClient = new Client(this, "127.0.0.1", 5204);
  
  lastFrameTime = millis();
}

void draw()
{
  background(80);
  
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  if (deltaTime > 100)
  {
    deltaTime = 32;
  }
  println(deltaTime);
  
  if (k < 20)
  {
    gameObjectManager.update(deltaTime);
    k++;
  }
  else if (k == 20)
  {
    gameObjectManager.update(deltaTime);
    jsonGameWorld = gameObjectManager.serialize();
    myServer.write(jsonGameWorld.toString());
    k++;
  }
  else
  {
    if (myClient.available() > 0)
    {
      jsonGameWorld = JSONArray.parse(myClient.readString());
      if (jsonGameWorld != null)
      {
        gameObjectManager.deserialize(jsonGameWorld);
      }
    }
    gameObjectManager.update(deltaTime);
    k = 0;
  }
}