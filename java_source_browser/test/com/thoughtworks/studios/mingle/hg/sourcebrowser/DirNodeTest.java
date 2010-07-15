//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.assertThat;
import org.junit.Test;

public class DirNodeTest {

  @Test
  public void rootNodeReportsThatItIsRoot() {
    DirNode node = new DirNode(null, "", null, null, null);
    assertThat(node.isRootNode(), equalTo(true));
  }

  @Test
  public void nonRootNodeReportsThatItIsNotRoot() {
    DirNode node = new DirNode(null, "foo", null, null, null);
    assertThat(node.isRootNode(), equalTo(false));
  }
}
