//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import com.thoughtworks.studios.mingle.hg.util.ArrayUtils;

import java.util.Date;

public abstract class Node {

  private String path;
  private Integer changesetNumber;
  private String changesetIdentifier;
  private String mostRecentChangesetIdentifier;
  private String name;
  private String[] pathComponents;
  private String[] parentPathComponents;
  private String parentDisplayPath;
  private String mostRecentCommitter;
  private Date mostRecentCommitTime;
  private String mostRecentCommitDesc;

  public Node(String path, Integer changesetNumber,
              String changesetIdentifier, String mostRecentChangesetIdentifier) {

    this.path = path;
    this.changesetNumber = changesetNumber;
    this.changesetIdentifier = changesetIdentifier;
    this.mostRecentChangesetIdentifier = mostRecentChangesetIdentifier;
  }

  public String name() {
    if (name == null) {
      String[] pathComponents = pathComponents();
      if (pathComponents.length == 0) {
        name = "";
      } else {
        name = pathComponents[pathComponents.length - 1];
      }
    }

    return name;
  }

  public String[] pathComponents() {
    if (pathComponents == null) {
      if (path.equals("")) {
        return new String[0];
      } else {
        pathComponents = path.split("/");
      }
    }

    return pathComponents;
  }

  public String[] parentPathComponents() {
    if (parentPathComponents == null) {
      String[] pathComponents = pathComponents();
      if (pathComponents.length < 2) {
        parentPathComponents = new String[0];
      } else {
        parentPathComponents = ArrayUtils.cutLastOne(pathComponents);
      }
    }
    return parentPathComponents;
  }

  public String parentDisplayPath() {
    String[] parentPathComponents = parentPathComponents();
    if (parentDisplayPath == null) {
      StringBuilder builder = new StringBuilder();
      for (int i = 0; i < parentPathComponents.length; i++) {
        builder.append(parentPathComponents[i]);
        if (i < (parentPathComponents.length - 1)) {
          builder.append("/");
        }
      }
      parentDisplayPath = builder.toString();
    }
    return parentDisplayPath;
  }

  public Integer changesetNumber() {
    return changesetNumber;
  }

  public String changesetIdentifier() {
    return changesetIdentifier;
  }

  public String mostRecentChangesetIdentifier() {
    return mostRecentChangesetIdentifier;
  }

  public String path() {
    return path;
  }

  public String displayPath() {
    return path;
  }

  public String getMostRecentCommitter() {
    return mostRecentCommitter;
  }

  public void setMostRecentCommitter(String mostRecentCommitter) {
    this.mostRecentCommitter = mostRecentCommitter;
  }

  public Date getMostRecentCommitTime() {
    return mostRecentCommitTime;
  }

  public void setMostRecentCommitTime(Date mostRecentCommitTime) {
    this.mostRecentCommitTime = mostRecentCommitTime;
  }

  public String getMostRecentCommitDesc() {
    return mostRecentCommitDesc;
  }

  public void setMostRecentCommitDesc(String mostRecentCommitDesc) {
    this.mostRecentCommitDesc = mostRecentCommitDesc;
  }

  public abstract boolean isDir();
}
