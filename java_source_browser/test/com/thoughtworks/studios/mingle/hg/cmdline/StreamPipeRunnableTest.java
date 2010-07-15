//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.cmdline;

import org.junit.Test;
import static org.junit.Assert.assertThat;
import static org.hamcrest.CoreMatchers.equalTo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

public class StreamPipeRunnableTest {

  @Test
  public void pipeWorks() throws Exception {
    String content = "expected text";
    ByteArrayInputStream in = new ByteArrayInputStream(content.getBytes());
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    PipeRunnable pipeRunnable = new StreamPipeRunnable(in, out);
    pipeRunnable.run();
    assertThat(out.toString(), equalTo(content));
  }
}
