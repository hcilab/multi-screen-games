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
  public void fromFile(String fileName, float minU, float maxU, float minV, float maxV); // gif, jpg, tga, or png
  public void render();
}

public interface ISpriteManager
{
  public void loadAllSprites();
  public ISprite getSprite(String name);
  public void free();
}

public interface ISpriteInstance
{
  public ISprite getSprite();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  public PVector getTint();
  public float getAlpha();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  public void setTint(PVector pTint);
  public void setAlpha(float pAlpha);
  
  public void render();
  
  public int serialize(FlatBufferBuilder builder);
  public void deserialize(FlatSprite flatSprite);
}

public interface IModel
{
  public String getName();
  public void fromOBJ(String objFileName);
  public void render();
}

public interface IModelManager
{
  public void loadAllModels();
  public IModel getModel(String name);
  public void free();
}

public interface IModelInstance
{
  public IModel getModel();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  
  public void render();
  
  public int serialize(FlatBufferBuilder builder);
  public void deserialize(FlatModel flatModel);
}

public interface IFontManager
{
  public PFont getFont(String name);
}

public interface ITextInstance
{
  public String getName();
  
  public void fromXML(XML xmlTextLine);
  
  public void render();
  
  //public int serialize(FlatBufferBuilder builder);
  //public void deserialize(FlatText flatText);
}

public interface IScene
{
  public IOrthographicCamera getOrthographicCamera();
  public void setOrthographicCamera(IOrthographicCamera orthographicCamera);
  
  public IPerspectiveCamera getPerspectiveCamera();
  public void setPerspectiveCamera(IPerspectiveCamera perspectiveCamera);
  
  public int addSpriteInstance(ISpriteInstance sprite);
  public ISpriteInstance getSpriteInstance(int handle);
  public void removeSpriteInstance(int handle);
  
  public int addModelInstance(IModelInstance model);
  public IModelInstance getModelInstance(int handle);
  public void removeModelInstance(int handle);
  
  public void render();
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public abstract class Camera implements ICamera
{
  protected PVector position;
  protected PVector target;
  protected PVector up;
  
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
    position = new PVector(0.0f, 0.0f, -10.0f);
    target = new PVector(0.0f, 0.0f, 0.0f);
    up = new PVector(0.0f, 1.0f, 0.0f);
  }
  
  @Override public void apply()
  {
    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
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
    near = 0.1f;
    far = 1000.0f;
  }
  
  @Override public void apply()
  {
    super.apply();
    
    perspective(fieldOfView, aspectRatio, near, far);
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
}

public class Sprite implements ISprite
{
  private String name;
  private PShape pShape;
  
  public Sprite(String _name)
  {
    name = _name;
    pShape = null;
  }
    
  @Override public String getName()
  {
    return name;
  }
  
  @Override public void fromFile(String fileName, float minU, float maxU, float minV, float maxV)
  {
    pShape = createShape();
    pShape.beginShape();
    pShape.vertex(-0.5f, -0.5f, 0.0f, maxU, minV);
    pShape.vertex(0.5f, -0.5f, 0.0f, minU, minV);
    pShape.vertex(0.5f, 0.5f, 0.0f, minU, maxV);
    pShape.vertex(-0.5f, 0.5f, 0.0f, maxU, maxV);
    pShape.texture(materialManager.getTexture(fileName));
    pShape.endShape(CLOSE);
    pShape.disableStyle();
  }
  
  @Override public void render()
  {
    shape(pShape);
  }
}

public class SpriteManager implements ISpriteManager
{
  private static final String MANIFEST_FILE_NAME = "sprites/sprites-manifest.xml";
  
  private HashMap<String, ISprite> loadedSprites;
  private XML manifest;
  
  public SpriteManager()
  {
    loadedSprites = new HashMap<String, ISprite>();
    manifest = loadXML(MANIFEST_FILE_NAME);
    assert(manifest.getName().equals("Sprites"));
  }
  
