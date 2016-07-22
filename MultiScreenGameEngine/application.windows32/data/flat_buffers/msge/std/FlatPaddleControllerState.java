// automatically generated by the FlatBuffers compiler, do not modify

package msge.std;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

@SuppressWarnings("unused")
public final class FlatPaddleControllerState extends Table {
  public static FlatPaddleControllerState getRootAsFlatPaddleControllerState(ByteBuffer _bb) { return getRootAsFlatPaddleControllerState(_bb, new FlatPaddleControllerState()); }
  public static FlatPaddleControllerState getRootAsFlatPaddleControllerState(ByteBuffer _bb, FlatPaddleControllerState obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public FlatPaddleControllerState __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public boolean leftButtonDown() { int o = __offset(4); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean rightButtonDown() { int o = __offset(6); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean upButtonDown() { int o = __offset(8); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean downButtonDown() { int o = __offset(10); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean wButtonDown() { int o = __offset(12); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean aButtonDown() { int o = __offset(14); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean sButtonDown() { int o = __offset(16); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public boolean dButtonDown() { int o = __offset(18); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }

  public static int createFlatPaddleControllerState(FlatBufferBuilder builder,
      boolean leftButtonDown,
      boolean rightButtonDown,
      boolean upButtonDown,
      boolean downButtonDown,
      boolean wButtonDown,
      boolean aButtonDown,
      boolean sButtonDown,
      boolean dButtonDown) {
    builder.startObject(8);
    FlatPaddleControllerState.addDButtonDown(builder, dButtonDown);
    FlatPaddleControllerState.addSButtonDown(builder, sButtonDown);
    FlatPaddleControllerState.addAButtonDown(builder, aButtonDown);
    FlatPaddleControllerState.addWButtonDown(builder, wButtonDown);
    FlatPaddleControllerState.addDownButtonDown(builder, downButtonDown);
    FlatPaddleControllerState.addUpButtonDown(builder, upButtonDown);
    FlatPaddleControllerState.addRightButtonDown(builder, rightButtonDown);
    FlatPaddleControllerState.addLeftButtonDown(builder, leftButtonDown);
    return FlatPaddleControllerState.endFlatPaddleControllerState(builder);
  }

  public static void startFlatPaddleControllerState(FlatBufferBuilder builder) { builder.startObject(8); }
  public static void addLeftButtonDown(FlatBufferBuilder builder, boolean leftButtonDown) { builder.addBoolean(0, leftButtonDown, false); }
  public static void addRightButtonDown(FlatBufferBuilder builder, boolean rightButtonDown) { builder.addBoolean(1, rightButtonDown, false); }
  public static void addUpButtonDown(FlatBufferBuilder builder, boolean upButtonDown) { builder.addBoolean(2, upButtonDown, false); }
  public static void addDownButtonDown(FlatBufferBuilder builder, boolean downButtonDown) { builder.addBoolean(3, downButtonDown, false); }
  public static void addWButtonDown(FlatBufferBuilder builder, boolean wButtonDown) { builder.addBoolean(4, wButtonDown, false); }
  public static void addAButtonDown(FlatBufferBuilder builder, boolean aButtonDown) { builder.addBoolean(5, aButtonDown, false); }
  public static void addSButtonDown(FlatBufferBuilder builder, boolean sButtonDown) { builder.addBoolean(6, sButtonDown, false); }
  public static void addDButtonDown(FlatBufferBuilder builder, boolean dButtonDown) { builder.addBoolean(7, dButtonDown, false); }
  public static int endFlatPaddleControllerState(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
};
