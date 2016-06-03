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
  TRANSLATE_OVER_TIME,
  ROTATE_OVER_TIME,
  SCALE_OVER_TIME,
}

public interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public JSONObject      serialize();
  public void            deserialize(JSONObject jsonComponent);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
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
      
    case TRANSLATE_OVER_TIME:
      return "translateOverTime";
      
    case ROTATE_OVER_TIME:
      return "rotateOverTime";
      
    case SCALE_OVER_TIME:
      return "scaleOverTime";
      
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
      
    case "translateOverTime":
      return ComponentType.TRANSLATE_OVER_TIME;
      
    case "rotateOverTime":
      return ComponentType.ROTATE_OVER_TIME;
      
    case "scaleOverTime":
      return ComponentType.SCALE_OVER_TIME;
      
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


public class RenderComponent extends Component
{
  private class PShapeExt
  {
    PShape pshape;
    ArrayList<PVector> uvs;
  }
  
  private ArrayList<PShapeExt> model;
  private IMaterial material;
  
  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    model = new ArrayList<PShapeExt>();
    material = new Material();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    ArrayList<PVector> uvs = new ArrayList<PVector>();
    IMaterialLib materialLib = null;
    
    // These are dummy inserts so we don't need to subtract all the indices in the .obj file by one.
    vertices.add(new PVector());
    uvs.add(new PVector());
    
