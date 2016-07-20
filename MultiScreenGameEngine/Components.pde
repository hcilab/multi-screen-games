 //======================================================================================================
// Author: David Hanna
//
// Components are attached to Game Objects to provide their data and behaviour.
//======================================================================================================

//-------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------

public enum ComponentType
{
  RENDER,
  RIGID_BODY,
  PERSPECTIVE_CAMERA,
  ORTHOGRAPHIC_CAMERA,
  TRANSLATE_OVER_TIME,
  ROTATE_OVER_TIME,
  SCALE_OVER_TIME,
  BOX_PADDLE_CONTROLLER,
  CIRCLE_PADDLE_CONTROLLER,
  BALL_CONTROLLER,
  GOAL_LISTENER,
}

public interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
  public String          toString();
}

public interface INetworkComponent extends IComponent
{
  public int             serialize(FlatBufferBuilder builder);
  public void            deserialize(com.google.flatbuffers.Table componentTable);
}


//-----------------------------------------------------------------
// IMPLEMENTATION
//-----------------------------------------------------------------

public String componentTypeEnumToString(ComponentType componentType)
{
  switch(componentType)
  {
    case RENDER:
      return "render";
      
    case RIGID_BODY:
      return "rigidBody";
      
    case PERSPECTIVE_CAMERA:
      return "perspectiveCamera";
      
    case ORTHOGRAPHIC_CAMERA:
      return "orthographicCamera";
      
    case TRANSLATE_OVER_TIME:
      return "translateOverTime";
      
    case ROTATE_OVER_TIME:
      return "rotateOverTime";
      
    case SCALE_OVER_TIME:
      return "scaleOverTime";
      
    case BOX_PADDLE_CONTROLLER:
      return "boxPaddleController";
      
    case CIRCLE_PADDLE_CONTROLLER:
      return "circlePaddleController";
      
    case BALL_CONTROLLER:
      return "ballController";
      
    case GOAL_LISTENER:
      return "goalListener";
      
    default:
      println("Assertion: ComponentType not added to EnumToString.");
      assert(false);
      return null;
  }
}

public ComponentType componentTypeStringToEnum(String componentType)
{
  switch(componentType)
  {
    case "render":
      return ComponentType.RENDER;
      
    case "rigidBody":
      return ComponentType.RIGID_BODY;
      
    case "perspectiveCamera":
      return ComponentType.PERSPECTIVE_CAMERA;
      
    case "orthographicCamera":
      return ComponentType.ORTHOGRAPHIC_CAMERA;
      
    case "translateOverTime":
      return ComponentType.TRANSLATE_OVER_TIME;
      
    case "rotateOverTime":
      return ComponentType.ROTATE_OVER_TIME;
      
    case "scaleOverTime":
      return ComponentType.SCALE_OVER_TIME;
      
    case "boxPaddleController":
      return ComponentType.BOX_PADDLE_CONTROLLER;
      
    case "circlePaddleController":
      return ComponentType.CIRCLE_PADDLE_CONTROLLER;
      
    case "ballController":
      return ComponentType.BALL_CONTROLLER;
      
    case "goalListener":
      return ComponentType.GOAL_LISTENER;
      
    default:
      println("Assertion: String not mapped to a ComponentType.");
      assert(false);
      return null;
  }
}

public abstract class Component implements IComponent
{
  protected IGameObject gameObject;
  
  public Component(IGameObject _gameObject)
  {
    gameObject = _gameObject;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  // There is no need to change this in subclasses.
  @Override final public IGameObject getGameObject()
  {
    return gameObject; 
  }
  
  @Override public void update(int deltaTime)
  {
  }
}


public abstract class NetworkComponent extends Component implements INetworkComponent
{
  public NetworkComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
}


public class RenderComponent extends NetworkComponent
{
  ArrayList<Integer> spriteHandles;
  ArrayList<PVector> spriteTranslationOffsets;
  ArrayList<PVector> spriteRotationOffsets;
  ArrayList<PVector> spriteScaleOffsets;
  
  ArrayList<Integer> modelHandles;
  ArrayList<PVector> modelTranslationOffsets;
  ArrayList<PVector> modelRotationOffsets;
  ArrayList<PVector> modelScaleOffsets;
  
  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    spriteHandles = new ArrayList<Integer>();
    spriteTranslationOffsets = new ArrayList<PVector>();
    spriteRotationOffsets = new ArrayList<PVector>();
    spriteScaleOffsets = new ArrayList<PVector>();
    
    modelHandles = new ArrayList<Integer>();
    modelTranslationOffsets = new ArrayList<PVector>();
    modelRotationOffsets = new ArrayList<PVector>();
    modelScaleOffsets = new ArrayList<PVector>();
  }
  
  @Override public void destroy()
  {
    for (Integer handle : spriteHandles)
    {
      scene.removeSpriteInstance(handle);
    }
    for (Integer handle : modelHandles)
    {
      scene.removeModelInstance(handle);
    }
    
    spriteHandles.clear();
    spriteTranslationOffsets.clear();
    spriteRotationOffsets.clear();
    spriteScaleOffsets.clear();
    
    modelHandles.clear();
    modelTranslationOffsets.clear();
    modelRotationOffsets.clear();
    modelScaleOffsets.clear();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlSubComponent : xmlComponent.getChildren())
    {
      if (xmlSubComponent.getName().equals("Sprite"))
      {
        ISpriteInstance sprite = new SpriteInstance(xmlSubComponent.getString("name"));
        
        XML xmlTranslationOffset = xmlSubComponent.getChild("Translation");
        spriteTranslationOffsets.add(new PVector(xmlTranslationOffset.getFloat("x"), xmlTranslationOffset.getFloat("y"), xmlTranslationOffset.getFloat("z")));
        
        XML xmlRotationOffset = xmlSubComponent.getChild("Rotation");
        spriteRotationOffsets.add(new PVector(xmlRotationOffset.getFloat("x"), xmlRotationOffset.getFloat("y"), xmlRotationOffset.getFloat("z")));
        
        XML xmlScaleOffset = xmlSubComponent.getChild("Scale");
        spriteScaleOffsets.add(new PVector(xmlScaleOffset.getFloat("x"), xmlScaleOffset.getFloat("y"), xmlScaleOffset.getFloat("z")));
        
        XML xmlTint = xmlSubComponent.getChild("Tint");
        sprite.setTint(new PVector(xmlTint.getFloat("r"), xmlTint.getFloat("g"), xmlTint.getFloat("b")));
        sprite.setAlpha(xmlTint.getFloat("a"));
        
        spriteHandles.add(scene.addSpriteInstance(sprite));
      }
      else if (xmlSubComponent.getName().equals("Model"))
      {
        IModelInstance modelInstance = new ModelInstance(xmlSubComponent.getString("name"));
        
        XML xmlTranslationOffset = xmlSubComponent.getChild("Translation");
        modelTranslationOffsets.add(new PVector(xmlTranslationOffset.getFloat("x"), xmlTranslationOffset.getFloat("y"), xmlTranslationOffset.getFloat("z")));
        
        XML xmlRotationOffset = xmlSubComponent.getChild("Rotation");
        modelRotationOffsets.add(new PVector(xmlRotationOffset.getFloat("x"), xmlRotationOffset.getFloat("y"), xmlRotationOffset.getFloat("z")));
        
        XML xmlScaleOffset = xmlSubComponent.getChild("Scale");
        modelScaleOffsets.add(new PVector(xmlScaleOffset.getFloat("x"), xmlScaleOffset.getFloat("y"), xmlScaleOffset.getFloat("z")));
        
        modelHandles.add(scene.addModelInstance(modelInstance));
      }
    }
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int[] flatSprites = new int[spriteHandles.size()];
    for (int i = 0; i < spriteHandles.size(); i++)
    {
      flatSprites[i] = scene.getSpriteInstance(spriteHandles.get(i)).serialize(builder);
    }
    int flatSpritesVector = FlatRenderComponent.createSpritesVector(builder, flatSprites);
    
