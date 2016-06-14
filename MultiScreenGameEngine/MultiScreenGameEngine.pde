//======================================================================================================
// Author: David Hanna
//
// A Game Engine that provides the utility to enable multiple screens of gameplay and interaction.
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
IEventManager eventManager;
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
  eventManager = new EventManager();
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
  println(deltaTime);
  
  //println(((com.jogamp.newt.opengl.GLWindow)surface.getNative()).getLocationOnScreen(null));
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
  
  gameStateController.update(deltaTime);
  eventManager.update();
}