//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.cmdline;

import org.junit.Test;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.not;

import java.io.ByteArrayOutputStream;
import java.util.Arrays;

public class CommandExecutorTest {

  @Test
  public void captureOutputWhenStreamingToOutputStream() {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    String[] cmd = TestProgram.cmdFor(new String[]{"echo", "foobar"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    exec.run(outputStream);
    assertThat(outputStream.toString(), equalTo("foobar"));
  }

  @Test
  public void captureErrorWhenStreamingToOutputStream() {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    String[] cmd = TestProgram.cmdFor(new String[]{"error", "something went wrong", "173"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    exec.run(outputStream);

    assertThat(exec.isError(), equalTo(true));
    assertThat(exec.standardErrorText(), equalTo("something went wrong"));
    assertThat(exec.returnCode(), equalTo(173));
  }

  @Test
  public void timeoutWhenStreamingtoOutputStream() {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    String[] cmd = TestProgram.cmdFor(new String[]{"sleep", "5000"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd), 100L);
    try {
      exec.run(outputStream);
      fail("should have timed out!");
    } catch (CommandExecutorException ex) {
      assertThat(ex.getMessage().contains("timed out"), equalTo(true));
      assertThat(exec.returnCode(), not(equalTo(0)));
    }
  }

  @Test
  public void captureOutputWhenStreamingToLineHandler() {
    TestLineHandler lineHandler = new TestLineHandler();
    String[] cmd = TestProgram.cmdFor(new String[]{"echo", "foo\nbar\n"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    exec.run(lineHandler);
    String[] expectedLines = new String[]{"foo", "bar"};
    lineHandler.assertLinesEqual(Arrays.asList(expectedLines));
  }

  @Test
  public void captureOutputWithoutStreaming() {
    String[] cmd = TestProgram.cmdFor(new String[]{"echo", "foobar"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    assertThat(exec.run(), equalTo("foobar"));    
  }

  @Test
  public void captureChineseOutputWhenStreamingToOutputStream() throws Exception {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    String[] cmd = TestProgram.cmdFor(new String[]{"chinese"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    exec.run(outputStream);
    assertThat(outputStream.toString("UTF-8"), equalTo("这是中文"));
  }

  @Test
  public void captureChineseOutputWhenStreamingToLineHandler() {
    TestLineHandler lineHandler = new TestLineHandler();
    String[] cmd = TestProgram.cmdFor(new String[]{"chinese"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    exec.run(lineHandler);
    String[] expectedLines = new String[]{"这是中文"};
    lineHandler.assertLinesEqual(Arrays.asList(expectedLines));
  }

  @Test
  public void captureChineseOutputWhenNotStreaming() throws Exception {
    String[] cmd = TestProgram.cmdFor(new String[]{"chinese"});
    CommandExecutor exec = new CommandExecutor(Arrays.asList(cmd));
    assertThat(exec.run(), equalTo("这是中文"));
  }

}
