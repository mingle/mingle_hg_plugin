//Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

package com.thoughtworks.studios.mingle.hg.hgcmdline;

import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

public class HgLogEntry {

  private Integer revNumber;
  private String identifier;
  private Calendar time;
  private String committer;
  private String description;

  public HgLogEntry(Integer revNumber, String identifier, Long time, String committer, String description) {
    this.revNumber = revNumber;
    this.identifier = identifier;
    if (time != null) {
      this.time = Calendar.getInstance();
      this.time.setTimeZone(TimeZone.getTimeZone("UTC"));
      this.time.setTime(new Date(time));
    }
    this.committer = committer;
    this.description = description;
  }

  public Integer getRevNumber() {
    return revNumber;
  }

  public String getIdentifier() {
    return identifier;
  }

  public Calendar getTime() {
    return time;
  }

  public long getEpochTime() {
    return getTime().getTime().getTime();
  }

  public String getCommitter() {
    return committer;
  }

  public String getDescription() {
    return description;
  }  
}
