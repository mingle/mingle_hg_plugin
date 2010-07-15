//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import com.thoughtworks.studios.mingle.hg.hgcmdline.HgClient;
import com.thoughtworks.studios.mingle.hg.util.ArrayUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class ContentBuilder {
  private HgClient hgClient;

  public ContentBuilder(HgClient hgClient) {
    this.hgClient = hgClient;
  }

  public void buildContent(String changeIdentifier, Map<String, String> baseContent) {
    for (String file : hgClient.filesInChangeset(changeIdentifier)) {
      updatePaths(changeIdentifier, baseContent, file.split("/"), false);
    }

    for (String file : hgClient.deletedFilesInChangeset(changeIdentifier)) {
      baseContent.remove(file);
    }

    removeEmptyDirs(baseContent);

    baseContent.put("/", changeIdentifier);
  }

  private void updatePaths(String changesetIdentifier, Map<String, String> content, String[] parts, Boolean isDir) {
    if (parts.length == 0) {
      return;
    }

    String path = joinString(parts, "/");
    if (isDir) {
      path += "/";
    }

    content.put(path, changesetIdentifier);

    updatePaths(changesetIdentifier, content, ArrayUtils.cutLastOne(parts), true);
  }

  private void removeEmptyDirs(Map<String, String> content) {
    List<String> emptyDirs = new ArrayList<String>();

    List<String> paths = new ArrayList<String>(content.keySet());
    Collections.sort(paths);
    Collections.reverse(paths);

    for (int i = 0; i < paths.size(); i++) {
      String path = paths.get(i);
      if (path.endsWith("/")) {
        if (i == 0) {
          emptyDirs.add(path);
        } else {
          if (!paths.get(i - 1).startsWith(path)) {
            emptyDirs.add(path);
          }
        }

        for (String emptyDir : emptyDirs) {
          content.remove(emptyDir);
        }
      }
    }

  }

  public String joinString(String[] parts, String joinWith) {
    StringBuilder builder = new StringBuilder();
    for (int i = 0; i < parts.length; i++) {
      builder.append(parts[i]);
      if (i < (parts.length - 1)) {
        builder.append(joinWith);
      }
    }

    return builder.toString();
  }

}
