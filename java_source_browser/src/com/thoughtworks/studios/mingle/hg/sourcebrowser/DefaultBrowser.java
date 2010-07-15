//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import com.thoughtworks.studios.mingle.hg.hgcmdline.HgClient;
import com.thoughtworks.studios.mingle.hg.hgcmdline.HgLogEntry;

import java.util.*;
import java.io.OutputStream;

public class DefaultBrowser implements Browser {

  private HgClient hgClient;
  private ContentBuilder contentBuilder;
  private ContentCache contentCache;

  public DefaultBrowser(HgClient hgClient, String cachePath) {
    this.hgClient = hgClient;
    this.contentBuilder = new ContentBuilder(hgClient);
    this.contentCache = new ContentCache(cachePath);
  }

  public void fileContentsFor(FileNode fileNode, OutputStream out) {
    hgClient.cat(fileNode.path(), fileNode.changesetIdentifier(), out);
  }

  public boolean isBinary(String path, String rev) {
    return hgClient.isBinary(path, rev);    
  }

  public Node tipNode(String path, Integer likelyTipNumber, String likelyTipIdentifier) {
    for (int i = likelyTipNumber; i >= 1; i--) {
      if (contentCache.isCached(i)) {
        if (likelyTipNumber.equals(i)) {
          return node(path, likelyTipNumber, likelyTipIdentifier);
        } else {
          HgLogEntry logEntry = hgClient.logForRev(String.valueOf(i));
          return node(path, logEntry.getRevNumber(), logEntry.getIdentifier());
        }
      }
    }

    HgLogEntry entry0 = hgClient.logForRev("0");
    ensureFileCacheSynchedFor(0, entry0.getIdentifier());
    return node(path, 0, entry0.getIdentifier());
  }

  public Node node(String path, Integer changesetNumber, String changesetIdentifier) {
    Map<String, String> rawContent = contentCache.readFor(changesetNumber);
    if (!path.equals("") && rawContent.containsKey(path)) {
      return new FileNode(this, path, changesetNumber, changesetIdentifier, rawContent.get(path));
    } else {
      DirNode dirNode = new DirNode(this, path, changesetNumber, changesetIdentifier, rawContent.get(path) + "/");
      dirNode.setChildren(childNodesFor(dirNode, rawContent));
      return dirNode;
    }
  }

  public Node[] childNodesFor(DirNode dirNode, Map<String, String> rawChangesetContent) {
    if (rawChangesetContent == null) {
      rawChangesetContent = contentCache.readFor(dirNode.changesetNumber());
    }

    List<Node> children = new ArrayList<Node>();

    String dirPath = dirNode.isRootNode() ? "" : dirNode.path() + "/";

    List<String> paths = new ArrayList<String>(rawChangesetContent.keySet());
    Collections.sort(paths);

    String lastAddedChildPath = "";
    for (String path : paths) {
      if (path.indexOf(lastAddedChildPath + "/") != 0) {


        if (path.indexOf(dirPath) == 0 && path.length() > dirPath.length() && !path.equals("/")) {
          if (path.endsWith("/")) {
            lastAddedChildPath = path.substring(0, path.length() - 1);
            children.add(new DirNode(
              this, path.substring(0, path.length() - 1), dirNode.changesetNumber(),
              dirNode.changesetIdentifier(), rawChangesetContent.get(path)
            ));
          } else {
            lastAddedChildPath = path;
            children.add(new FileNode(
              this, path, dirNode.changesetNumber(),
              dirNode.changesetIdentifier(), rawChangesetContent.get(path)
            ));
          }
        }
      }
    }

    return children.toArray(new Node[0]);
  }

  public void ensureFileCacheSynchedFor(Integer changesetNumber, String changesetIdentifier) {
    if (contentCache.isCached(changesetNumber)) {
      return;
    }

    Map<String, String> baseContent;
    if (changesetNumber.equals(0)) {
      baseContent = new HashMap<String, String>();
    } else {
      baseContent = contentCache.readFor(changesetNumber - 1);
    }

    if (changesetIdentifier == null) {
      changesetIdentifier = hgClient.logForRev(String.valueOf(changesetNumber)).getIdentifier();
    }

    contentBuilder.buildContent(changesetIdentifier, baseContent);
    contentCache.writeFor(changesetNumber, baseContent);
  }

  public boolean isCached(Integer revisionNumber) {
    return contentCache.isCached(revisionNumber);
  }

  public void cleanUpObsoleteCacheFiles() {
    contentCache.cleanUpObsoleteCacheFiles();
  }

  public Map<String, String> rawFileCacheContent(Integer revisionNumber) {
    return contentCache.readFor(revisionNumber);
  }
}


