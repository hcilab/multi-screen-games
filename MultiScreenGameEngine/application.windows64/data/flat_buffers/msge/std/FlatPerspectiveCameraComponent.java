// automatically generated by the FlatBuffers compiler, do not modify

package msge.std;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

@SuppressWarnings("unused")
public final class FlatPerspectiveCameraComponent extends Table {
  public static FlatPerspectiveCameraComponent getRootAsFlatPerspectiveCameraComponent(ByteBuffer _bb) { return getRootAsFlatPerspectiveCameraComponent(_bb, new FlatPerspectiveCameraComponent()); }
  public static FlatPerspectiveCameraComponent getRootAsFlatPerspectiveCameraComponent(ByteBuffer _bb, FlatPerspectiveCameraComponent obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public FlatPerspectiveCameraComponent __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }


  public static void startFlatPerspectiveCameraComponent(FlatBufferBuilder builder) { builder.startObject(0); }
  public static int endFlatPerspectiveCameraComponent(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
};

