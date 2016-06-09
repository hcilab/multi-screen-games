//======================================================================================================
// Author: David Hanna
//
// An module responsible for rendering a collection of objects to the screen.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface ICamera
{
  public PVector getPosition();
  public PVector getTarget();
  public PVector getUp();
  
  public void setPosition(PVector position);
  public void setTarget(PVector target);
  public void setUp(PVector up);
  
  public void setToDefaults();
  
  public void apply();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonCamera);
}

public interface IPerspectiveCamera extends ICamera
{
  public float getFieldOfView();
  public float getAspectRatio();
  public float getNear();
  public float getFar();
  
  public void setFieldOfView(float fieldOfView);
  public void setAspectRatio(float aspectRatio);
  public void setNear(float near);
  public void setFar(float far);
}

public interface IOrthographicCamera extends ICamera
{
  public float getLeft();
  public float getRight();
  public float getBottom();
  public float getTop();
  public float getNear();
  public float getFar();
  
  public void setLeft(float left);
  public void setRight(float right);
  public void setBottom(float bottom);
  public void setTop(float top);
  public void setNear(float near);
  public void setFar(float far);
}

public interface ISprite
{
  public String getName();
  
  public PVector getTranslation();
  public float getRotation();
  public PVector getScale();
  
  public void setTranslation(PVector translation);
  public void setRotation(float rotation);
  public void setScale(PVector scale);
  
  public void render();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonSprite);
}

public interface IModel
{
  public void fromOBJ(String objFileName);
  
  public String getName();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  
  public void render();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonModel);
}

public interface IScene
{
  public IOrthographicCamera getOrthographicCamera();
  public void setOrthographicCamera(IOrthographicCamera orthographicCamera);
  
  public IPerspectiveCamera getPerspectiveCamera();
  public void setPerspectiveCamera(IPerspectiveCamera perspectiveCamera);
  
  public void addSprite(ISprite sprite);
  public ISprite getSprite(String name);
  public void removeSprite(String name);
  
  public void addModel(IModel model);
  public IModel getModel(String name);
  public void removeModel(String name);
  
  public void render();
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public abstract class Camera implements ICamera
{
  private PVector position;
  private PVector target;
  private PVector up;
  
  public Camera()
  {
    setToDefaults();
  }
  
  @Override public PVector getPosition()
  {
    return position;
  }
  
  @Override public PVector getTarget()
  {
    return target;
  }
  
  @Override public PVector getUp()
  {
    return up;
  }
  
  @Override public void setPosition(PVector _position)
  {
    position = _position;
  }
  
  @Override public void setTarget(PVector _target)
  {
    target = _target;
  }
  
  @Override public void setUp(PVector _up)
  {
    up = _up;
  }
  
  @Override public void setToDefaults()
  {
    position = new PVector(0.0f, 0.0f, 10.0f);
    target = new PVector(0.0f, 0.0f, 0.0f);
    up = new PVector(0.0f, 1.0f, 0.0f);
  }
  
  @Override public void apply()
  {
    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonPosition = new JSONObject();
    jsonPosition.setFloat("x", position.x);
    jsonPosition.setFloat("y", position.y);
    jsonPosition.setFloat("z", position.z);
    
    JSONObject jsonTarget = new JSONObject();
    jsonTarget.setFloat("x", target.x);
    jsonTarget.setFloat("y", target.y);
    jsonTarget.setFloat("z", target.z);
    
    JSONObject jsonUp = new JSONObject();
    jsonUp.setFloat("x", up.x);
    jsonUp.setFloat("y", up.y);
    jsonUp.setFloat("z", up.z);
    
    JSONObject jsonCamera = new JSONObject();
    jsonCamera.setJSONObject("position", jsonPosition);
    jsonCamera.setJSONObject("target", jsonTarget);
    jsonCamera.setJSONObject("up", jsonUp);
    
    return jsonCamera;
  }
  
  @Override public void deserialize(JSONObject jsonCamera)
  {
    JSONObject jsonPosition = jsonCamera.getJSONObject("position");
    JSONObject jsonTarget = jsonCamera.getJSONObject("target");
    JSONObject jsonUp = jsonCamera.getJSONObject("up");
    
    position.x = jsonPosition.getFloat("x");
    position.y = jsonPosition.getFloat("y");
    position.z = jsonPosition.getFloat("z");
    
    target.x = jsonTarget.getFloat("x");
    target.y = jsonTarget.getFloat("y");
    target.z = jsonTarget.getFloat("z");
    
    up.x = jsonUp.getFloat("x");
    up.y = jsonUp.getFloat("y");
    up.z = jsonUp.getFloat("z");
  }
}

public class PerspectiveCamera extends Camera implements IPerspectiveCamera
{
  private float fieldOfView;
  private float aspectRatio;
  private float near;
  private float far;
  
  public PerspectiveCamera()
  {
    setToDefaults();
  }
  
  @Override public float getFieldOfView()
  {
    return fieldOfView;
  }
  