    for (String line : loadStrings(xmlComponent.getString("objFileName")))
    {
      String[] words = line.split(" ");
      
      switch(words[0])
      {
        case "mtllib":
          materialLib = materialLibManager.getMaterialLib(words[1]);
          break;
          
        case "v":
          vertices.add(new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3])));
          break;
          
        case "vt":
          uvs.add(new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2])));
          break;
          
        case "usemtl":
          if (materialLib != null)
          {
            material = materialLib.getMaterial(words[1]);
          }
          break;
          
        case "f":
          PShapeExt face = new PShapeExt();
          face.uvs = new ArrayList<PVector>();
          
          face.pshape = createShape();
          face.pshape.beginShape();
          face.pshape.noStroke();
          for (int i = 1; i < words.length; i++)
          {
            String[] vertexComponentsIndices = words[i].split("/");
            
            int vertexIndex = Integer.parseInt(vertexComponentsIndices[0]);
            int uvIndex = Integer.parseInt(vertexComponentsIndices[1]);
            
            face.pshape.vertex(vertices.get(vertexIndex).x, vertices.get(vertexIndex).y, vertices.get(vertexIndex).z, uvs.get(uvIndex).x, uvs.get(uvIndex).y);
            face.uvs.add(new PVector(uvs.get(uvIndex).x, uvs.get(uvIndex).y));
          }
          face.pshape.texture(material.getTexture());
          face.pshape.endShape();
          model.add(face);
          break;
      }
    }
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonRenderComponent = new JSONObject();
    
    JSONArray jsonModel = new JSONArray();
    for (PShapeExt face : model)
    {
      JSONArray jsonFace = new JSONArray();
      for (int i = 0; i < face.pshape.getVertexCount(); i++)
      {
        PVector vertex = face.pshape.getVertex(i);
        JSONObject jsonVertex = new JSONObject();
        jsonVertex.setFloat("x", vertex.x);
        jsonVertex.setFloat("y", vertex.y);
        jsonVertex.setFloat("z", vertex.z);
        jsonVertex.setFloat("u", face.uvs.get(i).x);
        jsonVertex.setFloat("v", face.uvs.get(i).y);
        jsonFace.append(jsonVertex);
      }
      jsonModel.append(jsonFace);
    }
    jsonRenderComponent.setJSONArray("model", jsonModel);
    
    jsonRenderComponent.setJSONObject("material", material.serialize());
    
    return jsonRenderComponent;
  }
  
  @Override public void deserialize(JSONObject jsonRenderComponent)
  {
    material.deserialize(jsonRenderComponent.getJSONObject("material"));
    
    JSONArray jsonModel = jsonRenderComponent.getJSONArray("model");
    for (int i = 0; i < jsonModel.size(); i++)
    {
      PShapeExt face = new PShapeExt();
      face.uvs = new ArrayList<PVector>();
      
      face.pshape = createShape();
      face.pshape.beginShape();
      face.pshape.noStroke();
      
      JSONArray jsonFace = jsonModel.getJSONArray(i);
      for (int j = 0; j < jsonFace.size(); j++)
      {
        PVector uv = new PVector();
        
        JSONObject jsonVertex = jsonFace.getJSONObject(j);
        uv.x = jsonVertex.getFloat("u");
        uv.y = jsonVertex.getFloat("v");
        face.pshape.vertex(jsonVertex.getFloat("x"), jsonVertex.getFloat("y"), jsonVertex.getFloat("z"), uv.x, uv.y);
        face.uvs.add(uv);
      }
      
      face.pshape.texture(material.getTexture());
      face.pshape.endShape();
      
      model.add(face);
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
  
  @Override public void update(int deltaTime)
  {
    pushMatrix();
    
    translate(gameObject.getTranslation().x, gameObject.getTranslation().y, gameObject.getTranslation().z);
    rotateX(gameObject.getRotation().x);
    rotateY(gameObject.getRotation().y);
    rotateZ(gameObject.getRotation().z);
    scale(gameObject.getScale().x, gameObject.getScale().y, gameObject.getScale().z);
    
    for (PShapeExt face : model)
    {
      shape(face.pshape);
    }
    
    popMatrix();
  }
}


public class TranslateOverTimeComponent extends Component
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
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonTranslateOverTime = new JSONObject();
    
    jsonTranslateOverTime.setBoolean("movingLeft", movingLeft);
    jsonTranslateOverTime.setFloat("xUnitsPerMillisecond", xUnitsPerMillisecond);
    jsonTranslateOverTime.setFloat("leftLimit", leftLimit);
    jsonTranslateOverTime.setFloat("rightLimit", rightLimit);
    
    jsonTranslateOverTime.setBoolean("movingDown", movingDown);
    jsonTranslateOverTime.setFloat("yUnitsPerMillisecond", yUnitsPerMillisecond);
    jsonTranslateOverTime.setFloat("lowerLimit", lowerLimit);
    jsonTranslateOverTime.setFloat("upperLimit", upperLimit);
    
    jsonTranslateOverTime.setBoolean("movingForward", movingForward);
    jsonTranslateOverTime.setFloat("zUnitsPerMillisecond", zUnitsPerMillisecond);
    jsonTranslateOverTime.setFloat("forwardLimit", forwardLimit);
    jsonTranslateOverTime.setFloat("backwardLimit", backwardLimit);
    
    return jsonTranslateOverTime;
  }
  
  @Override public void deserialize(JSONObject jsonTranslateOverTime)
  {
    movingLeft = jsonTranslateOverTime.getBoolean("movingLeft");
    xUnitsPerMillisecond = jsonTranslateOverTime.getFloat("xUnitsPerMillisecond");
    leftLimit = jsonTranslateOverTime.getFloat("leftLimit");
    rightLimit = jsonTranslateOverTime.getFloat("rightLimit");
    
    movingDown = jsonTranslateOverTime.getBoolean("movingDown");
    yUnitsPerMillisecond = jsonTranslateOverTime.getFloat("yUnitsPerMillisecond");
    lowerLimit = jsonTranslateOverTime.getFloat("lowerLimit");
    upperLimit = jsonTranslateOverTime.getFloat("upperLimit");
    
    movingForward = jsonTranslateOverTime.getBoolean("movingForward");
    zUnitsPerMillisecond = jsonTranslateOverTime.getFloat("zUnitsPerMillisecond");
    forwardLimit = jsonTranslateOverTime.getFloat("forwardLimit");
    backwardLimit = jsonTranslateOverTime.getFloat("backwardLimit");
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
      }
    }
    else
    {
      translation.x = xUnitsPerMillisecond;
      
      if (gameObject.getTranslation().x > rightLimit)
      {
        movingLeft = true;
      }
    }
    
    if (movingDown)
    {
      translation.y = yUnitsPerMillisecond;
      
      if (gameObject.getTranslation().y > lowerLimit)
      {
        movingDown = false;
      }
    }
    else
    {
      translation.y = -yUnitsPerMillisecond;
      
      if (gameObject.getTranslation().y < upperLimit)
      {
        movingDown = true;
      }
    }
    
    if (movingForward)
    {
      translation.z = zUnitsPerMillisecond;
      
      if (gameObject.getTranslation().z > forwardLimit)
      {
        movingForward = false;
      }
    }
    else
    {
      translation.z = -zUnitsPerMillisecond;
      
      if (gameObject.getTranslation().z < backwardLimit)
      {
        movingForward = true;
      }
    }
    
    gameObject.translate(translation.mult(deltaTime));
  }
}


public class RotateOverTimeComponent extends Component
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
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonRotateOverTime = new JSONObject();
    
    jsonRotateOverTime.setFloat("xRadiansPerMillisecond", xRadiansPerMillisecond);
    jsonRotateOverTime.setFloat("yRadiansPerMillisecond", yRadiansPerMillisecond);
    jsonRotateOverTime.setFloat("zRadiansPerMillisecond", zRadiansPerMillisecond);
    
    return jsonRotateOverTime;
  }
  
  @Override public void deserialize(JSONObject jsonRotateOverTime)
  {
    xRadiansPerMillisecond = jsonRotateOverTime.getFloat("xRadiansPerMillisecond");
    yRadiansPerMillisecond = jsonRotateOverTime.getFloat("yRadiansPerMillisecond");
    zRadiansPerMillisecond = jsonRotateOverTime.getFloat("zRadiansPerMillisecond");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ROTATE_OVER_TIME;
  }
  
  @Override public void update(int deltaTime)
  {
    gameObject.rotate(new PVector(xRadiansPerMillisecond * deltaTime, yRadiansPerMillisecond * deltaTime, zRadiansPerMillisecond * deltaTime));
  }
}


