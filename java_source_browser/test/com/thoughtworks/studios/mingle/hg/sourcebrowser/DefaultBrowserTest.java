//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import com.thoughtworks.studios.mingle.hg.TestRepository;
import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.assertThat;
import org.junit.Test;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class DefaultBrowserTest {

  private DefaultBrowser browser;
  private String browserCachePath;

  private void setupRepos(String bundleName)  {
    TestRepository testRepos = new TestRepository(bundleName);
    browser = testRepos.getBrowser();
    browserCachePath = testRepos.getBrowserCachePath();
  }

  @Test
  public void fileCacheIsBuiltCorrectlyForFirstChangeset() {
    setupRepos("one_changeset");
    browser.ensureFileCacheSynchedFor(0, null);

    Map<String, String> expectedContent = new HashMap<String, String>();
    expectedContent.put("/", "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4");
    expectedContent.put("README", "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4");

    assertThat(browser.rawFileCacheContent(0), equalTo(expectedContent));
  }

  @Test
  public void fileCacheIsBuiltCorrectlyForAddChangeset() {
    setupRepos("one_add");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    Map<String, String> expectedContent = new HashMap<String, String>();
    expectedContent.put("/", "6b3f0eefe63182cd2dea92d4a219199ef6429125");
    expectedContent.put("README", "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4");
    expectedContent.put("INSTALL", "6b3f0eefe63182cd2dea92d4a219199ef6429125");

    assertThat(browser.rawFileCacheContent(1), equalTo(expectedContent));
  }

  @Test
  public void fileCacheIsBuiltCorrectlyForRemoveChangeset() {
    setupRepos("one_remove");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    Map<String, String> expectedContent = new HashMap<String, String>();
    expectedContent.put("/", "93694ea4a21c1933bb8f5f4d46a8bb352ee0ed0a");
    expectedContent.put("README", "72e690d34170cef2eb7c1c3d71d8df8b3ec9e17d");

    assertThat(browser.rawFileCacheContent(1), equalTo(expectedContent));
  }

  @Test
  public void fileCacheIsBuiltCorrectlyForRenameChangeset() {
    setupRepos("renames");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    Map<String, String> expectedContent = new HashMap<String, String>();
    expectedContent.put("/", "4bdbb6906cef5481b93e192395c933af43b4935b");
    expectedContent.put("WorstestEver.png", "4bdbb6906cef5481b93e192395c933af43b4935b");
    expectedContent.put("some_stuff.txt", "4bdbb6906cef5481b93e192395c933af43b4935b");

    assertThat(browser.rawFileCacheContent(1), equalTo(expectedContent));
  }

  @Test
  public void nodeReturnsFileNodeForFilePath() {
    setupRepos("one_changeset");
    browser.ensureFileCacheSynchedFor(0, null);

    assertThat(browser.node("README", 0, "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4").isDir(), equalTo(false));
  }

  @Test
  public void nodeReturnsDirNodeForDirPath() {
    setupRepos("one_changeset_with_subdirs");
    browser.ensureFileCacheSynchedFor(0, null);

    assertThat(browser.node("src", 0, "32ecc7b520f6110ce0ebef34ae4c650a3126ec91").isDir(), equalTo(true));
  }

  @Test
  public void nodeReturnsDirNodeForRoot() {
    setupRepos("one_changeset");
    browser.ensureFileCacheSynchedFor(0, null);

    assertThat(browser.node("", 0, "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4").isDir(), equalTo(true));
  }

  @Test
  public void canGetChildrenOfRootNode() {
    setupRepos("one_changeset_with_many_files");
    browser.ensureFileCacheSynchedFor(0, null);

    DirNode root = (DirNode) browser.node("", 0, "25c12050e5597a54698b1b0c1c8f8c89b9147548");
    Node[] children = root.getChildren();
    String[] childNames = new String[children.length];
    for (int i = 0; i < children.length; i++) {
      childNames[i] = children[i].path();
    }
    assertThat(childNames, equalTo(new String[]{"README", "src", "tests"}));
  }

  @Test
  public void canGetChildrenOfRootNodeWhenRootContainsDotFiles() {
    setupRepos("dot_files");
    browser.ensureFileCacheSynchedFor(0, null);

    DirNode root = (DirNode) browser.node("", 0, "201ad72d825eb5e601f1b817172a863a2b4ca72d");
    Node[] children = root.getChildren();
    String[] childNames = new String[children.length];
    for (int i = 0; i < children.length; i++) {
      childNames[i] = children[i].path();
    }
    assertThat(childNames, equalTo(new String[]{".bar", ".foo", "foobar"}));
  }

  @Test
  public void canGetChildrenOfNonRootNode() {
    setupRepos("one_changeset_with_many_files");
    browser.ensureFileCacheSynchedFor(0, null);

    DirNode root = (DirNode) browser.node("src", 0, "25c12050e5597a54698b1b0c1c8f8c89b9147548");
    Node[] children = root.getChildren();
    String[] childNames = new String[children.length];
    for (int i = 0; i < children.length; i++) {
      childNames[i] = children[i].path();
    }
    assertThat(childNames, equalTo(new String[]{"src/foo.rb", "src/foo"}));
  }

  @Test
  public void canGetChildrenOfNonRootNodeWhenNodeContainsDotFiles() {
    setupRepos("dot_files");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    DirNode root = (DirNode) browser.node("foobar", 1, "6681910051b605852dc4c33a88f924e5997dc58d");
    Node[] children = root.getChildren();
    String[] childNames = new String[children.length];
    for (int i = 0; i < children.length; i++) {
      childNames[i] = children[i].path();
    }
    assertThat(childNames, equalTo(new String[]{"foobar/.stuff", "foobar/non_dot.txt"}));
  }

  @Test
  public void canGetChildrenOfNonRootNodeWhenNodeIsADotFile() {
    setupRepos("dot_files");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    DirNode root = (DirNode) browser.node(".bar", 1, "6681910051b605852dc4c33a88f924e5997dc58d");
    Node[] children = root.getChildren();
    String[] childNames = new String[children.length];
    for (int i = 0; i < children.length; i++) {
      childNames[i] = children[i].path();
    }
    assertThat(childNames, equalTo(new String[]{".bar/.stuff.txt", ".bar/stuff.txt"}));
  }

  @Test
  public void childrenAreCorrectNodeTypes() {
    setupRepos("one_changeset_with_many_files");
    browser.ensureFileCacheSynchedFor(0, null);

    Node[] children = ((DirNode) browser.node("src", 0, "25c12050e5597a54698b1b0c1c8f8c89b9147548")).getChildren();
    assertThat(children[0].isDir(), equalTo(false));
    assertThat(children[0].name(), equalTo("foo.rb"));
    assertThat(children[1].isDir(), equalTo(true));
    assertThat(children[1].name(), equalTo("foo"));
  }

//  def test_most_recent_commit_information_is_included_in_child_nodes
//    setup_repos('two_changesets_with_many_files')
//    synch_source_browser_up_to(1)
//
//    dir = @source_browser.node('', "1", "bdc6584d0f24562c2bae56ce5abb208126d2a60b")
//    children = dir.children
//    @mingle_revision_repository.assert_correct_identifiers_were_passed([
//      "25c12050e5597a54698b1b0c1c8f8c89b9147548",
//      "bdc6584d0f24562c2bae56ce5abb208126d2a60b",
//      "25c12050e5597a54698b1b0c1c8f8c89b9147548"
//    ])
//    foo_rb_file = children.find{|c| c.path == 'src'}
//    assert_equal ['wpc', Time.mktime(2009, 2, 2, 8, 3, 45), 'fake revision from wpc'],
//      [foo_rb_file.most_recent_committer, foo_rb_file.most_recent_commit_time, foo_rb_file.most_recent_commit_desc]
//    readme_file = children.find{|c| c.path == 'README'}
//    assert_equal ['jen', Time.mktime(2009, 2, 3, 8, 3, 45), 'fake revision from jen'],
//      [readme_file.most_recent_committer, readme_file.most_recent_commit_time, readme_file.most_recent_commit_desc]
//  end

//  # this is relevant while large chunks of changesets are being cached, particularly during initialization
//  def test_child_nodes_are_still_created_if_mingle_revisions_cannot_be_found_to_populate_most_recent_commit_info
//    setup_repos('one_changeset_with_subdirs')
//    synch_source_browser_up_to(0)
//
//    dir = @source_browser.node('', "0", "32ecc7b520f6110ce0ebef34ae4c650a3126ec91")
//    children = dir.children
//    children.each do |child|
//      assert_nil child.most_recent_committer
//      assert_nil child.most_recent_commit_time
//      assert_nil child.most_recent_commit_desc
//    end
//  end

  @Test
  public void tipNodeReturnsProposedTipIfItIsCached() {
    setupRepos("hello");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    Node tipNode = browser.tipNode("", 1, "82e55d328c8ca4ee16520036c0aaace03a5beb65");
    assertThat(tipNode.changesetNumber(), equalTo(1));
  }

  @Test
  public void tipNodeReturnsOnlyYoungestFromFileCache() {
    setupRepos("hello");
    browser.ensureFileCacheSynchedFor(0, null);
    browser.ensureFileCacheSynchedFor(1, null);

    Node tipNode = browser.tipNode("", 2, "fef857204a0c58caefe249dda038316e856e896d");
    assertThat(tipNode.changesetNumber(), equalTo(1));
  }

  @Test
  public void tipNodeReturnsRevZeroWhenNothingCached() {
    setupRepos("hello");

    Node tipNode = browser.tipNode("", 2, "fef857204a0c58caefe249dda038316e856e896d");
    assertThat(tipNode.changesetNumber(), equalTo(0));
  }

  @Test
  public void cleanUpObsoleteCacheFiles() throws Exception {
    setupRepos("hello");
    browser.ensureFileCacheSynchedFor(0, null);

    File foriegnSubDir =  new File(browserCachePath + File.separator + "0" + File.separator + "foo.bar");
    File foreignFile = new File(browserCachePath + File.separator + "foo.bar");

    foriegnSubDir.mkdirs();
    foreignFile.createNewFile();

    browser.cleanUpObsoleteCacheFiles();

    assertThat(foreignFile.exists(), equalTo(false));
    assertThat(new File(browserCachePath + File.separator + "0").exists(), equalTo(false));
    assertThat(new File(browserCachePath + File.separator + "2").exists(), equalTo(true));  // the actual cache path
  }
}