  @Override public void loadAllSprites()
  {
    for (XML xmlSprite : manifest.getChildren("Sprite"))
    {
      loadSprite(xmlSprite.getString("name"), xmlSprite);
    }
  }
  
  @Override public ISprite getSprite(String name)
  {
    ISprite sprite = loadedSprites.get(name);
    
    if (sprite != null)
    {
      return sprite;
    }
    
    for (XML xmlSprite : manifest.getChildren("Sprite"))
    {
      if (xmlSprite.getString("name").equals(name))
      {
        return loadSprite(name, xmlSprite);
      }
    }
    
    println("WARNING: No such sprite by name: " + name + " found in sprites-manifest.");
    return null;
  }
  
  private ISprite loadSprite(String name, XML xmlSprite)
  {
    ISprite sprite = new Sprite(name);
    sprite.fromFile(xmlSprite.getString("file"), xmlSprite.getFloat("minU"), xmlSprite.getFloat("maxU"), xmlSprite.getFloat("minV"), xmlSprite.getFloat("maxV"));
    loadedSprites.put(sprite.getName(), sprite);
    return sprite;
  }
  
  @Override public void free()
  {
    loadedSprites.clear();
  }
}

public class SpriteInstance implements ISpriteInstance
{
  private ISprite sprite;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  private PVector tintColor;
  private float alpha;
  
  public SpriteInstance(String spriteName)
  {
    sprite = spriteManager.getSprite(spriteName);
    
    translation = new PVector(0.0f, 0.0f, 0.0f);
    rotation = new PVector(0.0f, 0.0f, 0.0f);
    scale = new PVector(1.0f, 1.0f, 1.0f);
    
    tintColor = new PVector(255.0f, 255.0f, 255.0f);
    alpha = 255.0f;
  }
  
  @Override public ISprite getSprite()
  {
    return sprite;
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
  
  @Override public PVector getTint()
  {
    return tintColor;
  }
  
  @Override public float getAlpha()
  {
    return alpha;
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
  
  @Override public void setTint(PVector pTint)
  {
    tintColor = pTint;
  }
  
  @Override public void setAlpha(float pAlpha)
  {
    alpha = pAlpha;
  }
  
  @Override public void render()
  {
    pushMatrix();
    
    translate(translation.x, translation.y, translation.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    
    noStroke();
    tint(tintColor.x, tintColor.y, tintColor.z, alpha);
    
    sprite.render();
    
    popMatrix();
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int spriteNameOffset = builder.createString(sprite.getName());
    
    FlatSprite.startFlatSprite(builder);
    FlatSprite.addSpriteName(builder, spriteNameOffset);
    FlatSprite.addTranslation(builder, FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z));
    FlatSprite.addRotation(builder, FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z));
    FlatSprite.addScale(builder, FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z));
    FlatSprite.addTint(builder, FlatVec4.createFlatVec4(builder, tintColor.x, tintColor.y, tintColor.z, alpha));
    
    return FlatSprite.endFlatSprite(builder);
  }
  
