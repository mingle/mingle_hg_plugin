//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.assertThat;
import org.junit.Test;

import java.util.Map;
import java.io.OutputStream;

public class FileNodeTest {

  @Test
  public void isBinaryDelegatesToSourceBrowser() {
    DummyBrowser browser = new DummyBrowser();
    FileNode node = new FileNode(browser, null, null, null, null);

    browser.setReturnValue(true);
    assertThat(node.isBinary(), equalTo(true));
    browser.setReturnValue(false);
    assertThat(node.isBinary(), equalTo(false));
  }

  class DummyBrowser implements Browser {

    private boolean returnValue;

    public void setReturnValue(boolean value) {
      this.returnValue = value;
    }

    public Node[] childNodesFor(DirNode dirNode, Map<String, String> baseContent) {
      return new Node[0];
    }

    public boolean isBinary(String path, String rev) {
      return returnValue;
    }

    public void ensureFileCacheSynchedFor(Integer changesetNumber, String changesetIdentifier) {
    }

    public Map<String, String> rawFileCacheContent(Integer revisionNumber) {
      return null;
    }

    public Node node(String path, Integer changesetNumber, String changesetIdentifier) {
      return null;
    }

    public Node tipNode(String path, Integer likelyTipNumber, String likelyTipIdentifier) {
      return null;
    }

    public void fileContentsFor(FileNode fileNode, OutputStream out) {
      
    }
  }
}
