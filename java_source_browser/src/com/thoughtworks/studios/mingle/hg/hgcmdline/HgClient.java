//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.hgcmdline;

import com.thoughtworks.studios.mingle.hg.util.ArrayUtils;
import com.thoughtworks.studios.mingle.hg.util.FileUtils;
import com.thoughtworks.studios.mingle.hg.cmdline.CommandExecutor;
import com.thoughtworks.studios.mingle.hg.cmdline.LineHandler;
import com.thoughtworks.studios.mingle.hg.cmdline.CommandExecutorException;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.apache.log4j.Logger;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.File;
import java.io.StringReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Arrays;

public class HgClient {

  private static final Logger LOGGER = Logger.getLogger(HgClient.class);

  private static final Long ONE_MINUTE_IN_MSECS = 60L * 1000;
  private static final Long ONE_HOUR_IN_MSECS = ONE_MINUTE_IN_MSECS * 60;
  private static final Long FOUR_HOURS_IN_MSECS = ONE_HOUR_IN_MSECS * 4;
  private static Long LOCAL_OPERATION_TIMEOUT = ONE_HOUR_IN_MSECS;
  private static Long PULL_TIMEOUT = FOUR_HOURS_IN_MSECS;

  static {
    try {
      String localOperationTimeoutOverride = System.getProperty("mingle.hg.plugin.timeout.local");
      if (localOperationTimeoutOverride != null) {
        LOCAL_OPERATION_TIMEOUT = Long.valueOf(localOperationTimeoutOverride);
      }
      String pullTimeoutOverride = System.getProperty("mingle.hg.plugin.timeout.pull");
      if (pullTimeoutOverride != null) {
        PULL_TIMEOUT = Long.valueOf(pullTimeoutOverride);
      }
    } catch (Exception e) {
      LOGGER.warn("Unable to override timeout settings; will use defaults", e);  
    }
  }

  private String masterPath;
  private String clonePath;
  private String styleDir;

  private static final String LOG_ENTRY_TEMPLATE = "" +
    "<entry>" +
    "<rev>{rev}</rev>" +
    "<node>{node}</node>" +
    "<time>{date|hgdate}</time>" +
    "<committer>{author|person|escape}</committer>" +
    "<desc>{desc|escape}</desc>" +
    "</entry>";


  public HgClient(String masterPath, String clonePath, String styleDir) {
    this.masterPath = masterPath;
    this.clonePath = clonePath;
    this.styleDir = styleDir;

  }

  public HgLogEntry logForRev(String rev) {
    return logForRevs(rev, rev).get(0);
  }

  public List<HgLogEntry> logForRevs(String from, String to) {
    XPath xPath = XPathFactory.newInstance().newXPath();
    List<HgLogEntry> logEntries = new ArrayList<HgLogEntry>();
    try {
      String logXml = hg(new String[]{
        "log", "-r", from + ":" + to, "--template", LOG_ENTRY_TEMPLATE
      }, LOCAL_OPERATION_TIMEOUT);
      if (logXml.equals("")) {
        throw new HgClientException("Repository is empty!");
      }
      logXml = "<entries>" + logXml + "</entries>";
      NodeList nodes = (NodeList) xPath.evaluate(
        "//entries/entry",
        new InputSource(new StringReader(logXml)),
        XPathConstants.NODESET);
      for (int i = 0; i < nodes.getLength(); i++) {
        String rev = xPath.evaluate("rev", nodes.item(i));
        String identifier = xPath.evaluate("node", nodes.item(i));
        String time = xPath.evaluate("time", nodes.item(i)).split(" ")[0];
        String committer = xPath.evaluate("committer", nodes.item(i));
        String desc = xPath.evaluate("desc", nodes.item(i));
        HgLogEntry logEntry = new HgLogEntry(Integer.valueOf(rev),
          identifier, Long.valueOf(time), committer, desc);
        logEntries.add(logEntry);
      }
    } catch (XPathExpressionException e) {
      throw new HgClientException(e);
    }

    return logEntries;
  }

  public boolean isBinary(String path, String rev) {
    String annotation = hg(new String[]{
      "annotate", "-r", rev, path
    }, LOCAL_OPERATION_TIMEOUT);
    String osSpecificPath = ArrayUtils.join(path.split("/"), File.separator);
    String expectedBinaryAnnotation = osSpecificPath + ": binary file";
    return annotation.trim().equals(expectedBinaryAnnotation);
  }

