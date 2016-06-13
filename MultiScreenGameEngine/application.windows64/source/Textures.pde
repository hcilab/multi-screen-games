//======================================================================================================
// Author: David Hanna
//
// A collection of PImages used for texturing objects in the game world. Ensures once-only loading times.
//======================================================================================================

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface ITextureManager
{
  public PImage getTexture(String name);
}


//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public class TextureManager implements ITextureManager
{
  private HashMap<String, PImage> textures;
  
  public TextureManager()
  {
    textures = new HashMap<String, PImage>();
  }
  
  @Override public PImage getTexture(String name)
  {
    if (!textures.containsKey(name))
    {
      textures.put(name, loadImage(name));
    }
    return textures.get(name);
  }
}