  @Override public float getAspectRatio()
  {
    return aspectRatio;
  }
  
  @Override public float getNear()
  {
    return near;
  }
  
  @Override public float getFar()
  {
    return far;
  }
  
  @Override public void setFieldOfView(float _fieldOfView)
  {
    fieldOfView = _fieldOfView;
  }
  
  @Override public void setAspectRatio(float _aspectRatio)
  {
    aspectRatio = _aspectRatio;
  }
  
  @Override public void setNear(float _near)
  {
    near = _near;
  }
  
  @Override public void setFar(float _far)
  {
    far = _far;
  }
  
  @Override public void setToDefaults()
  {
    super.setToDefaults();
    
    fieldOfView = PI / 3.0f;
    aspectRatio = 4.0f / 3.0f;
    near = 0.01f;
    far = 1000.0f;
  }
  
  @Override public void apply()
  {
    super.apply();
    
    perspective(fieldOfView, aspectRatio, near, far);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonPerspectiveCamera = super.serialize();
    
    jsonPerspectiveCamera.setFloat("fieldOfView", fieldOfView);
    jsonPerspectiveCamera.setFloat("aspectRatio", aspectRatio);
    jsonPerspectiveCamera.setFloat("near", near);
    jsonPerspectiveCamera.setFloat("far", far);
    
    return jsonPerspectiveCamera;
  }
  
  @Override public void deserialize(JSONObject jsonPerspectiveCamera)
  {
    super.deserialize(jsonPerspectiveCamera);
    
    fieldOfView = jsonPerspectiveCamera.getFloat("fieldOfView");
    aspectRatio = jsonPerspectiveCamera.getFloat("aspectRatio");
    near = jsonPerspectiveCamera.getFloat("near");
    far = jsonPerspectiveCamera.getFloat("far");
  }
}

public class OrthographicCamera extends Camera implements IOrthographicCamera
{
  private float left;
  private float right;
  private float bottom;
  private float top;
  private float near;
  private float far;
  
  public OrthographicCamera()
  {
    setToDefaults();
  }
  
  @Override public float getLeft()
  {
    return left;
  }
  
  @Override public float getRight()
  {
    return right;
  }
  
  @Override public float getBottom()
  {
    return bottom;
  }
  
  @Override public float getTop()
  {
    return top;
  }
  
  @Override public float getNear()
  {
    return near;
  }
  
  @Override public float getFar()
  {
    return far;
  }
  
  @Override public void setLeft(float _left)
  {
    left = _left;
  }
  
  @Override public void setRight(float _right)
  {
    right = _right;
  }
  
  @Override public void setBottom(float _bottom)
  {
    bottom = _bottom;
  }
  
  @Override public void setTop(float _top)
  {
    top = _top;
  }
  
  @Override public void setNear(float _near)
  {
    near = _near;
  }
  
  @Override public void setFar(float _far)
  {
    far = _far;
  }
  
  @Override public void setToDefaults()
  {
    super.setToDefaults();
    
    left = -width / 2.0f;
    right = width / 2.0f;
    bottom = -height / 2.0f;
    top = height / 2.0f;
    float cameraZ = ((height / 2.0f) / tan(PI * 60.0f / 360.0f));
    near = cameraZ / 10.0f;
    far = cameraZ * 10.0f;
  }
  
  @Override public void apply()
  {
    super.apply();
    ortho(left, right, bottom, top, near, far);
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonOrthographicCamera = super.serialize();
    
    jsonOrthographicCamera.setFloat("left", left);
    jsonOrthographicCamera.setFloat("right", right);
    jsonOrthographicCamera.setFloat("bottom", bottom);
    jsonOrthographicCamera.setFloat("top", top);
    jsonOrthographicCamera.setFloat("near", near);
    jsonOrthographicCamera.setFloat("far", far);
    
    return jsonOrthographicCamera;
  }
  
  @Override public void deserialize(JSONObject jsonOrthographicCamera)
  {
    super.deserialize(jsonOrthographicCamera);
    
    left = jsonOrthographicCamera.getFloat("left");
    right = jsonOrthographicCamera.getFloat("right");
    bottom = jsonOrthographicCamera.getFloat("bottom");
    top = jsonOrthographicCamera.getFloat("top");
    near = jsonOrthographicCamera.getFloat("near");
    far = jsonOrthographicCamera.getFloat("far");
  }
}

public class Sprite implements ISprite
{
  private String name;
  
  private PVector translation;
  private float rotation;
  private PVector scale;
  
  public Sprite(String _name)
  {
    name = _name;
    
    translation = new PVector();
    rotation = 0.0f;
    scale = new PVector(1.0f, 1.0f);
  }
  