  public void cat(String path, String rev, OutputStream out) {
    hg(new String[]{
      "cat", "-r", rev, path
    }, out, LOCAL_OPERATION_TIMEOUT);
  }

  public List<String> filesInChangeset(String rev) {
    return filesXmlToList(hg(new String[]{
      "log", "-r", rev, "--style", styleDir + File.separator + "changeset_files.style"
    }, LOCAL_OPERATION_TIMEOUT));
  }

  public List<String> deletedFilesInChangeset(String rev) {
    return filesXmlToList(hg(new String[]{
      "log", "-r", rev, "--style", styleDir + File.separator + "changeset_dels.style"
    }, LOCAL_OPERATION_TIMEOUT));
  }

  public void gitPatchFor(String rev, LineHandler lineHandler) {
    hg(new String[] {
      "log", "--config", "diff.git=true", "-p", "-r", rev, "--template", "{patch}"
    }, lineHandler, LOCAL_OPERATION_TIMEOUT);
  }

  public void pull() {
    hg(new String[]{
      "pull", masterPath
    }, PULL_TIMEOUT);
  }

  public void ensureLocalClone() {
    if (!new File(clonePath + File.separator + ".hg").exists()) {
      FileUtils.mkdirP(new File(clonePath).getParentFile());
      String[] cmdarray = new String[]{"hg", "clone", "--noupdate", masterPath, clonePath};
      CommandExecutor cmdExec = new CommandExecutor(Arrays.asList(cmdarray));
      try {
        cmdExec.run();
      } catch (CommandExecutorException ex) {
        throw new HgClientException(ex);
      }
      if (!cmdExec.standardErrorText().trim().equals("")) {
        throw new HgClientException(cmdExec.standardErrorText());
      }
    }
  }

  public boolean isRepositoryEmpty() {
    return !(new File(clonePath + File.separator + ".hg" + File.separator + "store" + File.separator + "data").exists());
  }

  private List<String> filesXmlToList(String filesXml) {
    try {
      XPath xPath = XPathFactory.newInstance().newXPath();
      NodeList nodes = (NodeList) xPath.evaluate(
        "//files/file",
        new InputSource(new StringReader(filesXml)),
        XPathConstants.NODESET
      );
      List<String> files = new ArrayList<String>();
      for (int i = 0; i < nodes.getLength(); i++) {
        files.add(nodes.item(i).getTextContent());
      }
      return files;
    } catch (XPathExpressionException e) {
      throw new HgClientException(e);
    }
  }

  private void hg(String[] cmdarray, OutputStream out, Long timeout) {
    CommandExecutor cmdExec = new CommandExecutor(buildHgCommand(cmdarray), timeout);
    try {
      cmdExec.run(out);
    } catch (CommandExecutorException ex) {
      throw new HgClientException(ex);
    }
    if (!cmdExec.standardErrorText().trim().equals("")) {
      throw new HgClientException(cmdExec.standardErrorText());
    }    
  }

  private void hg(String[] cmdarray, LineHandler lineHandler, Long timeout) {
    CommandExecutor cmdExec = new CommandExecutor(buildHgCommand(cmdarray), timeout);
    try {
      cmdExec.run(lineHandler);
    } catch (CommandExecutorException ex) {
      throw new HgClientException(ex);
    }
    if (!cmdExec.standardErrorText().trim().equals("")) {
      throw new HgClientException(cmdExec.standardErrorText());
    }
  }

  private String hg(String[] cmdarray, Long timeout) {
    CommandExecutor cmdExec = new CommandExecutor(buildHgCommand(cmdarray), timeout);
    try {
      cmdExec.run();
    } catch (CommandExecutorException ex) {
      throw new HgClientException(ex);
    }
    if (!cmdExec.standardErrorText().trim().equals("")) {
      throw new HgClientException(cmdExec.standardErrorText());
    }
    return cmdExec.run();
  }

  private List<String> buildHgCommand(String[] cmdarray) {
    List<String> cmdParts = new LinkedList<String>();
    cmdParts.add("hg");
    cmdParts.add("--cwd");
    cmdParts.add(clonePath);
    for (String part : cmdarray) {
      cmdParts.add(part);
    }
    return cmdParts;
  }
}