    FlatRenderComponent.startSpriteTranslationOffsetsVector(builder, spriteTranslationOffsets.size());
    for (int i = 0; i < spriteTranslationOffsets.size(); i++)
    {
      PVector translation = spriteTranslationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z);
    }
    int flatSpriteTranslationOffsets = builder.endVector();
    
    FlatRenderComponent.startSpriteRotationOffsetsVector(builder, spriteRotationOffsets.size());
    for (int i = 0; i < spriteRotationOffsets.size(); i++)
    {
      PVector rotation = spriteRotationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z);
    }
    int flatSpriteRotationOffsets = builder.endVector();
    
    FlatRenderComponent.startSpriteScaleOffsetsVector(builder, spriteScaleOffsets.size());
    for (int i = 0; i < spriteScaleOffsets.size(); i++)
    {
      PVector scale = spriteScaleOffsets.get(i);
      FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z);
    }
    int flatSpriteScaleOffsets = builder.endVector();
    
    int[] flatModels = new int[modelHandles.size()];
    for (int i = 0; i < modelHandles.size(); i++)
    {
      flatModels[i] = scene.getModelInstance(modelHandles.get(i)).serialize(builder);
    }
    int flatModelsVector = FlatRenderComponent.createModelsVector(builder, flatModels);
    
    FlatRenderComponent.startModelTranslationOffsetsVector(builder, modelTranslationOffsets.size());
    for (int i = 0; i < modelTranslationOffsets.size(); i++)
    {
      PVector translation = modelTranslationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z);
    }
    int flatModelTranslationOffsets = builder.endVector();
    
    FlatRenderComponent.startModelRotationOffsetsVector(builder, modelRotationOffsets.size());
    for (int i = 0; i < modelRotationOffsets.size(); i++)
    {
      PVector rotation = modelRotationOffsets.get(i);
      FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z);
    }
    int flatModelRotationOffsets = builder.endVector();
    
    FlatRenderComponent.startModelScaleOffsetsVector(builder, modelScaleOffsets.size());
    for (int i = 0; i < modelScaleOffsets.size(); i++)
    {
      PVector scale = modelScaleOffsets.get(i);
      FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z);
    }
    int flatModelScaleOffsets = builder.endVector();
    
    FlatRenderComponent.startFlatRenderComponent(builder);
    
    FlatRenderComponent.addSprites(builder, flatSpritesVector);
    FlatRenderComponent.addSpriteTranslationOffsets(builder, flatSpriteTranslationOffsets);
    FlatRenderComponent.addSpriteRotationOffsets(builder, flatSpriteRotationOffsets);
    FlatRenderComponent.addSpriteScaleOffsets(builder, flatSpriteScaleOffsets);
    
    FlatRenderComponent.addModels(builder, flatModelsVector);
    FlatRenderComponent.addModelTranslationOffsets(builder, flatModelTranslationOffsets);
    FlatRenderComponent.addModelRotationOffsets(builder, flatModelRotationOffsets);
    FlatRenderComponent.addModelScaleOffsets(builder, flatModelScaleOffsets);
    
    int flatRenderComponent = FlatRenderComponent.endFlatRenderComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatRenderComponent);
    FlatComponentTable.addComponent(builder, flatRenderComponent);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatRenderComponent flatRenderComponent = (FlatRenderComponent)componentTable;
    
    for (int i = 0; i < flatRenderComponent.spritesLength(); i++)
    {
      FlatSprite flatSprite = flatRenderComponent.sprites(i);
      ISpriteInstance spriteInstance = new SpriteInstance(flatSprite.spriteName());
      spriteInstance.deserialize(flatSprite);
      spriteHandles.add(scene.addSpriteInstance(spriteInstance));
    }
    
    for (int i = 0; i < flatRenderComponent.spriteTranslationOffsetsLength(); i++)
    {
      FlatVec3 flatSpriteTranslationOffset = flatRenderComponent.spriteTranslationOffsets(i);
      spriteTranslationOffsets.add(new PVector(flatSpriteTranslationOffset.x(), flatSpriteTranslationOffset.y(), flatSpriteTranslationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.spriteRotationOffsetsLength(); i++)
    {
      FlatVec3 flatSpriteRotationOffset = flatRenderComponent.spriteRotationOffsets(i);
      spriteRotationOffsets.add(new PVector(flatSpriteRotationOffset.x(), flatSpriteRotationOffset.y(), flatSpriteRotationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.spriteScaleOffsetsLength(); i++)
    {
      FlatVec3 flatSpriteScaleOffset = flatRenderComponent.spriteScaleOffsets(i);
      spriteScaleOffsets.add(new PVector(flatSpriteScaleOffset.x(), flatSpriteScaleOffset.y(), flatSpriteScaleOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.modelsLength(); i++)
    {
      FlatModel flatModel = flatRenderComponent.models(i);
      IModelInstance modelInstance = new ModelInstance(flatModel.modelName());
      modelInstance.deserialize(flatModel);
      modelHandles.add(scene.addModelInstance(modelInstance));
    }
    
    for (int i = 0; i < flatRenderComponent.modelTranslationOffsetsLength(); i++)
    {
      FlatVec3 flatModelTranslationOffset = flatRenderComponent.modelTranslationOffsets(i);
      modelTranslationOffsets.add(new PVector(flatModelTranslationOffset.x(), flatModelTranslationOffset.y(), flatModelTranslationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.modelRotationOffsetsLength(); i++)
    {
      FlatVec3 flatModelRotationOffset = flatRenderComponent.modelRotationOffsets(i);
      modelRotationOffsets.add(new PVector(flatModelRotationOffset.x(), flatModelRotationOffset.y(), flatModelRotationOffset.z()));
    }
    
    for (int i = 0; i < flatRenderComponent.modelScaleOffsetsLength(); i++)
    {
      FlatVec3 flatModelScaleOffset = flatRenderComponent.modelScaleOffsets(i);
      modelScaleOffsets.add(new PVector(flatModelScaleOffset.x(), flatModelScaleOffset.y(), flatModelScaleOffset.z()));
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (int i = 0; i < spriteHandles.size(); i++)
    {
      ISpriteInstance spriteInstance = scene.getSpriteInstance(spriteHandles.get(i));
      
      PVector translation = gameObject.getTranslation();
      PVector translationOffset = spriteTranslationOffsets.get(i);
      PVector adjustedTranslation = new PVector(translation.x + translationOffset.x, translation.y + translationOffset.y, translation.z + translationOffset.z);
      spriteInstance.setTranslation(adjustedTranslation);
      
      PVector rotation = gameObject.getRotation();
      PVector rotationOffset = spriteRotationOffsets.get(i);
      PVector adjustedRotation = new PVector(rotation.x + rotationOffset.x, rotation.y + rotationOffset.y, rotation.z + rotationOffset.z);
      spriteInstance.setRotation(adjustedRotation);
      
      PVector scale = gameObject.getScale();
      PVector scaleOffset = spriteScaleOffsets.get(i);
      PVector adjustedScale = new PVector(scale.x * scaleOffset.x, scale.y * scaleOffset.y, scale.z * scaleOffset.z);
      spriteInstance.setScale(adjustedScale);
    }
    
    for (int i = 0; i < modelHandles.size(); i++)
    {
      IModelInstance modelInstance = scene.getModelInstance(modelHandles.get(i));
      
      PVector translation = gameObject.getTranslation();
      PVector translationOffset = modelTranslationOffsets.get(i);
      PVector adjustedTranslation = new PVector(translation.x + translationOffset.x, translation.y + translationOffset.y, translation.z + translationOffset.z);
      modelInstance.setTranslation(adjustedTranslation);
      
      PVector rotation = gameObject.getRotation();
      PVector rotationOffset = modelRotationOffsets.get(i);
      PVector adjustedRotation = new PVector(rotation.x + rotationOffset.x, rotation.y + rotationOffset.y, rotation.z + rotationOffset.z);
      modelInstance.setRotation(adjustedRotation);
      
      PVector scale = gameObject.getScale();
      PVector scaleOffset = modelScaleOffsets.get(i);
      PVector adjustedScale = new PVector(scale.x * scaleOffset.x, scale.y * scaleOffset.y, scale.z * scaleOffset.z);
      modelInstance.setScale(adjustedScale);
    }
  }
  
  @Override public String toString()
  {
    String stringRenderComponent = "=========== RenderComponent ===========\n";
    
    for (Integer spriteHandle : spriteHandles)
    {
      ISpriteInstance spriteInstance = scene.getSpriteInstance(spriteHandle);
      stringRenderComponent += "\tSprite: " + spriteInstance.getSprite().getName() + "\n";
    }
    
    for (Integer modelHandle : modelHandles)
    {
      IModelInstance modelInstance = scene.getModelInstance(modelHandle);
      stringRenderComponent += "\tModel: " + modelInstance.getModel().getName() + "\n";
    }
    
    return stringRenderComponent;
  }
  
  public ArrayList<Integer> getSpriteHandles()
  {
    return spriteHandles;
  }
  
  public ArrayList<Integer> getModelHandles()
  {
    return modelHandles;
  }
}


public class RigidBodyComponent extends Component
{
  private class OnCollideEvent
  {
    public String collidedWith; 
    public EventType eventType; 
    public HashMap<String, String> eventParameters;
  } 
   
  private Body body; 
  public PVector latestForce; 
  private ArrayList<OnCollideEvent> onCollideEvents; 
 
  public RigidBodyComponent(IGameObject _gameObject) 
  { 
    super(_gameObject); 
 
    latestForce = new PVector(); 
    onCollideEvents = new ArrayList<OnCollideEvent>(); 
  } 
 
  @Override public void destroy() 
  { 
    physicsWorld.destroyBody(body); 
  }  
  
  @Override public void fromXML(XML xmlComponent)  
  {  
    BodyDef bodyDefinition = new BodyDef();
  
    String bodyType = xmlComponent.getString("type");  
    if (bodyType.equals("static")) 
    { 
      bodyDefinition.type = BodyType.STATIC;
    }  
    else if (bodyType.equals("kinematic"))  
    {  
      bodyDefinition.type = BodyType.KINEMATIC;  
    }  
    else if (bodyType.equals("dynamic"))  
    {  
      bodyDefinition.type = BodyType.DYNAMIC; 
    } 
    else  
    {
      print("Unknown rigid body type: " + bodyType);  
      assert(false);  
    }  
  
    bodyDefinition.position.set(pixelsToMeters(gameObject.getTranslation().x), pixelsToMeters(gameObject.getTranslation().y));  
    bodyDefinition.angle = gameObject.getRotation().z;
    bodyDefinition.linearDamping = xmlComponent.getFloat("linearDamping");  
    bodyDefinition.angularDamping = xmlComponent.getFloat("angularDamping");  
    bodyDefinition.gravityScale = xmlComponent.getFloat("gravityScale");  
    bodyDefinition.allowSleep = xmlComponent.getString("allowSleep").equals("true") ? true : false;  
    bodyDefinition.awake = xmlComponent.getString("awake").equals("true") ? true : false;  
    bodyDefinition.fixedRotation = xmlComponent.getString("fixedRotation").equals("true") ? true : false;  
    bodyDefinition.bullet = xmlComponent.getString("bullet").equals("true") ? true : false;  
    bodyDefinition.active = xmlComponent.getString("active").equals("true") ? true : false;  
    bodyDefinition.userData = gameObject;
    
 
    body = physicsWorld.createBody(bodyDefinition); 

    for (XML rigidBodyComponent : xmlComponent.getChildren())
    { 
      if (rigidBodyComponent.getName().equals("Fixture")) 
      {
        FixtureDef fixtureDef = new FixtureDef(); 
        fixtureDef.density = rigidBodyComponent.getFloat("density"); 
        fixtureDef.friction = rigidBodyComponent.getFloat("friction");
        fixtureDef.restitution = rigidBodyComponent.getFloat("restitution");
        fixtureDef.isSensor = rigidBodyComponent.getString("isSensor").equals("true") ? true : false;
        fixtureDef.filter.categoryBits = rigidBodyComponent.getInt("categoryBits");
        fixtureDef.filter.maskBits = rigidBodyComponent.getInt("maskBits");
        fixtureDef.userData = gameObject;

        for (XML xmlShape : rigidBodyComponent.getChildren()) 
        {  
          if (xmlShape.getName().equals("Shape"))  
          {  
            String shapeType = xmlShape.getString("type");  
  
            if (shapeType.equals("circle")) 
            { 
              CircleShape circleShape = new CircleShape(); 
              circleShape.m_p.set(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y")));
              circleShape.m_radius = pixelsToMeters(xmlShape.getFloat("radius")) * gameObject.getScale().x; 
                
              fixtureDef.shape = circleShape; 
            } 
            else if (shapeType.equals("box"))  
            {  
              PolygonShape boxShape = new PolygonShape();  
              boxShape.m_centroid.set(new Vec2(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y")))); 
              boxShape.setAsBox(
                pixelsToMeters(xmlShape.getFloat("halfWidth")) * gameObject.getScale().x,
                pixelsToMeters(xmlShape.getFloat("halfHeight")) * gameObject.getScale().y
              ); 
 
              fixtureDef.shape = boxShape;
            } 
            else 
            {
              print("Unknown fixture shape type: " + shapeType);
              assert(false);
            }
          }
        }
         
        body.createFixture(fixtureDef); 
      } 
      else if (rigidBodyComponent.getName().equals("OnCollideEvents")) 
      { 
        for (XML xmlOnCollideEvent : rigidBodyComponent.getChildren()) 
        { 
          if (xmlOnCollideEvent.getName().equals("Event")) 
          {
            OnCollideEvent onCollideEvent = new OnCollideEvent();
            onCollideEvent.collidedWith = xmlOnCollideEvent.getString("collidedWith"); 
             
            String stringEventType = xmlOnCollideEvent.getString("eventType"); 
            if (stringEventType.equals("GOAL_SCORED"))  
            {
              onCollideEvent.eventType = EventType.GOAL_SCORED; 
              onCollideEvent.eventParameters = new HashMap<String, String>(); 
              onCollideEvent.eventParameters.put("ballParameterName", xmlOnCollideEvent.getString("ballParameterName"));
            }
            //else if (stringEventType.equals("GAME_OVER"))
            //{
            //  onCollideEvent.eventType = EventType.GAME_OVER;
            //}
            //else if (stringEventType.equals("DESTROY_COIN"))
            //{
            //  onCollideEvent.eventType = EventType.DESTROY_COIN;
            //  onCollideEvent.eventParameters = new HashMap<String, String>();
            //  onCollideEvent.eventParameters.put("coinParameterName", xmlOnCollideEvent.getString("coinParameterName"));
            //}
            //else if (stringEventType.equals("PLAYER_PLATFORM_COLLISION"))
            //{
            //  onCollideEvent.eventType = EventType.PLAYER_PLATFORM_COLLISION;
            //  onCollideEvent.eventParameters = new HashMap<String, String>();
            //  onCollideEvent.eventParameters.put("platformParameterName", xmlOnCollideEvent.getString("platformParameterName"));
            //}
            
            onCollideEvents.add(onCollideEvent); 
          }  
        }  
      }  
    }  
  }
    
  @Override public ComponentType getComponentType() 
  {
    return ComponentType.RIGID_BODY;
  } 
    
  @Override public void update(int deltaTime)  
  {  
    // Reverse sync the physically simulated position to the Game Object position.  
    gameObject.setTranslation(new PVector(metersToPixels(body.getPosition().x), metersToPixels(body.getPosition().y)));  
  }
 
  public void onCollisionEnter(IGameObject collider)
  {
    for (OnCollideEvent onCollideEvent : onCollideEvents)
    {
      if (onCollideEvent.collidedWith.equals(collider.getTag()))  
      {
        if (onCollideEvent.eventType == EventType.GOAL_SCORED)  
        {
          Event event = new Event(EventType.GOAL_SCORED);  
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("ballParameterName"), collider);  
          eventManager.queueEvent(event);
        }
        //else if (onCollideEvent.eventType == EventType.GAME_OVER)  
        //{  
        //  eventManager.queueEvent(new Event(EventType.GAME_OVER));  
        //}  
        //else if (onCollideEvent.eventType == EventType.DESTROY_COIN)  
        //{   
        //  Event event = new Event(EventType.DESTROY_COIN);  
        //  event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);  
        //  eventManager.queueEvent(event);  
  
        //} 
        //else if (onCollideEvent.eventType == EventType.PLAYER_PLATFORM_COLLISION) 
        //{  
        //  Event event = new Event(EventType.PLAYER_PLATFORM_COLLISION);  
        //  event.addGameObjectParameter(onCollideEvent.eventParameters.get("platformParameterName"), collider);  
        //  eventManager.queueEvent(event);  
        //}  
      }  
    } 
  }
  
  public PVector getLinearVelocity() 
  {
    return new PVector(metersToPixels(body.getLinearVelocity().x), metersToPixels(body.getLinearVelocity().y)); 
  } 

  public float getSpeed()
  {
    PVector linearVelocity = getLinearVelocity(); 
    return sqrt((linearVelocity.x * linearVelocity.x) + (linearVelocity.y * linearVelocity.y)); 
  }
  
  public PVector getAcceleration() 
  { 
    return new PVector(metersToPixels(latestForce.x), metersToPixels(latestForce.y));  
  }
  
  public void setPosition(PVector position)
  {
    body.setTransform(new Vec2(position.x, position.y), body.getAngle());
  }
  
  public void setLinearVelocity(PVector linearVelocity)  
  {  
    body.setLinearVelocity(new Vec2(pixelsToMeters(linearVelocity.x), pixelsToMeters(linearVelocity.y)));  
  }  
    
  public void applyForce(PVector force, PVector position)  
  {  
    latestForce = force;  
    body.applyForce(new Vec2(pixelsToMeters(force.x), pixelsToMeters(force.y)), new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)));  
  }  
  
  public void applyLinearImpulse(PVector impulse, PVector position, boolean wakeUp)  
  {  
    body.applyLinearImpulse( 
      new Vec2(pixelsToMeters(impulse.x), pixelsToMeters(impulse.y)),
      new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)), 
      wakeUp 
    );
  }
 
  private float pixelsToMeters(float pixels) 
  {  
    return pixels / 50.0f;  
  }

  private float metersToPixels(float meters)
  { 
    return meters * 50.0f;  
  }
}


public class PerspectiveCameraComponent extends Component
{
  private IPerspectiveCamera camera;
  
  public PerspectiveCameraComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    camera = new PerspectiveCamera();
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlParameter : xmlComponent.getChildren())
    {
      if (xmlParameter.getName().equals("Position"))
      {
        PVector position = new PVector();
        position.x = xmlParameter.getFloat("x");
        position.y = xmlParameter.getFloat("y");
        position.z = xmlParameter.getFloat("z");
        camera.setPosition(position);
      }
      else if (xmlParameter.getName().equals("Target"))
      {
        PVector target = new PVector();
        target.x = xmlParameter.getFloat("x");
        target.y = xmlParameter.getFloat("y");
        target.z = xmlParameter.getFloat("z");
        camera.setTarget(target);
      }
      else if (xmlParameter.getName().equals("Up"))
      {
        PVector up = new PVector();
        up.x = xmlParameter.getFloat("x");
        up.y = xmlParameter.getFloat("y");
        up.z = xmlParameter.getFloat("z");
        camera.setUp(up);
      }
      else if (xmlParameter.getName().equals("FieldOfView"))
      {
        camera.setFieldOfView(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("AspectRatio"))
      {
        camera.setAspectRatio(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Near"))
      {
        camera.setNear(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Far"))
      {
        camera.setFar(xmlParameter.getFloat("value"));
      }
    }
    
    scene.setPerspectiveCamera(camera);
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PERSPECTIVE_CAMERA;
  }
  
  @Override public void update(int deltaTime)
  {
  }
}

public class OrthographicCameraComponent extends Component
{
  private IOrthographicCamera camera;
  
  public OrthographicCameraComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    camera = new OrthographicCamera();
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlParameter : xmlComponent.getChildren())
    {
      if (xmlParameter.getName().equals("Position"))
      {
        PVector position = new PVector();
        position.x = xmlParameter.getFloat("x");
        position.y = xmlParameter.getFloat("y");
        position.z = xmlParameter.getFloat("z");
        camera.setPosition(position);
      }
      else if (xmlParameter.getName().equals("Target"))
      {
        PVector target = new PVector();
        target.x = xmlParameter.getFloat("x");
        target.y = xmlParameter.getFloat("y");
        target.z = xmlParameter.getFloat("z");
        camera.setTarget(target);
      }
      else if (xmlParameter.getName().equals("Up"))
      {
        PVector up = new PVector();
        up.x = xmlParameter.getFloat("x");
        up.y = xmlParameter.getFloat("y");
        up.z = xmlParameter.getFloat("z");
        camera.setUp(up);
      }
      else if (xmlParameter.getName().equals("Left"))
      {
        camera.setLeft(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Right"))
      {
        camera.setRight(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Bottom"))
      {
        camera.setBottom(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Top"))
      {
        camera.setTop(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Near"))
      {
        camera.setNear(xmlParameter.getFloat("value"));
      }
      else if (xmlParameter.getName().equals("Far"))
      {
        camera.setFar(xmlParameter.getFloat("value"));
      }
    }
    
    scene.setOrthographicCamera(camera);
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ORTHOGRAPHIC_CAMERA;
  }
  
  @Override public void update(int deltaTime)
  {
  }
}

public class TranslateOverTimeComponent extends NetworkComponent
{
  private boolean movingLeft;
  private float xUnitsPerMillisecond;
  private float leftLimit;
  private float rightLimit;
  
  private boolean movingDown;
  private float yUnitsPerMillisecond;
  private float lowerLimit;
  private float upperLimit;
  
  private boolean movingForward;
  private float zUnitsPerMillisecond;
  private float forwardLimit;
  private float backwardLimit;
  
  public TranslateOverTimeComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  public void setMovingLeft(boolean _movingLeft)
  {
    movingLeft = _movingLeft;
  }
  
  public void setMovingDown(boolean _movingDown)
  {
    movingDown = _movingDown;
  }
  
  public void setMovingForward(boolean _movingForward)
  {
    movingForward = _movingForward;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    movingLeft = xmlComponent.getString("movingLeft").equals("true") ? true : false;
    xUnitsPerMillisecond = xmlComponent.getFloat("xUnitsPerSecond") / 1000.0f;
    leftLimit = xmlComponent.getFloat("leftLimit");
    rightLimit = xmlComponent.getFloat("rightLimit");
    
    movingDown = xmlComponent.getString("movingDown").equals("true") ? true : false;
    yUnitsPerMillisecond = xmlComponent.getFloat("yUnitsPerSecond") / 1000.0f;
    lowerLimit = xmlComponent.getFloat("lowerLimit");
    upperLimit = xmlComponent.getFloat("upperLimit");
    
    movingForward = xmlComponent.getString("movingForward").equals("true") ? true : false;
    zUnitsPerMillisecond = xmlComponent.getFloat("zUnitsPerSecond") / 1000.0f;
    forwardLimit = xmlComponent.getFloat("forwardLimit");
    backwardLimit = xmlComponent.getFloat("backwardLimit");
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    FlatTranslateOverTimeComponent.startFlatTranslateOverTimeComponent(builder);
    FlatTranslateOverTimeComponent.addMovingLeft(builder, movingLeft);
    FlatTranslateOverTimeComponent.addXUnitsPerMillisecond(builder, xUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addLeftLimit(builder, leftLimit);
    FlatTranslateOverTimeComponent.addRightLimit(builder, rightLimit);
    FlatTranslateOverTimeComponent.addMovingDown(builder, movingDown);
    FlatTranslateOverTimeComponent.addYUnitsPerMillisecond(builder, yUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addLowerLimit(builder, lowerLimit);
    FlatTranslateOverTimeComponent.addUpperLimit(builder, upperLimit);
    FlatTranslateOverTimeComponent.addMovingForward(builder, movingForward);
    FlatTranslateOverTimeComponent.addZUnitsPerMillisecond(builder, zUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addForwardLimit(builder, forwardLimit);
    FlatTranslateOverTimeComponent.addBackwardLimit(builder, backwardLimit);
    int flatTranslateOverTimeComponentOffset = FlatTranslateOverTimeComponent.endFlatTranslateOverTimeComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatTranslateOverTimeComponent);
    FlatComponentTable.addComponent(builder, flatTranslateOverTimeComponentOffset);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatTranslateOverTimeComponent flatTranslateOverTimeComponent = (FlatTranslateOverTimeComponent)componentTable;
    
    movingLeft = flatTranslateOverTimeComponent.movingLeft();
    xUnitsPerMillisecond = flatTranslateOverTimeComponent.xUnitsPerMillisecond();
    leftLimit = flatTranslateOverTimeComponent.leftLimit();
    rightLimit = flatTranslateOverTimeComponent.rightLimit();
    
    movingDown = flatTranslateOverTimeComponent.movingDown();
    yUnitsPerMillisecond = flatTranslateOverTimeComponent.yUnitsPerMillisecond();
    lowerLimit = flatTranslateOverTimeComponent.lowerLimit();
    upperLimit = flatTranslateOverTimeComponent.upperLimit();
    
    movingForward = flatTranslateOverTimeComponent.movingForward();
    zUnitsPerMillisecond = flatTranslateOverTimeComponent.zUnitsPerMillisecond();
    forwardLimit = flatTranslateOverTimeComponent.forwardLimit();
    backwardLimit = flatTranslateOverTimeComponent.backwardLimit();
  } 
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.TRANSLATE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector translation = new PVector();
    
    if (movingLeft)
    {
      translation.x = -xUnitsPerMillisecond;
      
      if (gameObject.getTranslation().x < leftLimit)
      {
        movingLeft = false;
        addSetMovingLeftAction();
      }
    }
    else
    {
      translation.x = xUnitsPerMillisecond;
      
      if (gameObject.getTranslation().x > rightLimit)
      {
        movingLeft = true;
        addSetMovingLeftAction();
      }
    }
    
    if (movingDown)
    {
      translation.y = -yUnitsPerMillisecond;
      
      if (gameObject.getTranslation().y < lowerLimit)
      {
        movingDown = false;
        addSetMovingDownAction();
      }
    }
    else
    {
      translation.y = yUnitsPerMillisecond;
      
      if (gameObject.getTranslation().y > upperLimit)
      {
        movingDown = true;
        addSetMovingDownAction();
      }
    }    
    
    if (movingForward)
    {
      translation.z = -zUnitsPerMillisecond;
      
      if (gameObject.getTranslation().z < forwardLimit)
      {
        movingForward = false;
        addSetMovingForwardAction();
      }
    }
    else
    {
      translation.z = zUnitsPerMillisecond;
      
      if (gameObject.getTranslation().z > backwardLimit)
      { 
        movingForward = true;
        addSetMovingForwardAction();
      }
    }
    
    translation = translation.mult(deltaTime);
    gameObject.translate(translation);
    addTranslateAction(translation);
  }
  
  private void addSetMovingLeftAction()
  {
    SetMovingLeftAction setMovingLeftAction = new SetMovingLeftAction();
    setMovingLeftAction.setTargetUID(gameObject.getUID());
    setMovingLeftAction.setMovingLeft(movingLeft);
    
    //actionBuffer.add(setMovingLeftAction);
  }
  
  private void addSetMovingDownAction()
  {
    SetMovingDownAction setMovingDownAction = new SetMovingDownAction();
    setMovingDownAction.setTargetUID(gameObject.getUID());
    setMovingDownAction.setMovingDown(movingDown);
    
    //actionBuffer.add(setMovingDownAction);
  }
  
  private void addSetMovingForwardAction()
  {
    SetMovingForwardAction setMovingForwardAction = new SetMovingForwardAction();
    setMovingForwardAction.setTargetUID(gameObject.getUID());
    setMovingForwardAction.setMovingForward(movingForward);
    
    //actionBuffer.add(setMovingForwardAction);
  }
  
  private void addTranslateAction(PVector translation)
  {
    TranslateAction translateAction = new TranslateAction();
    translateAction.setTargetUID(gameObject.getUID());
    translateAction.setTranslation(translation);
    
    //actionBuffer.add(translateAction);
  }
  
  @Override public String toString()
  {
    String stringTranslateOverTimeComponent = new String();
    stringTranslateOverTimeComponent += "=========== TranslateOverTimeComponent ===========\n";
    stringTranslateOverTimeComponent += "\tmovingLeft: " + movingLeft + "\n";
    stringTranslateOverTimeComponent += "\txUnitsPerMillisecond: " + xUnitsPerMillisecond + "\n";
    stringTranslateOverTimeComponent += "\tleftLimit: " + leftLimit + "\n";
    stringTranslateOverTimeComponent += "\trightLimit: " + rightLimit + "\n";
    stringTranslateOverTimeComponent += "\tmovingDown: " + movingDown + "\n";
    stringTranslateOverTimeComponent += "\tyUnitsPerMillisecond: " + yUnitsPerMillisecond + "\n";
    stringTranslateOverTimeComponent += "\tlowerLimit: " + lowerLimit + "\n";
    stringTranslateOverTimeComponent += "\tupperLimit: " + upperLimit + "\n";
    stringTranslateOverTimeComponent += "\tmovingForward: " + movingForward + "\n";
    stringTranslateOverTimeComponent += "\tzUnitsPerMillisecond: " + zUnitsPerMillisecond + "\n";
    stringTranslateOverTimeComponent += "\tforwardLimit: " + forwardLimit + "\n";
    stringTranslateOverTimeComponent += "\tbackwardLimit: " + backwardLimit + "\n";
    return stringTranslateOverTimeComponent;
  }
}


public class RotateOverTimeComponent extends NetworkComponent
{
  private float xRadiansPerMillisecond;
  private float yRadiansPerMillisecond;
  private float zRadiansPerMillisecond;
  
  public RotateOverTimeComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    xRadiansPerMillisecond = xmlComponent.getFloat("xRadiansPerSecond") / 1000.0f;
    yRadiansPerMillisecond = xmlComponent.getFloat("yRadiansPerSecond") / 1000.0f;
    zRadiansPerMillisecond = xmlComponent.getFloat("zRadiansPerSecond") / 1000.0f;
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    FlatRotateOverTimeComponent.startFlatRotateOverTimeComponent(builder);
    FlatRotateOverTimeComponent.addXRadiansPerMillisecond(builder, xRadiansPerMillisecond);
    FlatRotateOverTimeComponent.addYRadiansPerMillisecond(builder, yRadiansPerMillisecond);
    FlatRotateOverTimeComponent.addZRadiansPerMillisecond(builder, zRadiansPerMillisecond);
    int flatRotateOverTimeComponentOffset = FlatRotateOverTimeComponent.endFlatRotateOverTimeComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatRotateOverTimeComponent);
    FlatComponentTable.addComponent(builder, flatRotateOverTimeComponentOffset);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatRotateOverTimeComponent flatRotateOverTimeComponent = (FlatRotateOverTimeComponent)componentTable;
    
    xRadiansPerMillisecond = flatRotateOverTimeComponent.xRadiansPerMillisecond();
    yRadiansPerMillisecond = flatRotateOverTimeComponent.yRadiansPerMillisecond();
    zRadiansPerMillisecond = flatRotateOverTimeComponent.zRadiansPerMillisecond();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ROTATE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector rotation = new PVector(xRadiansPerMillisecond * deltaTime, yRadiansPerMillisecond * deltaTime, zRadiansPerMillisecond * deltaTime);
    gameObject.rotate(rotation);
    addRotateAction(rotation);
  }
  
  private void addRotateAction(PVector rotation)
  {
    RotateAction rotateAction = new RotateAction();
    rotateAction.setTargetUID(gameObject.getUID());
    rotateAction.setRotation(rotation);
    
    //actionBuffer.add(rotateAction);
  }
  
  @Override public String toString()
  {
    String stringRotateOverTimeComponent = new String();
    stringRotateOverTimeComponent += "======= RotateOverTimeComponent =======\n";
    stringRotateOverTimeComponent += "\txRadiansPerMillisecond: " + xRadiansPerMillisecond + "\n";
    stringRotateOverTimeComponent += "\tyRadiansPerMillisecond: " + yRadiansPerMillisecond + "\n";
    stringRotateOverTimeComponent += "\tzRadiansPerMillisecond: " + zRadiansPerMillisecond + "\n";
    return stringRotateOverTimeComponent;
  }
}


public class ScaleOverTimeComponent extends NetworkComponent
{
  private boolean xScalingUp;
  private float xScalePerMillisecond;
  private float xLowerLimit;
  private float xUpperLimit;
  
  private boolean yScalingUp;
  private float yScalePerMillisecond;
  private float yLowerLimit;
  private float yUpperLimit;
  
  private boolean zScalingUp;
  private float zScalePerMillisecond;
  private float zLowerLimit;
  private float zUpperLimit;
  
  public ScaleOverTimeComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  public void setXScalingUp(boolean _xScalingUp)
  {
    xScalingUp = _xScalingUp;
  }
  
  public void setYScalingUp(boolean _yScalingUp)
  {
    yScalingUp = _yScalingUp;
  }
  
  public void setZScalingUp(boolean _zScalingUp)
  {
    zScalingUp = _zScalingUp;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    xScalingUp = xmlComponent.getString("xScalingUp").equals("true") ? true : false;
    xScalePerMillisecond = xmlComponent.getFloat("xScalePerSecond") / 1000.0f;
    xLowerLimit = xmlComponent.getFloat("xLowerLimit");
    xUpperLimit = xmlComponent.getFloat("xUpperLimit");
    
    yScalingUp = xmlComponent.getString("yScalingUp").equals("true") ? true : false;
    yScalePerMillisecond = xmlComponent.getFloat("yScalePerSecond") / 1000.0f;
    yLowerLimit = xmlComponent.getFloat("yLowerLimit");
    yUpperLimit = xmlComponent.getFloat("yUpperLimit");
    
    zScalingUp = xmlComponent.getString("zScalingUp").equals("true") ? true : false;
    zScalePerMillisecond = xmlComponent.getFloat("zScalePerSecond") / 1000.0f;
    zLowerLimit = xmlComponent.getFloat("zLowerLimit");
    zUpperLimit = xmlComponent.getFloat("zUpperLimit");
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    FlatScaleOverTimeComponent.startFlatScaleOverTimeComponent(builder);
    FlatScaleOverTimeComponent.addXScalingUp(builder, xScalingUp);
    FlatScaleOverTimeComponent.addXScalePerMillisecond(builder, xScalePerMillisecond);
    FlatScaleOverTimeComponent.addXLowerLimit(builder, xLowerLimit);
    FlatScaleOverTimeComponent.addXUpperLimit(builder, xUpperLimit);
    FlatScaleOverTimeComponent.addYScalingUp(builder, yScalingUp);
    FlatScaleOverTimeComponent.addYScalePerMillisecond(builder, yScalePerMillisecond);
    FlatScaleOverTimeComponent.addYLowerLimit(builder, yLowerLimit);
    FlatScaleOverTimeComponent.addYUpperLimit(builder, yUpperLimit);
    FlatScaleOverTimeComponent.addZScalingUp(builder, zScalingUp);
    FlatScaleOverTimeComponent.addZScalePerMillisecond(builder, zScalePerMillisecond);
    FlatScaleOverTimeComponent.addZLowerLimit(builder, zLowerLimit);
    FlatScaleOverTimeComponent.addZUpperLimit(builder, zUpperLimit);
    int flatScaleOverTimeComponentOffset = FlatScaleOverTimeComponent.endFlatScaleOverTimeComponent(builder);
    
    FlatComponentTable.startFlatComponentTable(builder);
    FlatComponentTable.addComponentType(builder, FlatComponentUnion.FlatScaleOverTimeComponent);
    FlatComponentTable.addComponent(builder, flatScaleOverTimeComponentOffset);
    return FlatComponentTable.endFlatComponentTable(builder);
  }
  
  @Override public void deserialize(com.google.flatbuffers.Table componentTable)
  {
    FlatScaleOverTimeComponent flatScaleOverTimeComponent = (FlatScaleOverTimeComponent)componentTable;
    
    xScalingUp = flatScaleOverTimeComponent.xScalingUp();
    xScalePerMillisecond = flatScaleOverTimeComponent.xScalePerMillisecond();
    xLowerLimit = flatScaleOverTimeComponent.xLowerLimit();
    xUpperLimit = flatScaleOverTimeComponent.xUpperLimit();
    
    yScalingUp = flatScaleOverTimeComponent.yScalingUp();
    yScalePerMillisecond = flatScaleOverTimeComponent.yScalePerMillisecond();
    yLowerLimit = flatScaleOverTimeComponent.yLowerLimit();
    yUpperLimit = flatScaleOverTimeComponent.yUpperLimit();
    
    zScalingUp = flatScaleOverTimeComponent.zScalingUp();
    zScalePerMillisecond = flatScaleOverTimeComponent.zScalePerMillisecond();
    zLowerLimit = flatScaleOverTimeComponent.zLowerLimit();
    zUpperLimit = flatScaleOverTimeComponent.zUpperLimit();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.SCALE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector scale = new PVector();
    
    if (xScalingUp)
    {
      scale.x = xScalePerMillisecond;
      
      if (gameObject.getScale().x > xUpperLimit)
      {
        xScalingUp = false;
        addSetXScalingUpAction();
      }
    }
    else
    {
      scale.x = -xScalePerMillisecond;
      
      if (gameObject.getScale().x < xLowerLimit)
      {
        xScalingUp = true;
        addSetXScalingUpAction();
      }
    }
    
    if (yScalingUp)
    {
      scale.y = yScalePerMillisecond;
      
      if (gameObject.getScale().y > yUpperLimit)
      {
        yScalingUp = false;
        addSetYScalingUpAction();
      }
    }
    else
    {
      scale.y = -yScalePerMillisecond;
      
      if (gameObject.getScale().y < yLowerLimit)
      {
        yScalingUp = true;
        addSetYScalingUpAction();
      }
    }
    
    if (zScalingUp)
    {
      scale.z = zScalePerMillisecond;
      
      if (gameObject.getScale().z > zUpperLimit)
      {
        zScalingUp = false;
        addSetZScalingUpAction();
      }
    }
    else
    {
      scale.z = -zScalePerMillisecond;
      
      if (gameObject.getScale().z < zLowerLimit)
      {
        zScalingUp = true;
        addSetZScalingUpAction();
      }
    }
    
    scale = scale.mult(deltaTime);
    gameObject.scale(scale);
    addScaleAction(scale);
  }
  
  private void addSetXScalingUpAction()
  {
    SetXScalingUpAction setXScalingUpAction = new SetXScalingUpAction();
    setXScalingUpAction.setTargetUID(gameObject.getUID());
    setXScalingUpAction.setXScalingUp(xScalingUp);
    
    //actionBuffer.add(setXScalingUpAction);
  }
  
  private void addSetYScalingUpAction()
  {
    SetYScalingUpAction setYScalingUpAction = new SetYScalingUpAction();
    setYScalingUpAction.setTargetUID(gameObject.getUID());
    setYScalingUpAction.setYScalingUp(yScalingUp);
    
    //actionBuffer.add(setYScalingUpAction);
  }
  
  private void addSetZScalingUpAction()
  {
    SetZScalingUpAction setZScalingUpAction = new SetZScalingUpAction();
    setZScalingUpAction.setTargetUID(gameObject.getUID());
    setZScalingUpAction.setZScalingUp(zScalingUp);
    
    //actionBuffer.add(setZScalingUpAction);
  }
  
  private void addScaleAction(PVector scale)
  {
    ScaleAction scaleAction = new ScaleAction();
    scaleAction.setTargetUID(gameObject.getUID());
    scaleAction.setScale(scale);
    
    //actionBuffer.add(scaleAction);
  }
  
  @Override public String toString()
  {
    String stringScaleOverTimeComponent = new String();
    stringScaleOverTimeComponent += "======= ScaleOverTimeComponent =======\n";
    stringScaleOverTimeComponent += "\txScalingUp: " + xScalingUp + "\n";
    stringScaleOverTimeComponent += "\txScalePerMillisecond: " + xScalePerMillisecond + "\n";
    stringScaleOverTimeComponent += "\txLowerLimit: " + xLowerLimit + "\n";
    stringScaleOverTimeComponent += "\txUpperLimit: " + xUpperLimit + "\n";
    stringScaleOverTimeComponent += "\tyScalingUp: " + yScalingUp + "\n";
    stringScaleOverTimeComponent += "\tyScalePerMillisecond: " + yScalePerMillisecond + "\n";
    stringScaleOverTimeComponent += "\tyLowerLimit: " + yLowerLimit + "\n";
    stringScaleOverTimeComponent += "\tyUpperLimit: " + yUpperLimit + "\n";
    stringScaleOverTimeComponent += "\tzScalingUp: " + zScalingUp + "\n";
    stringScaleOverTimeComponent += "\tzScalePerMillisecond: " + zScalePerMillisecond + "\n";
    stringScaleOverTimeComponent += "\tzLowerLimit: " + zLowerLimit + "\n";
    stringScaleOverTimeComponent += "\tzUpperLimit: " + zUpperLimit + "\n";
    return stringScaleOverTimeComponent;
  }
}


public class BoxPaddleControllerComponent extends Component
{
  private boolean horizontal;
  private float speed;
  
  private boolean upButtonDown;
  private boolean downButtonDown;
  private boolean leftButtonDown;
  private boolean rightButtonDown;
  
  public BoxPaddleControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    upButtonDown = false;
    downButtonDown = false;
    leftButtonDown = false;
    rightButtonDown = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    horizontal = xmlComponent.getString("direction").equals("horizontal") ? true : false;
    speed = xmlComponent.getFloat("speed");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.BOX_PADDLE_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if (horizontal)
    {
      if (eventManager.getEvents(EventType.LEFT_BUTTON_PRESSED).size() > 0)
      {
        leftButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.RIGHT_BUTTON_PRESSED).size() > 0)
      {
        rightButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.LEFT_BUTTON_RELEASED).size() > 0)
      {
        leftButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.RIGHT_BUTTON_RELEASED).size() > 0)
      {
        rightButtonDown = false;
      }
      
      float horizontalVelocity = 0.0f;
      
      if (leftButtonDown)
      {
        horizontalVelocity -= speed;
      }
      
      if (rightButtonDown)
      {
        horizontalVelocity += speed;
      }
      
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(horizontalVelocity, 0.0f));
      }
    }
    else
    {
      if (eventManager.getEvents(EventType.UP_BUTTON_PRESSED).size() > 0)
      {
        upButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.DOWN_BUTTON_PRESSED).size() > 0)
      {
        downButtonDown = true;
      }
      
      if (eventManager.getEvents(EventType.UP_BUTTON_RELEASED).size() > 0)
      {
        upButtonDown = false;
      }
      
      if (eventManager.getEvents(EventType.DOWN_BUTTON_RELEASED).size() > 0)
      {
        downButtonDown = false;
      }
      
      float verticalVelocity = 0.0f;
      
      if (upButtonDown)
      {
        verticalVelocity += speed;
      }
      
      if (downButtonDown)
      {
        verticalVelocity -= speed;
      }
      
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(0.0f, verticalVelocity));
      }
    }
  }
}


public class CirclePaddleControllerComponent extends Component
{
  private float speed;
  
  private boolean wButtonDown;
  private boolean aButtonDown;
  private boolean sButtonDown;
  private boolean dButtonDown;
  
  public CirclePaddleControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    wButtonDown = false;
    aButtonDown = false;
    sButtonDown = false;
    dButtonDown = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    speed = xmlComponent.getFloat("speed");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.CIRCLE_PADDLE_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if (eventManager.getEvents(EventType.W_BUTTON_PRESSED).size() > 0)
    {
      wButtonDown = true;
    }
    
    if (eventManager.getEvents(EventType.A_BUTTON_PRESSED).size() > 0)
    {
      aButtonDown = true;
    }
    
    if (eventManager.getEvents(EventType.S_BUTTON_PRESSED).size() > 0)
    {
      sButtonDown = true;
    }
    
    if (eventManager.getEvents(EventType.D_BUTTON_PRESSED).size() > 0)
    {
      dButtonDown = true;
    }
    
    if (eventManager.getEvents(EventType.W_BUTTON_RELEASED).size() > 0)
    {
      wButtonDown = false;
    }
    
    if (eventManager.getEvents(EventType.A_BUTTON_RELEASED).size() > 0)
    {
      aButtonDown = false;
    }
    
    if (eventManager.getEvents(EventType.S_BUTTON_RELEASED).size() > 0)
    {
      sButtonDown = false;
    }
    
    if (eventManager.getEvents(EventType.D_BUTTON_RELEASED).size() > 0)
    {
      dButtonDown = false;
    }
    
    PVector velocity = new PVector(0.0f, 0.0f);
    
    if (wButtonDown)
    {
      velocity.y += speed;
    }
    
    if (aButtonDown)
    {
      velocity.x -= speed;
    }
    
    if (sButtonDown)
    {
      velocity.y -= speed;
    }
    
    if (dButtonDown)
    {
      velocity.x += speed;
    }
    
    velocity = velocity.normalize().mult(speed);
    
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setLinearVelocity(velocity);
    }
  }
}


public class BallControllerComponent extends Component
{
  private float speed;
  private int waitTime;
  private boolean waiting;
  private int timePassed;
  private int currentPlayerID;
  
  public BallControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    waiting = true;
    timePassed = 0;
    currentPlayerID = -1;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    speed = xmlComponent.getFloat("speed");
    waitTime = xmlComponent.getInt("waitTime");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.BALL_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      PVector velocity = rigidBodyComponent.getLinearVelocity();
      
      if (waiting)
      {
        timePassed += deltaTime;
        if (timePassed > waitTime)
        {
          velocity.x = random(-1.0f, 1.0f);
          velocity.y = random(-1.0f, 1.0f);
          
          waiting = false;
        }
      }
      
      rigidBodyComponent.setLinearVelocity(velocity.normalize().mult(speed));
    }
  }
  
  public int getCurrentPlayerID()
  {
    return currentPlayerID;
  }
  
  public void reset()
  {
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setPosition(new PVector(0.0f, 0.0f));
      rigidBodyComponent.setLinearVelocity(new PVector(0.0f, 0.0f));
      waiting = true;
      timePassed = 0;
    }
  }
}


