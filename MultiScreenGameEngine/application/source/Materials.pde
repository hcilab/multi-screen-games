//======================================================================================================
// Author: David Hanna
//
// A collection of material libs. Each material lib is a .mtl file containing material definitions.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface IMaterial
{
  public int        fromMTL(String[] mtlFile, int lineIndex);
  public String     getName();
  public PVector    getAmbientReflect();
  public PVector    getDiffuseReflect();
  public PVector    getSpecularReflect();
  public float      getSpecularExponent();
  public float      getDissolve();
  public PImage     getTexture();
}

public interface IMaterialLib
{
  public void      fromMTL(String mtlFileName);
  public String    getName();
  public IMaterial getMaterial(String name);
}

public interface IMaterialManager
{
  public PImage getTexture(String name);
  public IMaterialLib getMaterialLib(String mtlFileName);
}


//----------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//----------------------------------------------------------------------------------------------------

public class Material implements IMaterial
{
  private String name;
  
  private PVector ambientReflect;
  private PVector diffuseReflect;
  private PVector specularReflect;
  private float specularExponent;
  
  private float dissolve; // transparency
  
  private String textureFileName;
  private PImage texture;
  
  public Material()
  {
    ambientReflect = new PVector();
    diffuseReflect = new PVector();
    specularReflect = new PVector();
  }
  
  // Returns the line index this method stopped parsing (the end of the material).
  @Override public int fromMTL(String[] mtlFile, int lineIndex)
  {
    String[] firstLineWords = mtlFile[lineIndex].split(" ");
    assert(firstLineWords[0].equals("newmtl"));
    name = firstLineWords[1];
    ++lineIndex;
    
    for (String line; lineIndex < mtlFile.length; ++lineIndex)
    {
      line = mtlFile[lineIndex];
      String[] words = line.split(" ");
      
      switch(words[0])
      {
        case "Ka":
          ambientReflect = new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3]));
          break;
          
        case "Kd":
          diffuseReflect = new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3]));
          break;
          
        case "Ks":
          specularReflect = new PVector(Float.parseFloat(words[1]), Float.parseFloat(words[2]), Float.parseFloat(words[3]));
          break;
          
        case "Ns":
          specularExponent = Float.parseFloat(words[1]);
          break;
          
        case "d":
          dissolve = Float.parseFloat(words[1]);
          break;
          
        case "Tr":
          dissolve = 1.0f - Float.parseFloat(words[1]);
          break;
          
        case "map_Kd":
          textureFileName = words[1];
          texture = materialManager.getTexture(textureFileName);
          break;
          
        case "newmtl":
          return lineIndex;
      }
    }
    
    return lineIndex;
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public PVector getAmbientReflect()
  {
    return ambientReflect;
  }
  
  @Override public PVector getDiffuseReflect()
  {
    return diffuseReflect;
  }
  
  @Override public PVector getSpecularReflect()
  {
    return specularReflect;
  }
  
  @Override public float getSpecularExponent()
  {
    return specularExponent;
  }
  
  @Override public float getDissolve()
  {
    return dissolve;
  }
  
  @Override public PImage getTexture()
  {
    return texture;
  }
}

public class MaterialLib implements IMaterialLib
{
  private String name;
  private HashMap<String, IMaterial> materials;
  
  public MaterialLib()
  {
    materials = new HashMap<String, IMaterial>();
  }
  
  @Override public void fromMTL(String mtlFileName)
  {
    name = mtlFileName;
    String[] mtlFile = loadStrings(mtlFileName);
    
    for (int lineIndex = 0; lineIndex < mtlFile.length;)
    {
      String[] words = mtlFile[lineIndex].split(" ");
      
      if (words[0].equals("newmtl"))
      {
        IMaterial material = new Material();
        lineIndex = material.fromMTL(mtlFile, lineIndex);
        materials.put(material.getName(), material);
      }
      else
      {
        ++lineIndex;
      }
    }
  }
  
  @Override public String getName()
  {
    return name;
  }
  
  @Override public IMaterial getMaterial(String name)
  {
    return materials.get(name);
  }
}

public class MaterialManager implements IMaterialManager
{
  private HashMap<String, PImage> textures;
  private HashMap<String, IMaterialLib> materialLibs;
  
  public MaterialManager()
  {
    textures = new HashMap<String, PImage>();
    materialLibs = new HashMap<String, IMaterialLib>();
  }
  
  @Override public PImage getTexture(String name)
  {
    if (!textures.containsKey(name))
    {
      textures.put(name, loadImage(name));
    }
    return textures.get(name);
  }
  
  @Override public IMaterialLib getMaterialLib(String mtlFileName)
  {
    if (!materialLibs.containsKey(mtlFileName))
    {
      IMaterialLib materialLib = new MaterialLib();
      materialLib.fromMTL(mtlFileName);
      materialLibs.put(materialLib.getName(), materialLib);
    }
    return materialLibs.get(mtlFileName);
  }
}
