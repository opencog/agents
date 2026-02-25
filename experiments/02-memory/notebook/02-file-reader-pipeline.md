Directory-Scanning File-Reader Pipeline
=======================================
Date: 25 February 2026

The single-file reader in `scm/file-reader.scm` was replaced with a
directory-scanning pipeline. Instead of reading one hardcoded text file,
the pipeline uses `FileSysNode` to discover all files in the project's
`scm/` and `notebook/` directories, and logs each discovered filename
to `/tmp/agent.log` via `TextFileNode`.

All definitions are pure Atomese (no top-level Trigger calls) so they
survive a RocksDB store/restore cycle.

Key design points:

* `FileSysNode` `ls` returns a `LinkValue` whose element 0 is a
  command-echo `ItemNode` and elements 1+ are `StringValue`s containing
  `file://` URLs. A `(Type 'StringValue)` type guard in each Filter
  Rule naturally skips the echo.

* `TextStreamNode::do_write` does not accept `LinkValue` directly, so
  a Filter iterates the `ls` result and writes each filename
  individually.

* `PipeLink` is a `UniqueLink` and throws on redefinition. To allow
  `build-memory.scm.in` to set the actual project paths, the directory
  PipeLinks are defined only in `build-memory.scm.in`, not in
  `file-reader.scm`. The pipeline references the `NameNode`s, which
  are resolved at runtime.

Pipeline stages defined in `scm/file-reader.scm`:

1. Directory bindings -- NameNodes "scm dir" and "notebook dir" (bound
   to FileSysNodes in build-memory.scm.in).
2. Log file binding -- PipeLink for "agent log" pointing at
   `/tmp/agent.log`.
3. "dir-open" pipeline -- opens both directories and the log file.
4. "list-scm-files" / "list-notebook-files" -- PureExec schemas that
   write an `ls` command then read the result.
5. "log-scm-files" / "log-notebook-files" -- Filter schemas that
   iterate filenames and write each to the log.
6. "file-scan" pipeline -- lists both dirs, caches results at
   `(Anchor "file-pipe")`, drains the logging filters.
7. Named file streams -- `(Name "scm file stream")` and
   `(Name "notebook file stream")` for downstream consumption.
8. "file-reader" -- passthrough Filter placeholder for future per-file
   processing.

Changes to `scm/build-memory.scm.in`:

* Added `project-dir` variable set to `@CMAKE_SOURCE_DIR@`.
* After loading `file-reader.scm`, creates the two directory PipeLinks
  pointing at `<project-dir>/scm` and `<project-dir>/notebook`.

Runtime usage (after restoring from RocksDB):
```
(Trigger (Name "dir-open"))
(Trigger (Name "file-scan"))
(Trigger (Name "scm file stream"))
(Trigger (Name "notebook file stream"))
```