public class ScaleOverTimeComponent extends Component
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
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonScaleOverTime = new JSONObject();
    
    jsonScaleOverTime.setBoolean("xScalingUp", xScalingUp);
    jsonScaleOverTime.setFloat("xScalePerMillisecond", xScalePerMillisecond);
    jsonScaleOverTime.setFloat("xLowerLimit", xLowerLimit);
    jsonScaleOverTime.setFloat("xUpperLimit", xUpperLimit);
    
    jsonScaleOverTime.setBoolean("yScalingUp", yScalingUp);
    jsonScaleOverTime.setFloat("yScalePerMillisecond", yScalePerMillisecond);
    jsonScaleOverTime.setFloat("yLowerLimit", yLowerLimit);
    jsonScaleOverTime.setFloat("yUpperLimit", yUpperLimit);
    
    jsonScaleOverTime.setBoolean("zScalingUp", zScalingUp);
    jsonScaleOverTime.setFloat("zScalePerMillisecond", zScalePerMillisecond);
    jsonScaleOverTime.setFloat("zLowerLimit", zLowerLimit);
    jsonScaleOverTime.setFloat("zUpperLimit", zUpperLimit);
    
    return jsonScaleOverTime;
  }
  
  @Override public void deserialize(JSONObject jsonScaleOverTime)
  {
    xScalingUp = jsonScaleOverTime.getBoolean("xScalingUp");
    xScalePerMillisecond = jsonScaleOverTime.getFloat("xScalePerMillisecond");
    xLowerLimit = jsonScaleOverTime.getFloat("xLowerLimit");
    xUpperLimit = jsonScaleOverTime.getFloat("xUpperLimit");
    
    yScalingUp = jsonScaleOverTime.getBoolean("yScalingUp");
    yScalePerMillisecond = jsonScaleOverTime.getFloat("yScalePerMillisecond");
    yLowerLimit = jsonScaleOverTime.getFloat("yLowerLimit");
    yUpperLimit = jsonScaleOverTime.getFloat("yUpperLimit");
    
    zScalingUp = jsonScaleOverTime.getBoolean("zScalingUp");
    zScalePerMillisecond = jsonScaleOverTime.getFloat("zScalePerMillisecond");
    zLowerLimit = jsonScaleOverTime.getFloat("zLowerLimit");
    zUpperLimit = jsonScaleOverTime.getFloat("zUpperLimit");
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
      }
    }
    else
    {
      scale.x = -xScalePerMillisecond;
      
      if (gameObject.getScale().x < xLowerLimit)
      {
        xScalingUp = true;
      }
    }
    
    if (yScalingUp)
    {
      scale.y = yScalePerMillisecond;
      
      if (gameObject.getScale().y > yUpperLimit)
      {
        yScalingUp = false;
      }
    }
    else
    {
      scale.y = -yScalePerMillisecond;
      
      if (gameObject.getScale().y < yLowerLimit)
      {
        yScalingUp = true;
      }
    }
    
    if (zScalingUp)
    {
      scale.z = zScalePerMillisecond;
      
      if (gameObject.getScale().z > zUpperLimit)
      {
        zScalingUp = false;
      }
    }
    else
    {
      scale.z = -zScalePerMillisecond;
      
      if (gameObject.getScale().z < zLowerLimit)
      {
        zScalingUp = true;
      }
    }
    
    gameObject.scale(scale.mult(deltaTime));
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
      
    case "TranslateOverTime":
      component = new TranslateOverTimeComponent(gameObject);
      break;
      
    case "RotateOverTime":
      component = new RotateOverTimeComponent(gameObject);
      break;
      
    case "ScaleOverTime":
      component = new ScaleOverTimeComponent(gameObject);
      break;
  }
  
  if (component != null)
  {
    component.fromXML(xmlComponent);
  }
  
  return component;
}

public IComponent deserializeComponent(GameObject gameObject, JSONObject jsonComponent)
{
  IComponent component = null;
  
  ComponentType componentType = componentTypeStringToEnum(jsonComponent.getString("componentType"));
  
  switch (componentType)
  {
    case RENDER:
      component = new RenderComponent(gameObject);
      break;
      
    case TRANSLATE_OVER_TIME:
      component = new TranslateOverTimeComponent(gameObject);
      break;
      
    case ROTATE_OVER_TIME:
      component = new RotateOverTimeComponent(gameObject);
      break;
      
    case SCALE_OVER_TIME:
      component = new ScaleOverTimeComponent(gameObject);
      break;
      
    default:
      println("Assertion: ComponentType not added to deserializeComponent.");
      assert(false);
  }
  
  if (component != null)
  {
    component.deserialize(jsonComponent);
  }
  
  return component;
}