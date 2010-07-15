//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg;

import java.io.File;
import java.io.IOException;
import java.util.Random;
import java.util.Arrays;

import com.thoughtworks.studios.mingle.hg.hgcmdline.HgClient;
import com.thoughtworks.studios.mingle.hg.sourcebrowser.DefaultBrowser;
import com.thoughtworks.studios.mingle.hg.cmdline.CommandExecutor;
import com.thoughtworks.studios.mingle.hg.util.FileUtils;

public class TestRepository {
  
  private String bundleName;
  private String browserCachePath;
  private String reposDirName;
  private HgClient hgClient;
  private DefaultBrowser browser;

  public TestRepository() {
    this(null);
  }

  public TestRepository(String bundleName) {
    this.bundleName = bundleName;
    setupRepos();
  }

  public void setupRepos()  {
    try {
      reposDirName = bundleName == null ? oneTimeReposDir(bundleName) : cachedReposDir(bundleName);
      File hgFile = new File(reposDirName + ".hg");
      if (!hgFile.exists()) {
        File reposDir = new File(reposDirName);
        if (reposDir.exists()) {
          FileUtils.rmRf(reposDir);
        }
        FileUtils.mkdirP(reposDir);
        String[] initCmd = {"hg", "init", "--cwd", reposDirName};
        new CommandExecutor(Arrays.asList(initCmd)).run();

        if (bundleName != null) {
          FileUtils.copyFileToDir(new File("rails_plugin/tests/bundles/" + bundleName + ".hg"), reposDir);
          String[] unbundleCmd = {"hg", "unbundle", "--cwd", reposDirName, bundleName + ".hg"};
          new CommandExecutor(Arrays.asList(unbundleCmd)).run();
        }
      }
      hgClient = new HgClient(null, reposDirName, new File("rails_plugin/app/templates").getCanonicalPath());
      browserCachePath = "tmp/test_source_browsers/" + randomString();
      browser = new DefaultBrowser(hgClient, browserCachePath);
    } catch (IOException ioEx) {
      throw new RuntimeException("Unable to create hgClient!", ioEx);
    }
  }

  public String getBrowserCachePath() {
    return browserCachePath;
  }

  public HgClient getHgClient() {
    return hgClient;
  }

  public DefaultBrowser getBrowser() {
    return browser;
  }

  public String getReposDirName() {
    return reposDirName;
  }

  public static String cachedReposDir(String bundleName) {
    return new File("tmp/test_repositories/from_bundles/" + (bundleName == null ? "empty" : bundleName) + "/").getAbsolutePath();
  }

  public static String oneTimeReposDir(String bundleName) {
    return new File("tmp/test_repositories/one_timers/" + (bundleName == null ? "empty" : bundleName) + "/" + randomString() + "/").getAbsolutePath();
  }

  private static String randomString() {
    Random random = new Random();
    long r1 = random.nextLong();
    long r2 = random.nextLong();
    String hash1 = Long.toHexString(r1);
    String hash2 = Long.toHexString(r2);
    String hash = hash1 + hash2;
    return hash;
  }
}