  public Sprite(JSONObject jsonSprite)
  {
    deserialize(jsonSprite);
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public PVector getTranslation()
  {
    return translation;
  }
  
  @Override public float getRotation()
  {
    return rotation;
  }
  
  @Override public PVector getScale()
  {
    return scale;
  }
  
  @Override public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  @Override public void setRotation(float _rotation)
  {
    rotation = _rotation;
  }
  
  @Override public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  @Override public void render()
  {
  }
  
  @Override public JSONObject serialize()
  {
    return new JSONObject();
  }
  
  @Override public void deserialize(JSONObject jsonSprite)
  {
    name = jsonSprite.getString("name");
  }
}

public class Model implements IModel
{
  private class PShapeExt
  {
    PShape pshape;
    ArrayList<PVector> uvs;
  }
  
  private String name;
  
  private ArrayList<PShapeExt> faces;
  private IMaterial material;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  public Model(String _name)
  {
    name = _name;
    
    faces = new ArrayList<PShapeExt>();
    material = new Material();
    
    translation = new PVector();
    rotation = new PVector();
    scale = new PVector(1.0f, 1.0f, 1.0f);
  }
  
  public Model(JSONObject jsonModel)
  {
    deserialize(jsonModel);
  }
  
  @Override public void fromOBJ(String objFileName)
  {
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    ArrayList<PVector> uvs = new ArrayList<PVector>();
    IMaterialLib materialLib = null;
    
    // These are dummy inserts so we don't need to subtract all the indices in the .obj file by one.
    vertices.add(new PVector());
    uvs.add(new PVector());
    
    for (String line : loadStrings(objFileName))
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
          faces.add(face);
          break;
      }
    }
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public PVector getTranslation()
  {
    return translation;
  }
  
  @Override public PVector getRotation()
  {
    return rotation;
  }
  
  @Override public PVector getScale()
  {
    return scale;
  }
  
  @Override public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  @Override public void setRotation(PVector _rotation)
  {
    rotation = _rotation;
  }
  
  @Override public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  @Override public void render()
  {
    pushMatrix();
    
    translate(translation.x, translation.y, translation.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    
    for (PShapeExt face : faces)
    {
      shape(face.pshape);
    }
    
    popMatrix();
  }
  
  @Override public JSONObject serialize()
  {
    JSONObject jsonModel = new JSONObject();
    
    jsonModel.setString("name", name);
    
    JSONArray jsonFaces = new JSONArray();
    for (PShapeExt face : faces)
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
      jsonFaces.append(jsonFace);
    }
    jsonModel.setJSONArray("faces", jsonFaces);
    
    jsonModel.setJSONObject("material", material.serialize());
    
    return jsonModel;
  }
  
  @Override public void deserialize(JSONObject jsonModel)
  {
    name = jsonModel.getString("name");
    
    material = new Material(jsonModel.getJSONObject("material"));
    
    faces = new ArrayList<PShapeExt>();
    JSONArray jsonFaces = jsonModel.getJSONArray("faces");
    for (int i = 0; i < jsonFaces.size(); i++)
    {
      PShapeExt face = new PShapeExt();
      face.uvs = new ArrayList<PVector>();
      
      face.pshape = createShape();
      face.pshape.beginShape();
      face.pshape.noStroke();
      
      JSONArray jsonFace = jsonFaces.getJSONArray(i);
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
      
      faces.add(face);
    }
  }
}


public class Scene implements IScene
{
  private IOrthographicCamera orthographicCamera;
  private IPerspectiveCamera perspectiveCamera;
  private HashMap<String, ISprite> sprites;
  private HashMap<String, IModel> models;
  
  public Scene()
  {
    orthographicCamera = new OrthographicCamera();
    perspectiveCamera = new PerspectiveCamera();
    sprites = new HashMap<String, ISprite>();
    models = new HashMap<String, IModel>();
  }
  
  @Override public IOrthographicCamera getOrthographicCamera()
  {
    return orthographicCamera;
  }
  
  @Override public void setOrthographicCamera(IOrthographicCamera _orthographicCamera)
  {
    orthographicCamera = _orthographicCamera;
  }
  
  @Override public IPerspectiveCamera getPerspectiveCamera()
  {
    return perspectiveCamera;
  }
  
  @Override public void setPerspectiveCamera(IPerspectiveCamera _perspectiveCamera)
  {
    perspectiveCamera = _perspectiveCamera;
  }
  
  @Override public void addSprite(ISprite sprite)
  {
    sprites.put(sprite.getName(), sprite);
  }
  
  @Override public ISprite getSprite(String name)
  {
    return sprites.get(name);
  }
  
  @Override public void removeSprite(String name)
  {
    sprites.remove(name);
  }
  
  @Override public void addModel(IModel model)
  {
    models.put(model.getName(), model);
  }
  
  @Override public IModel getModel(String name)
  {
    return models.get(name);
  }
  
  @Override public void removeModel(String name)
  {
    models.remove(name);
  }
  
  @Override public void render()
  {
    orthographicCamera.apply();
    
    for (Map.Entry entry : sprites.entrySet())
    {
      ((ISprite)entry.getValue()).render();
    }
    
    perspectiveCamera.apply();
    
    for (Map.Entry entry : models.entrySet())
    {
      ((IModel)entry.getValue()).render();
    }
  }
}