//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

public class FileNode extends Node {

  private Browser browser;

  public FileNode(Browser browser, String path, Integer changesetNumber,
                  String changesetIdentifier, String mostRecentChangesetIdentifier) {
    super(path, changesetNumber, changesetIdentifier, mostRecentChangesetIdentifier);
    this.browser = browser;
  }

  public boolean isDir() {
    return false;
  }

  public boolean isBinary() {
    return browser.isBinary(path(), changesetIdentifier());
  }
}
