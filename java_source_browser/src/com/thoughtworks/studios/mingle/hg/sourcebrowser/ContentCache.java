//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import com.thoughtworks.studios.mingle.hg.util.FileUtils;

public class ContentCache {
  public static final String FILE_FORMAT_VERSION = "2";

  private String cachePath;

  public ContentCache(String cachePath) {
    this.cachePath = cachePath;
  }

  public Map<String, String> readFor(Integer revisionNumber) {
    if (!isCached(revisionNumber)) {
      throw new HgSourceBrowserException("Changeset " + revisionNumber + " is not cached!");
    }

    Map<String, String> content = new HashMap<String, String>();

    try {
      String key = null;
      ZipFile zipFile = new ZipFile(cachePathFor(revisionNumber));
      ZipEntry entry = zipFile.getEntry("zipEntry");

      BufferedReader reader = new BufferedReader(new InputStreamReader(zipFile.getInputStream(entry)));
      String line;
      while ((line = reader.readLine()) != null) {
        if (key == null) {
          key = line;
        } else {
          content.put(key, line);
          key = null;
        }
      }
    } catch (IOException ex) {
      throw new HgSourceBrowserException(ex);
    }

    return content;
  }

  public void writeFor(Integer revisionNumber, Map<String, String> content) {
    try {
      String cachePath = cachePathFor(revisionNumber);
      new File(cachePath).getParentFile().mkdirs();

      FileOutputStream fos = new FileOutputStream(cachePath);
      ZipOutputStream zos = new ZipOutputStream(fos);
      zos.putNextEntry(new ZipEntry("zipEntry"));
      BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(zos));

      for (String path : content.keySet()) {
        writer.write(path);
        writer.newLine();
        writer.write(content.get(path));
        writer.newLine();
      }
      writer.close();

    } catch (IOException ex) {
      throw new HgSourceBrowserException(ex);
    }
  }

  public Boolean isCached(Integer revisionNumber) {
    return new File(cachePathFor(revisionNumber)).exists();
  }

  private String cachePathFor(Integer revisionNumber) {
    StringBuilder builder = new StringBuilder();
    builder.append(this.cachePath);
    builder.append(File.separator);
    builder.append(FILE_FORMAT_VERSION);
    builder.append(File.separator);
    builder.append(revisionNumber % 256);
    builder.append(File.separator);
    builder.append(revisionNumber);
    builder.append(File.separator);
    builder.append("source_browser_info.yml");

    return builder.toString();
  }

  public void cleanUpObsoleteCacheFiles() {

    try {
      File[] toBeDeleted = new File(this.cachePath).listFiles(new FileFilter() {
        public boolean accept(File file) {
          boolean isSystemDotFile = file.getName().equals(".") || file.getName().equals("..");
          return !isSystemDotFile && (!file.isDirectory() || !file.getName().equals(FILE_FORMAT_VERSION));
        }
      });
      for (int i = 0; i < toBeDeleted.length; i++) {
        FileUtils.rmRf(toBeDeleted[i]);
      }
    } catch (Exception ioEx) {
      throw new HgSourceBrowserException(ioEx);
    }
  }

}

