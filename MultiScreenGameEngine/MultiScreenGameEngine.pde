//======================================================================================================
// Author: David Hanna
//
// A Game Engine that extends networked multiplayer gaming to also accomodate each player
// with multiple screens.
//======================================================================================================

import java.util.ArrayList;
import java.util.Map;

int lastFrameTime;

ITextureManager textureManager;
IMaterialLibManager materialLibManager;
IGameObjectManager gameObjectManager;
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
  jsonGameWorld = gameObjectManager.serialize();
  
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
    k++;
  }
  else
  {
    gameObjectManager.deserialize(jsonGameWorld);
    gameObjectManager.update(deltaTime);
    k = 0;
  }
}