//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.util;

public class ArrayUtils {

  public static String[] cutLastOne(String[] master) {
    if (master.length == 0) {
      return new String[0];
    }
    
    String[] result = new String[master.length - 1];
    for (int i = 0; i < result.length; i++) {
      result[i] = master[i];
    }
    return result;
  }

  public static String[] cutFirstOne(String[] master) {
    if (master.length == 0) {
      return new String[0];
    }
    
    String[] result = new String[master.length - 1];
    for (int i = 0; i < result.length; i++) {
      result[i] = master[i+1];
    }
    return result;
  }

  public static String join(String[] array, String joinWith) {
    StringBuilder builder = new StringBuilder();
    for (int i = 0; i < array.length; i++) {
      builder.append(array[i]);
      if (i < (array.length - 1)) {
        builder.append(joinWith);
      }
    }
    return builder.toString();
  }
}
