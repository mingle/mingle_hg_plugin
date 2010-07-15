//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.FileOutputStream;

public class FileUtils {

  public static void mkdirP(File dir) {
    if (dir.exists()) {
      return;
    }
    
    File parent = dir.getParentFile();
    if (parent != null) {
      mkdirP(parent);
    }

    dir.mkdir();
  }

  public static void rmRf(File file) {
    if (file.isDirectory()) {
      for (File entry : file.listFiles()) {
        rmRf(entry);
      }
    }

    file.delete();
  }

  public static void copyFileToDir(File sourceFile, File destDir) throws IOException {
    FileInputStream in = new FileInputStream(sourceFile);
    FileOutputStream out = new FileOutputStream(destDir.getAbsolutePath() + File.separator + sourceFile.getName());
    byte[] buffer = new byte[1024];
    int bytesRead;
    while ((bytesRead = in.read(buffer)) > -1) {
      out.write(buffer, 0, bytesRead);
    }
    out.flush();
    out.close();
  }

}
