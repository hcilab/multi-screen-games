//======================================================================================================
// Author: David Hanna
//
// A Game Engine that provides the utility to enable multiple screens of gameplay and interaction.
//======================================================================================================

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map;

import processing.net.Client;
import processing.net.Server;

import com.google.flatbuffers.FlatBufferBuilder;
import java.nio.ByteBuffer; 
import msge.std.*;

import java.awt.Robot;
import java.awt.AWTException;
import java.awt.MouseInfo;

import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.Contact;
import org.jbox2d.collision.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.callbacks.ContactImpulse;

MultiScreenGameEngine mainObject;
IEventManager eventManager;
Vec2 gravity;
World physicsWorld;
PhysicsContactListener contactListener;
int velocityIterations;    // Fewer iterations increases performance but accuracy suffers.
int positionIterations;    // More iterations decreases performance but improves accuracy.
                           // Box2D recommends 8 for velocity and 3 for position.
IMaterialManager materialManager;
ISpriteManager spriteManager;
IModelManager modelManager;
IFontManager fontManager;
IScene scene;
IGameStateController gameStateController;

int lastFrameTime;

void setup()
{
  size(500, 500, P3D);
  surface.setResizable(true);
  
  frameRate(20);
  mainObject = this;
  eventManager = new EventManager();
  gravity = new Vec2(0.0, 10.0);
  physicsWorld = new World(gravity); // gravity
  contactListener = new PhysicsContactListener();
  physicsWorld.setContactListener(contactListener);
  velocityIterations = 3;  // Our simple games probably don't need as much iteration.
  positionIterations = 1;
  materialManager = new MaterialManager();
  spriteManager = new SpriteManager();
  modelManager = new ModelManager();
  fontManager = new FontManager();
  scene = new Scene();
  gameStateController = new GameStateController();
  
  spriteManager.loadAllSprites();
  //modelManager.loadAllModels();
  gameStateController.pushState(new GameState_ChooseClientServerState());
  
  lastFrameTime = millis();
}

void draw()
{
  background(200);
  
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  //if (deltaTime > 100)
  //{
  //  deltaTime = 32;
  //}
  //println(deltaTime);
  
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

void exit()
{
  while (gameStateController.getCurrentState() != null)
  {
    gameStateController.popState();
  }
  super.exit();
}

void keyPressed()
{
  Event event;
  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case UP:
        event = new Event(EventType.UP_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case LEFT:
        event = new Event(EventType.LEFT_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case RIGHT:
        event = new Event(EventType.RIGHT_BUTTON_PRESSED);
        eventManager.queueEvent(event); 
        return;
      case DOWN:
        event = new Event(EventType.DOWN_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
    }
  }
  else
  {
    switch (key)
    {
      case 'w':
        event = new Event(EventType.W_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case 'a':
        event = new Event(EventType.A_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case 's':
        event = new Event(EventType.S_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case 'd':
        event = new Event(EventType.D_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
    }
  }
}

void keyReleased()
{
  Event event;
  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case UP:
        event = new Event(EventType.UP_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case LEFT:
        event = new Event(EventType.LEFT_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case RIGHT:
        event = new Event(EventType.RIGHT_BUTTON_RELEASED);
        eventManager.queueEvent(event); 
        return;
      case DOWN:
        event = new Event(EventType.DOWN_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
    }
  }
  else
  {
    switch (key)
    {
      case 'w':
        event = new Event(EventType.W_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case 'a':
        event = new Event(EventType.A_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case 's':
        event = new Event(EventType.S_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case 'd':
        event = new Event(EventType.D_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
    }
  }
}

class PhysicsContactListener implements ContactListener
{
  @Override public void beginContact(Contact contact)
  {
    IGameObject objectA = (IGameObject)contact.getFixtureA().getUserData();
    IGameObject objectB = (IGameObject)contact.getFixtureB().getUserData();
    
    RigidBodyComponent rigidBodyA = (RigidBodyComponent)objectA.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyB = (RigidBodyComponent)objectB.getComponent(ComponentType.RIGID_BODY);
    
    rigidBodyA.onCollisionEnter(objectB);
    rigidBodyB.onCollisionEnter(objectA);
  }
  
  @Override public void endContact(Contact contact)
  {
  }
  
  @Override public void preSolve(Contact contact, Manifold oldManifold)
  {
  }
  
  @Override public void postSolve(Contact contact, ContactImpulse impulse)
  {
  }
}