//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.hgcmdline;

import com.thoughtworks.studios.mingle.hg.TestRepository;
import com.thoughtworks.studios.mingle.hg.cmdline.LineHandler;
import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;
import org.junit.Test;

import java.util.*;
import java.io.ByteArrayOutputStream;

public class HgClientTest {

  HgClient hgClient;

  private void setupHgClient(String bundle) {
    TestRepository testRepos = new TestRepository(bundle);
    hgClient = testRepos.getHgClient();
  }

  @Test
  public void logForRev() {
    setupHgClient("hello");
    HgLogEntry logEntry = hgClient.logForRev("1");
    assertThat(logEntry.getRevNumber(), equalTo(1));
    assertThat(logEntry.getIdentifier(), equalTo("82e55d328c8ca4ee16520036c0aaace03a5beb65"));
    Calendar expectedTime = Calendar.getInstance();
    expectedTime.setTimeZone(TimeZone.getTimeZone("UTC"));
    expectedTime.setTime(new Date(1125044488));
    assertThat(logEntry.getTime(), equalTo(expectedTime));
    assertThat(logEntry.getCommitter(), equalTo("mpm"));
    assertThat(logEntry.getDescription(), equalTo("Create a makefile"));
  }

  @Test
  public void logForRevThrowsExceptionForBogusChangeset() {
    setupHgClient("hello");
    try {
      hgClient.logForRev("asdfkljs");
      fail("Should not have found revision!");
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("unknown revision 'asdfkljs'"), equalTo(true));
    }
  }

  @Test
  public void logForRevThrowsExceptionForBogusChangesetAgainstEmptyRepos() {
    setupHgClient(null);
    try {
      hgClient.logForRev("asdfkljs");
      fail("Should not have found revision!");
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("Repository is empty!"), equalTo(true));
    }
  }

  @Test
  public void logForRevs() {
    setupHgClient("hello");
    List<HgLogEntry> log = hgClient.logForRevs("0", "1");

    HgLogEntry logEntry1 = log.get(0);
    assertThat(logEntry1.getRevNumber(), equalTo(0));
    assertThat(logEntry1.getIdentifier(), equalTo("0a04b987be5ae354b710cefeba0e2d9de7ad41a9"));
    Calendar expectedTime = Calendar.getInstance();
    expectedTime.setTimeZone(TimeZone.getTimeZone("UTC"));
    expectedTime.setTime(new Date(1125044450));
    assertThat(logEntry1.getTime(), equalTo(expectedTime));
    assertThat(logEntry1.getCommitter(), equalTo("mpm"));
    assertThat(logEntry1.getDescription(), equalTo("Create a standard \"hello, world\" program"));

    HgLogEntry logEntry2 = log.get(1);
    assertThat(logEntry2.getRevNumber(), equalTo(1));
    assertThat(logEntry2.getIdentifier(), equalTo("82e55d328c8ca4ee16520036c0aaace03a5beb65"));
    expectedTime = Calendar.getInstance();
    expectedTime.setTimeZone(TimeZone.getTimeZone("UTC"));
    expectedTime.setTime(new Date(1125044488));
    assertThat(logEntry2.getTime(), equalTo(expectedTime));
    assertThat(logEntry2.getCommitter(), equalTo("mpm"));
    assertThat(logEntry2.getDescription(), equalTo("Create a makefile"));
  }

  @Test
  public void logForRevsThrowsExceptionForBogusChangeset() {
    setupHgClient("hello");
    try {
      hgClient.logForRevs("asdfkljs", "asdfkljs");
      fail("Should not have found revision!");
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("unknown revision 'asdfkljs'"), equalTo(true));
    }
  }

  @Test
  public void logForRevsThrowsExceptionForBogusChangesetAgainstEmptyRepos() {
    setupHgClient(null);
    try {
      hgClient.logForRevs("asdfkljs", "asdfkljs");
      fail("Should not have found revision!");
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("Repository is empty!"), equalTo(true));
    }
  }

  @Test
  public void isBinaryForNonBinary() {
    setupHgClient("hello");
    assertThat(hgClient.isBinary("hello.c", "0"), equalTo(false));
  }

  @Test
  public void isBinaryForBinary() {
    setupHgClient("source");
    assertThat(hgClient.isBinary("lib/Picture 1.png", "4"), equalTo(true));
  }

  @Test
  public void isBinaryThrowsExceptionForBogusParams() {
    setupHgClient("source");
    try {
      hgClient.isBinary("bogus/path", "0");
      fail("should have failed!");     
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("No such file"), equalTo(true));
    }
  }

  @Test
  public void cat() {
    setupHgClient("hello");
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    hgClient.cat("hello.c", "1", out);
    String expectedFileContents = "/*\n" + 
      " * hello.c\n" + 
      " *\n" + 
      " * Placed in the public domain by Bryan O'Sullivan\n" + 
      " *\n" + 
      " * This program is not covered by patents in the United States or other\n" + 
      " * countries.\n" + 
      " */\n" + 
      "\n" + 
      "#include <stdio.h>\n" + 
      "\n" + 
      "int main(int argc, char **argv)\n" + 
      "{\n" + 
      "\tprintf(\"hello, world!\\n\");\n" + 
      "\treturn 0;\n" + 
      "}\n";
    assertThat(expectedFileContents, equalTo(out.toString()));
  }

  @Test
  public void catThrowsExceptionForBogusParams() {
    setupHgClient("hello");
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    try {
      hgClient.cat("hello.cpp", "1", out);
      fail("should have failed!");      
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("No such file"), equalTo(true));
    }
  }

  @Test
  public void filesInChangeset() {
    setupHgClient("two_changesets_with_many_files");
    List<String> files = hgClient.filesInChangeset("0");
    String[] expectedFiles = {
      "README",
      "src/foo.rb",
      "src/foo/extra_stuff.rb",
      "tests/foo_test.rb",
      "tests/test_helper.rb"
    };
    assertThat(files, equalTo(Arrays.asList(expectedFiles)));
  }

  @Test
  public void filesInChangesetThrowsExceptionForBogusParams() {
    setupHgClient("hello");
    try {
      hgClient.filesInChangeset("slkdjfsldfkj");
      fail("should have failed!");
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("unknown revision"), equalTo(true));
    }
  }

  @Test
  public void deletedFilesInChangeset() {
    setupHgClient("one_remove");
    List<String> deletedFiles = hgClient.deletedFilesInChangeset("1");
    String[] exepctedFiles = {"INSTALL"};
    assertThat(deletedFiles, equalTo(Arrays.asList(exepctedFiles)));
  }

  @Test
  public void deletedFilesInChangesetThrowsExceptionForBogusParams() {
    setupHgClient("hello");
    try {
      hgClient.deletedFilesInChangeset("slkdjfsldfkj");
      fail("should have failed!");      
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("unknown revision"), equalTo(true));
    }
  }

  @Test
  public void gitPatchFor() {
    setupHgClient("source");
    final List<String> actualLines = new LinkedList<String>();
    hgClient.gitPatchFor("1", new LineHandler() {
      public void handleLine(String line) {
        actualLines.add(line);
      }
    });

    List<String> expectedLines = new LinkedList<String>();
    expectedLines.add("diff --git a/src/hello.rb b/src/hello.rb");
    expectedLines.add("new file mode 100644");
    expectedLines.add("--- /dev/null");
    expectedLines.add("+++ b/src/hello.rb");
    expectedLines.add("@@ -0,0 +1,9 @@");
    expectedLines.add("+class Hello");
    expectedLines.add("+  ");
    expectedLines.add("+  public go");
    expectedLines.add("+    puts \"Hello!\"");
    expectedLines.add("+  end");
    expectedLines.add("+  ");
    expectedLines.add("+end");
    expectedLines.add("+");
    expectedLines.add("+Hello.new.go");
    expectedLines.add("\\ No newline at end of file");
    expectedLines.add("diff --git a/test/test_hello.rb b/test/test_hello.rb");
    expectedLines.add("new file mode 100644");
    expectedLines.add("--- /dev/null");
    expectedLines.add("+++ b/test/test_hello.rb");
    expectedLines.add("@@ -0,0 +1,3 @@");
    expectedLines.add("+class TestHello");
    expectedLines.add("+  ");
    expectedLines.add("+end");
    expectedLines.add("\\ No newline at end of file");
    expectedLines.add("");

    assertThat(actualLines, equalTo(expectedLines));
  }

  @Test
  public void gitPatchForThrowsExceptionForBogusParams() {
    setupHgClient("hello");
    try {
      hgClient.gitPatchFor("slkdjfsldfkj", null);
      fail("should have failed!");
    } catch (HgClientException ex) {
      assertThat(ex.getMessage().contains("unknown revision"), equalTo(true));
    }
  }

  @Test
  public void pull() throws Exception {
    TestRepository oneAdd = new TestRepository("one_add");
    TestRepository empty = new TestRepository(null);

    hgClient = new HgClient(oneAdd.getReposDirName(), empty.getReposDirName(), null);
    hgClient.pull();
    assertThat(hgClient.logForRev("tip").getRevNumber(), equalTo(1));
  }

  @Test
  public void pullThrowsExceptionWithBogusParams() {
    hgClient = new HgClient("/fjalsdkfj/foo/bar", "/lasfjdlsakjf/bar/foo", null);
    try {
      hgClient.pull();
      fail("should have failed!");
    } catch (HgClientException ex) {
      // still trying to figure out best means of cross-platform assertion
      // that this is the correct exception
    }
  }

  @Test
  public void tryToConnectDoesNotThrowException() throws Exception {
    TestRepository oneAdd = new TestRepository("one_add");
    String pullToReposDir = TestRepository.oneTimeReposDir(null);
    hgClient = new HgClient(oneAdd.getReposDirName(), pullToReposDir, null);
    hgClient.tryToConnect();
  }
  

  @Test
  public void ensureLocalClone() throws Exception {
    TestRepository oneAdd = new TestRepository("one_add");
    String pullToReposDir = TestRepository.oneTimeReposDir(null);
    hgClient = new HgClient(oneAdd.getReposDirName(), pullToReposDir, null);
    hgClient.ensureLocalClone();
    assertThat(hgClient.logForRev("tip").getRevNumber(), equalTo(1));
  }

  @Test
  public void ensureLocalCloneThrowsExceptionWithBogusParams() {
    hgClient = new HgClient("/fjalsdkfj/foo/bar", "/lasfjdlsakjf/bar/foo", null);
    try {
      hgClient.ensureLocalClone();
      fail("should have failed!");
    } catch (HgClientException ex) {
      // still trying to figure out best means of cross-platform assertion
      // that this is the correct exception
    }
  }

  @Test
  public void repositoryIsEmptyReturnsTrueWhenRepositoryIsEmpty() {
    setupHgClient(null);
    assertThat(hgClient.isRepositoryEmpty(), equalTo(true));
  }

  @Test
  public void repositoryIsEmptyReturnsFalseWhenRepositoryIsNotEmpty() {
    setupHgClient("one_add");
    assertThat(hgClient.isRepositoryEmpty(), equalTo(false));
  }
}