public class GoalListenerComponent extends Component
{
  private String ballParameterName;
  private int playerID;
  private String scoreFullSpriteName;
  private PVector colorVector;
  private int currentScore;
  
  public GoalListenerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    currentScore = 0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    ballParameterName = xmlComponent.getString("ballParameterName");    
    playerID = xmlComponent.getInt("playerID");
    scoreFullSpriteName = xmlComponent.getString("scoreFullSpriteName");
    colorVector = new PVector(xmlComponent.getFloat("r"), xmlComponent.getFloat("g"), xmlComponent.getFloat("b"));
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.GOAL_LISTENER;
  }
  
  @Override public void update(int deltaTime)
  {
    for (IEvent event : eventManager.getEvents(EventType.GOAL_SCORED))
    {
      IGameObject ball = event.getRequiredGameObjectParameter(ballParameterName);
      IComponent component = ball.getComponent(ComponentType.BALL_CONTROLLER);
      if (component != null)
      {
        BallControllerComponent ballControllerComponent = (BallControllerComponent)component;
        
        if (currentScore < 9 && ballControllerComponent.getCurrentPlayerID() == playerID)
        {
          component = gameObject.getComponent(ComponentType.RENDER);
          if (component != null)
          {
            RenderComponent renderComponent = (RenderComponent)component;
            
            ArrayList<Integer> spriteHandles = renderComponent.getSpriteHandles();
            scene.removeSpriteInstance(spriteHandles.get(currentScore));
            
            ISpriteInstance scoreFullSprite = new SpriteInstance(scoreFullSpriteName);
            scoreFullSprite.setTint(colorVector);
            scoreFullSprite.setAlpha(255.0f);
            
            spriteHandles.set(currentScore, scene.addSpriteInstance(scoreFullSprite));
            
            currentScore++;
          }
        }
        
        ballControllerComponent.reset();
      }
    }
  }
}