  @Override public void deserialize(FlatSprite flatSprite)
  {
    sprite = spriteManager.getSprite(flatSprite.spriteName());
    
    FlatVec3 flatTranslation = flatSprite.translation();
    translation = new PVector(flatTranslation.x(), flatTranslation.y(), flatTranslation.z());
    
    FlatVec3 flatRotation = flatSprite.rotation();
    rotation = new PVector(flatRotation.x(), flatRotation.y(), flatRotation.z());
    
    FlatVec3 flatScale = flatSprite.scale();
    scale = new PVector(flatScale.x(), flatScale.y(), flatScale.z());
    
    FlatVec4 flatTint = flatSprite.tint();
    tintColor = new PVector(flatTint.x(), flatTint.y(), flatTint.z());
    alpha = flatTint.w();
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
  
  public Model(String _name)
  {
    name = _name;
    
    faces = new ArrayList<PShapeExt>();
    material = new Material();
  }
  
  @Override public String getName()
  {
    return name;
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
          materialLib = materialManager.getMaterialLib(words[1]);
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
  
  @Override public void render()
  {
    for (PShapeExt face : faces)
    {
      shape(face.pshape);
    }
  }
}

public class ModelManager implements IModelManager
{
  private static final String MANIFEST_FILE_NAME = "models/models-manifest.xml";
  
  private HashMap<String, IModel> loadedModels;
  private XML manifest;
  
  public ModelManager()
  {
    loadedModels = new HashMap<String, IModel>();
    manifest = loadXML(MANIFEST_FILE_NAME);
    assert(manifest.getName().equals("Models"));
  }
  
  @Override public void loadAllModels()
  {
    for (XML xmlModel : manifest.getChildren("Model"))
    {
      IModel model = new Model(xmlModel.getString("name"));
      model.fromOBJ(xmlModel.getString("objFile"));
      loadedModels.put(model.getName(), model);
    }
  }
  
  @Override public IModel getModel(String name)
  {
    IModel model = loadedModels.get(name);
    
    if (model != null)
    {
      return model;
    }
    
    for (XML xmlModel : manifest.getChildren("Model"))
    {
      if (xmlModel.getString("name").equals(name))
      {
        model = new Model(name);
        model.fromOBJ(xmlModel.getString("objFile"));
        loadedModels.put(name, model);
        return model;
      }
    }
    
    println("WARNING: No such model by name: " + name + " found in models-manifest.");
    return null;
  }
  
  @Override public void free()
  {
    loadedModels.clear();
  }
}

public class ModelInstance implements IModelInstance
{
  private IModel model;
  
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  
  public ModelInstance(String modelName)
  {
    model = modelManager.getModel(modelName);
    
    translation = new PVector();
    rotation = new PVector();
    scale = new PVector(1.0f, 1.0f, 1.0f);
  }
  
  @Override public IModel getModel()
  {
    return model;
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
    
    model.render();
    
    popMatrix();
  }
  
  @Override public int serialize(FlatBufferBuilder builder)
  {
    int modelNameOffset = builder.createString(model.getName());
    
    FlatModel.startFlatModel(builder);
    FlatModel.addModelName(builder, modelNameOffset);
    FlatModel.addTranslation(builder, FlatVec3.createFlatVec3(builder, translation.x, translation.y, translation.z));
    FlatModel.addRotation(builder, FlatVec3.createFlatVec3(builder, rotation.x, rotation.y, rotation.z));
    FlatModel.addScale(builder, FlatVec3.createFlatVec3(builder, scale.x, scale.y, scale.z));
    
    return FlatModel.endFlatModel(builder);
  }
  
  @Override public void deserialize(FlatModel flatModel)
  {
    model = modelManager.getModel(flatModel.modelName());
    
    FlatVec3 flatTranslation = flatModel.translation();
    translation = new PVector(flatTranslation.x(), flatTranslation.y(), flatTranslation.z());
    
    FlatVec3 flatRotation = flatModel.rotation();
    rotation = new PVector(flatRotation.x(), flatRotation.y(), flatRotation.z());
    
    FlatVec3 flatScale = flatModel.scale();
    scale = new PVector(flatScale.x(), flatScale.y(), flatScale.z());
  }
}

public class FontManager implements IFontManager
{
  private static final int DEFAULT_FONT_SIZE = 32;
  private static final boolean DEFAULT_ALIASING = true;
  
  private HashMap<String, PFont> fontMap;
  
  public FontManager()
  {
    fontMap = new HashMap<String, PFont>();
  }
  
  @Override public PFont getFont(String name)
  {
    PFont font = fontMap.get(name);
    
    if (font != null)
    {
      return font;
    }
    
    font = createFont(name, DEFAULT_FONT_SIZE, DEFAULT_ALIASING);
    return font;
  }
}


public class Text implements ITextInstance
{
  private String name;
  private String string;
  private PFont font;
  private int alignX;
  private int alignY;
  private PVector translation;
  private PVector rotation;
  private PVector scale;
  private color tcolor;
  
  public Text(String _name)
  {
    name = _name;
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public void fromXML(XML xmlTextLine)
  {
    string = xmlTextLine.getString("string");
    font = fontManager.getFont(xmlTextLine.getString("font"));
    
    String strAlignX = xmlTextLine.getString("alignX");
    switch (strAlignX)
    {
      case "left":
        alignX = LEFT;
        break;
        
      case "right":
        alignX = RIGHT;
        break;
        
      case "center":
      default:
        alignX = CENTER;
        break;
    }
    
    String strAlignY = xmlTextLine.getString("alignY");
    switch (strAlignY)
    {
      case "top":
        alignY = TOP;
        break;
        
      case "center":
        alignY = CENTER;
        break;
        
      case "bottom":
        alignY = BOTTOM;
        break;
        
      case "baseline":
      default:
        alignY = BASELINE;
        break;
    }
    
    translation = new PVector(xmlTextLine.getFloat("x"), xmlTextLine.getFloat("y"));
    tcolor = color(xmlTextLine.getFloat("r"), xmlTextLine.getFloat("g"), xmlTextLine.getFloat("b"), xmlTextLine.getFloat("a"));
  }
  
  @Override public void render()
  {
    pushMatrix();
    
    translate(translation.x, translation.y, translation.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    
    textFont(font);
    textAlign(alignX, alignY);
    strokeWeight(0);
    fill(tcolor);
    text(string, 0.0f, 0.0f, 0.0f);
    
    popMatrix();
  }
  
  //@Override public int serialize(FlatBufferBuilder builder)
  //{
  //  return 0;
  //}
  
  //@Override public void deserialize(FlatText flatText)
  //{
  //}
}


public class Scene implements IScene
{
  private IOrthographicCamera orthographicCamera;
  private IPerspectiveCamera perspectiveCamera;
  private HashMap<Integer, ISpriteInstance> spriteInstances;
  private HashMap<Integer, IModelInstance> modelInstances;
  private int nextSpriteHandle;
  private int nextModelHandle;
  
  public Scene()
  {
    orthographicCamera = new OrthographicCamera();
    perspectiveCamera = new PerspectiveCamera();
    spriteInstances = new HashMap<Integer, ISpriteInstance>();
    modelInstances = new HashMap<Integer, IModelInstance>();
    nextSpriteHandle = 0;
    nextModelHandle = 0;
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
  
  @Override public int addSpriteInstance(ISpriteInstance sprite)
  {
    int spriteHandle = nextSpriteHandle;
    ++nextSpriteHandle;
    spriteInstances.put(spriteHandle, sprite);
    return spriteHandle;
  }
  
  @Override public ISpriteInstance getSpriteInstance(int handle)
  {
    return spriteInstances.get(handle);
  }
  
  @Override public void removeSpriteInstance(int handle)
  {
    spriteInstances.remove(handle);
  }
  
  @Override public int addModelInstance(IModelInstance model)
  {
    int modelHandle = nextModelHandle;
    ++nextModelHandle;
    modelInstances.put(modelHandle, model);
    return modelHandle;
  }
  
  @Override public IModelInstance getModelInstance(int handle)
  {
    return modelInstances.get(handle);
  }
  
  @Override public void removeModelInstance(int handle)
  {
    modelInstances.remove(handle);
  }
  
  @Override public void render()
  {
    orthographicCamera.apply();
    
    for (Map.Entry entry : spriteInstances.entrySet())
    {
      ((ISpriteInstance)entry.getValue()).render();
    }
    
    //perspectiveCamera.apply();
    
    //for (Map.Entry entry : modelInstances.entrySet())
    //{
    //  ((IModelInstance)entry.getValue()).render();
    //}
  }
}
