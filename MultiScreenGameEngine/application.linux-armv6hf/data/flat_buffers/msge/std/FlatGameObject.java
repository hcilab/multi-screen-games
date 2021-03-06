// automatically generated by the FlatBuffers compiler, do not modify

package msge.std;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

@SuppressWarnings("unused")
public final class FlatGameObject extends Table {
  public static FlatGameObject getRootAsFlatGameObject(ByteBuffer _bb) { return getRootAsFlatGameObject(_bb, new FlatGameObject()); }
  public static FlatGameObject getRootAsFlatGameObject(ByteBuffer _bb, FlatGameObject obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public FlatGameObject __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public int uid() { int o = __offset(4); return o != 0 ? bb.getInt(o + bb_pos) : 0; }
  public String tag() { int o = __offset(6); return o != 0 ? __string(o + bb_pos) : null; }
  public ByteBuffer tagAsByteBuffer() { return __vector_as_bytebuffer(6, 1); }
  public msge.std.FlatVec3 translation() { return translation(new msge.std.FlatVec3()); }
  public msge.std.FlatVec3 translation(msge.std.FlatVec3 obj) { int o = __offset(8); return o != 0 ? obj.__init(o + bb_pos, bb) : null; }
  public msge.std.FlatVec3 rotation() { return rotation(new msge.std.FlatVec3()); }
  public msge.std.FlatVec3 rotation(msge.std.FlatVec3 obj) { int o = __offset(10); return o != 0 ? obj.__init(o + bb_pos, bb) : null; }
  public msge.std.FlatVec3 scale() { return scale(new msge.std.FlatVec3()); }
  public msge.std.FlatVec3 scale(msge.std.FlatVec3 obj) { int o = __offset(12); return o != 0 ? obj.__init(o + bb_pos, bb) : null; }
  public FlatComponentTable componentTables(int j) { return componentTables(new FlatComponentTable(), j); }
  public FlatComponentTable componentTables(FlatComponentTable obj, int j) { int o = __offset(14); return o != 0 ? obj.__init(__indirect(__vector(o) + j * 4), bb) : null; }
  public int componentTablesLength() { int o = __offset(14); return o != 0 ? __vector_len(o) : 0; }

  public static void startFlatGameObject(FlatBufferBuilder builder) { builder.startObject(6); }
  public static void addUid(FlatBufferBuilder builder, int uid) { builder.addInt(0, uid, 0); }
  public static void addTag(FlatBufferBuilder builder, int tagOffset) { builder.addOffset(1, tagOffset, 0); }
  public static void addTranslation(FlatBufferBuilder builder, int translationOffset) { builder.addStruct(2, translationOffset, 0); }
  public static void addRotation(FlatBufferBuilder builder, int rotationOffset) { builder.addStruct(3, rotationOffset, 0); }
  public static void addScale(FlatBufferBuilder builder, int scaleOffset) { builder.addStruct(4, scaleOffset, 0); }
  public static void addComponentTables(FlatBufferBuilder builder, int componentTablesOffset) { builder.addOffset(5, componentTablesOffset, 0); }
  public static int createComponentTablesVector(FlatBufferBuilder builder, int[] data) { builder.startVector(4, data.length, 4); for (int i = data.length - 1; i >= 0; i--) builder.addOffset(data[i]); return builder.endVector(); }
  public static void startComponentTablesVector(FlatBufferBuilder builder, int numElems) { builder.startVector(4, numElems, 4); }
  public static int endFlatGameObject(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
};

