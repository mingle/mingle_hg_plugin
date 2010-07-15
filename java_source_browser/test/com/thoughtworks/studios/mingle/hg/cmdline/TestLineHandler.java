//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.cmdline;

import static org.junit.Assert.assertThat;
import static org.hamcrest.CoreMatchers.equalTo;

import java.util.List;
import java.util.ArrayList;

public   class TestLineHandler implements LineHandler {
    private List<String> lines = new ArrayList<String>();

    public void handleLine(String line) {
      lines.add(line);
    }

    public void assertLinesEqual(List<String> expectedLines) {
      assertThat(lines, equalTo(expectedLines));
    }
  }