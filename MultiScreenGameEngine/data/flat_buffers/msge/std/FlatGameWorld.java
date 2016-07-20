// automatically generated by the FlatBuffers compiler, do not modify

package msge.std;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

@SuppressWarnings("unused")
public final class FlatGameWorld extends Table {
  public static FlatGameWorld getRootAsFlatGameWorld(ByteBuffer _bb) { return getRootAsFlatGameWorld(_bb, new FlatGameWorld()); }
  public static FlatGameWorld getRootAsFlatGameWorld(ByteBuffer _bb, FlatGameWorld obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public FlatGameWorld __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public FlatGameObject gameObjects(int j) { return gameObjects(new FlatGameObject(), j); }
  public FlatGameObject gameObjects(FlatGameObject obj, int j) { int o = __offset(4); return o != 0 ? obj.__init(__indirect(__vector(o) + j * 4), bb) : null; }
  public int gameObjectsLength() { int o = __offset(4); return o != 0 ? __vector_len(o) : 0; }

  public static int createFlatGameWorld(FlatBufferBuilder builder,
      int gameObjectsOffset) {
    builder.startObject(1);
    FlatGameWorld.addGameObjects(builder, gameObjectsOffset);
    return FlatGameWorld.endFlatGameWorld(builder);
  }

  public static void startFlatGameWorld(FlatBufferBuilder builder) { builder.startObject(1); }
  public static void addGameObjects(FlatBufferBuilder builder, int gameObjectsOffset) { builder.addOffset(0, gameObjectsOffset, 0); }
  public static int createGameObjectsVector(FlatBufferBuilder builder, int[] data) { builder.startVector(4, data.length, 4); for (int i = data.length - 1; i >= 0; i--) builder.addOffset(data[i]); return builder.endVector(); }
  public static void startGameObjectsVector(FlatBufferBuilder builder, int numElems) { builder.startVector(4, numElems, 4); }
  public static int endFlatGameWorld(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
};
