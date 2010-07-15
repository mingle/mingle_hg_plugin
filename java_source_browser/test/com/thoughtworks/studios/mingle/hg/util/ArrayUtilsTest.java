//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.util;

import org.junit.Test;
import static org.junit.Assert.assertThat;
import static org.hamcrest.CoreMatchers.equalTo;

public class ArrayUtilsTest {

  @Test
  public void cutFirstOneWithEmptyArray() {
    assertThat(ArrayUtils.cutFirstOne(new String[0]), equalTo(new String[0]));  
  }

  @Test
  public void cutFirstOneWithSingleMember() {
    assertThat(ArrayUtils.cutFirstOne(new String[]{"abc"}), equalTo(new String[0]));
  }

  @Test
  public void cutFirstOneWithTwoMembers() {
    assertThat(ArrayUtils.cutFirstOne(new String[]{"abc", "def"}), equalTo(new String[]{"def"}));      
  }

  @Test
  public void cutLaseOneWithEmptyArray() {
    assertThat(ArrayUtils.cutLastOne(new String[0]), equalTo(new String[0]));      
  }

  @Test
  public void cutLastOneWithSingleMember() {
    assertThat(ArrayUtils.cutLastOne(new String[]{"abc"}), equalTo(new String[0]));   
  }

  @Test
  public void cutLastOneWithTwoMembers() {
    assertThat(ArrayUtils.cutLastOne(new String[]{"abc", "def"}), equalTo(new String[]{"abc"}));         
  }

  @Test
  public void joinEmptyArray() {
    assertThat(ArrayUtils.join(new String[0], "abc"), equalTo(""));      
  }

  @Test
  public void joinSingleMemberArray() {
    assertThat(ArrayUtils.join(new String[]{"foo"}, "abc"), equalTo("foo"));          
  }

  @Test
  public void joinTwoMemberArray() {
    assertThat(ArrayUtils.join(new String[]{"foo", "bar"}, "abc"), equalTo("fooabcbar"));              
  }
}
