CREATE TABLE repositories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  repo_id INTEGER NOT NULL UNIQUE,
  repo_name TEXT NOT NULL,
  url TEXT NOT NULL,
  is_private INTEGER DEFAULT 0,
  is_archived INTEGER DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);

CREATE TABLE pull_requests (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pr_id INTEGER NOT NULL UNIQUE,
  repository_id INTEGER NOT NULL,
  number INTEGER NOT NULL,
  title TEXT,
  updated_at TEXT,
  closed_at TEXT,
  merged_at TEXT,
  author TEXT NOT NULL,
  additions INTEGER,
  deletions INTEGER,
  changed_files INTEGER,
  commits_count INTEGER,
  created_at TEXT,
  FOREIGN KEY (repository_id) REFERENCES repositories(id)
);

CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  review_id INTEGER NOT NULL UNIQUE,
  pull_request_id INTEGER NOT NULL,
  author TEXT NOT NULL,
  state TEXT NOT NULL,
  submitted_at TEXT,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY (pull_request_id) REFERENCES pull_requests(id)
);