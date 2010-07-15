//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.assertThat;
import org.junit.Test;

public class NodeTest {

  @Test
  public void nameReturnsBlankForRoot() {
    Node node = new DirNode(null, "", null, null, null);
    assertThat(node.name(), equalTo(""));
  }

  @Test
  public void nameIsOnlyLastPathComponent() {
    Node node = new DirNode(null, "src/bar/foo", null, null, null);
    assertThat(node.name(), equalTo("foo"));
  }

  @Test
  public void pathComponentsIsEmptyForRoot() {
    Node node = new DirNode(null, "", null, null, null);
    assertThat(node.pathComponents().length, equalTo(0));
  }

  @Test
  public void pathComponentsForTopLevelEntryAreCorrect() {
    Node node = new FileNode(null, "README", null, null, null);
    assertThat(node.pathComponents(), equalTo(new String[]{"README"}));
  }

  @Test
  public void pathComponentsForDeeperEntryAreCorrect() {
    Node node = new FileNode(null, "src/foo/bar.rb", null, null, null);
    assertThat(node.pathComponents(), equalTo(new String[]{"src", "foo", "bar.rb"}));
  }

  @Test
  public void parentPathComponentsIsEmptyForRoot() {
    Node node = new DirNode(null, "", null, null, null);
    assertThat(node.parentPathComponents().length, equalTo(0));
  }

  @Test
  public void parentPathComponentsIsEmptyForTopLevelEntry() {
    Node node = new FileNode(null, "README", null, null, null);
    assertThat(node.parentPathComponents().length, equalTo(0));
  }

  @Test
  public void parentPathComponentsForDeeperEntryIsCorrect() {
    Node node = new FileNode(null, "src/foo/bar.rb", null, null, null);
    assertThat(node.parentPathComponents(), equalTo(new String[]{"src", "foo"}));
  }

  @Test
  public void parentDisplayPathForRoot() {
    Node node = new FileNode(null, "", null, null, null);
    assertThat(node.parentDisplayPath(), equalTo(""));  
  }

  @Test
  public void parentDisplayPathForNonRoot() {
    Node node = new FileNode(null, "src/foo/bar.rb", null, null, null);
    assertThat(node.parentDisplayPath(), equalTo("src/foo"));
  }

}
