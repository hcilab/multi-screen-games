// automatically generated by the FlatBuffers compiler, do not modify

package msge.std;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

@SuppressWarnings("unused")
public final class FlatTranslateOverTimeComponent extends Table {
  public static FlatTranslateOverTimeComponent getRootAsFlatTranslateOverTimeComponent(ByteBuffer _bb) { return getRootAsFlatTranslateOverTimeComponent(_bb, new FlatTranslateOverTimeComponent()); }
  public static FlatTranslateOverTimeComponent getRootAsFlatTranslateOverTimeComponent(ByteBuffer _bb, FlatTranslateOverTimeComponent obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public FlatTranslateOverTimeComponent __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public boolean movingLeft() { int o = __offset(4); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public float xUnitsPerMillisecond() { int o = __offset(6); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public float leftLimit() { int o = __offset(8); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public float rightLimit() { int o = __offset(10); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public boolean movingDown() { int o = __offset(12); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public float yUnitsPerMillisecond() { int o = __offset(14); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public float lowerLimit() { int o = __offset(16); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public float upperLimit() { int o = __offset(18); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public boolean movingForward() { int o = __offset(20); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public float zUnitsPerMillisecond() { int o = __offset(22); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public float forwardLimit() { int o = __offset(24); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }
  public float backwardLimit() { int o = __offset(26); return o != 0 ? bb.getFloat(o + bb_pos) : 0.0f; }

  public static int createFlatTranslateOverTimeComponent(FlatBufferBuilder builder,
      boolean movingLeft,
      float xUnitsPerMillisecond,
      float leftLimit,
      float rightLimit,
      boolean movingDown,
      float yUnitsPerMillisecond,
      float lowerLimit,
      float upperLimit,
      boolean movingForward,
      float zUnitsPerMillisecond,
      float forwardLimit,
      float backwardLimit) {
    builder.startObject(12);
    FlatTranslateOverTimeComponent.addBackwardLimit(builder, backwardLimit);
    FlatTranslateOverTimeComponent.addForwardLimit(builder, forwardLimit);
    FlatTranslateOverTimeComponent.addZUnitsPerMillisecond(builder, zUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addUpperLimit(builder, upperLimit);
    FlatTranslateOverTimeComponent.addLowerLimit(builder, lowerLimit);
    FlatTranslateOverTimeComponent.addYUnitsPerMillisecond(builder, yUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addRightLimit(builder, rightLimit);
    FlatTranslateOverTimeComponent.addLeftLimit(builder, leftLimit);
    FlatTranslateOverTimeComponent.addXUnitsPerMillisecond(builder, xUnitsPerMillisecond);
    FlatTranslateOverTimeComponent.addMovingForward(builder, movingForward);
    FlatTranslateOverTimeComponent.addMovingDown(builder, movingDown);
    FlatTranslateOverTimeComponent.addMovingLeft(builder, movingLeft);
    return FlatTranslateOverTimeComponent.endFlatTranslateOverTimeComponent(builder);
  }

  public static void startFlatTranslateOverTimeComponent(FlatBufferBuilder builder) { builder.startObject(12); }
  public static void addMovingLeft(FlatBufferBuilder builder, boolean movingLeft) { builder.addBoolean(0, movingLeft, false); }
  public static void addXUnitsPerMillisecond(FlatBufferBuilder builder, float xUnitsPerMillisecond) { builder.addFloat(1, xUnitsPerMillisecond, 0.0f); }
  public static void addLeftLimit(FlatBufferBuilder builder, float leftLimit) { builder.addFloat(2, leftLimit, 0.0f); }
  public static void addRightLimit(FlatBufferBuilder builder, float rightLimit) { builder.addFloat(3, rightLimit, 0.0f); }
  public static void addMovingDown(FlatBufferBuilder builder, boolean movingDown) { builder.addBoolean(4, movingDown, false); }
  public static void addYUnitsPerMillisecond(FlatBufferBuilder builder, float yUnitsPerMillisecond) { builder.addFloat(5, yUnitsPerMillisecond, 0.0f); }
  public static void addLowerLimit(FlatBufferBuilder builder, float lowerLimit) { builder.addFloat(6, lowerLimit, 0.0f); }
  public static void addUpperLimit(FlatBufferBuilder builder, float upperLimit) { builder.addFloat(7, upperLimit, 0.0f); }
  public static void addMovingForward(FlatBufferBuilder builder, boolean movingForward) { builder.addBoolean(8, movingForward, false); }
  public static void addZUnitsPerMillisecond(FlatBufferBuilder builder, float zUnitsPerMillisecond) { builder.addFloat(9, zUnitsPerMillisecond, 0.0f); }
  public static void addForwardLimit(FlatBufferBuilder builder, float forwardLimit) { builder.addFloat(10, forwardLimit, 0.0f); }
  public static void addBackwardLimit(FlatBufferBuilder builder, float backwardLimit) { builder.addFloat(11, backwardLimit, 0.0f); }
  public static int endFlatTranslateOverTimeComponent(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
};

