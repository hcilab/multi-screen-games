//======================================================================================================
// Author: David Hanna
//
// A Game Engine that extends networked multiplayer gaming to also accomodate each player
// with multiple screens.
//======================================================================================================

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.MouseInfo;
import processing.net.Client;
import processing.net.Server;

MultiScreenGameEngine mainObject;
ITextureManager textureManager;
IMaterialLibManager materialLibManager;
IScene scene;
IGameStateController gameStateController;

int lastFrameTime;

void setup()
{
  size(800, 600, P3D);
  surface.setResizable(true);
  
  mainObject = this;
  textureManager = new TextureManager();
  materialLibManager = new MaterialLibManager(); 
  scene = new Scene();
  gameStateController = new GameStateController();
  gameStateController.pushState(new GameState_ChooseClientServerState());
  
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
  
  //println(((com.jogamp.newt.opengl.GLWindow)surface.getNative()).getLocationOnScreen(null));
  
  gameStateController.update(deltaTime);
  
  scene.render();
}