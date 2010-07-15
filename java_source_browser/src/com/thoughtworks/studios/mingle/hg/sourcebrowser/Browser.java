//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.sourcebrowser;

import java.util.Map;
import java.io.OutputStream;

public interface Browser {

  Node[] childNodesFor(DirNode dirNode, Map<String, String> rawChangesetContent);

  boolean isBinary(String path, String rev);

  void ensureFileCacheSynchedFor(Integer changesetNumber, String changesetIdentifier);

  Map<String, String> rawFileCacheContent(Integer revisionNumber);

  Node node(String path, Integer changesetNumber, String changesetIdentifier);

  Node tipNode(String path, Integer likelyTipNumber, String likelyTipIdentifier);

  void fileContentsFor(FileNode fileNode, OutputStream out);
}
