CREATE TABLE repositories (
  id TEXT PRIMARY KEY NOT NULL,
  repo_id INTEGER NOT NULL UNIQUE,
  repo_name TEXT NOT NULL,
  url TEXT NOT NULL,
  is_private INTEGER DEFAULT 0,
  is_archived INTEGER DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);

CREATE INDEX index_repositories_on_repo_name ON repositories(repo_name);

CREATE TABLE pull_requests (
  id TEXT PRIMARY KEY NOT NULL,
  pr_id INTEGER NOT NULL UNIQUE,
  repository_id TEXT NOT NULL,
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
  created_at TEXT
);

CREATE INDEX index_pull_requests_on_repository_id ON pull_requests(repository_id);
CREATE INDEX index_pull_requests_on_number ON pull_requests(number);
CREATE INDEX index_pull_requests_on_author ON pull_requests(author);
CREATE UNIQUE INDEX index_pull_requests_on_repository_id_and_number ON pull_requests(repository_id, number);

CREATE TABLE reviews (
  id TEXT PRIMARY KEY NOT NULL,
  review_id INTEGER NOT NULL UNIQUE,
  pull_request_id TEXT NOT NULL,
  author TEXT NOT NULL,
  state TEXT NOT NULL,
  submitted_at TEXT,
  created_at TEXT,
  updated_at TEXT
);

CREATE INDEX index_reviews_on_pull_request_id ON reviews(pull_request_id);
CREATE INDEX index_reviews_on_author ON reviews(author);
CREATE INDEX index_reviews_on_state ON reviews(state);