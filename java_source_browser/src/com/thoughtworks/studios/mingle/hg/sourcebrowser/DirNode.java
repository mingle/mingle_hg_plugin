//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

public class DirNode extends Node {

  private Browser browser;
  public Node[] children;

  public DirNode(Browser browser, String path, Integer changesetNumber,
                 String changesetIdentifier, String mostRecentChangesetIdentifier) {
    super(path, changesetNumber, changesetIdentifier, mostRecentChangesetIdentifier);
    this.browser = browser;
  }

  public boolean isDir() {
    return true;
  }

  public Node[] getChildren() {
    if (children == null) {
      children = browser.childNodesFor(this, null);
    }
    return children;
  }

  public void setChildren(Node[] children) {
    this.children = children;
  }

  public boolean isRootNode() {
    return path().equals("");
  }
}