public IComponent componentFactory(GameObject gameObject, XML xmlComponent)
{
  IComponent component = null;
  String componentName = xmlComponent.getName();
  
  switch (componentName)
  {
    case "Render":
      component = new RenderComponent(gameObject);
      break;
      
    case "RigidBody":
      component = new RigidBodyComponent(gameObject);
      break;
      
    case "PerspectiveCamera":
      component = new PerspectiveCameraComponent(gameObject);
      break;
      
    case "OrthographicCamera":
      component = new OrthographicCameraComponent(gameObject);
      break;
      
    case "TranslateOverTime":
      component = new TranslateOverTimeComponent(gameObject);
      break;
      
    case "RotateOverTime":
      component = new RotateOverTimeComponent(gameObject);
      break;
      
    case "ScaleOverTime":
      component = new ScaleOverTimeComponent(gameObject);
      break;
      
    case "BoxPaddleController":
      component = new BoxPaddleControllerComponent(gameObject);
      break;
      
    case "CirclePaddleController":
      component = new CirclePaddleControllerComponent(gameObject);
      break;
      
    case "BallController":
      component = new BallControllerComponent(gameObject);
      break;
      
    case "GoalListener":
      component = new GoalListenerComponent(gameObject);
      break;
  }
  
  if (component != null)
  {
    component.fromXML(xmlComponent);
  }
  
  return component;
}

public IComponent deserializeComponent(GameObject gameObject, FlatComponentTable flatComponentTable)
{
  INetworkComponent component = null;
  com.google.flatbuffers.Table componentTable = null;
  
  switch (flatComponentTable.componentType())
  {
    case FlatComponentUnion.FlatRenderComponent:
      component = new RenderComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatRenderComponent());
      break;
      
    case FlatComponentUnion.FlatTranslateOverTimeComponent:
      component = new TranslateOverTimeComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatTranslateOverTimeComponent());
      break;
      
    case FlatComponentUnion.FlatRotateOverTimeComponent:
      component = new RotateOverTimeComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatRotateOverTimeComponent());
      break;
      
    case FlatComponentUnion.FlatScaleOverTimeComponent:
      component = new ScaleOverTimeComponent(gameObject);
      componentTable = flatComponentTable.component(new FlatScaleOverTimeComponent());
      break;
      
    default:
      assert(false);
  }
  
  if (component != null && componentTable != null)
  {
    component.deserialize(componentTable);
  }
  
  return component;
}