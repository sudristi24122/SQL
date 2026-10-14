# SQL Terminal Runner

Local VS Code helper for sending SQL to an already-open DuckDB terminal.

- Click **Run All in Terminal** above the SQL file, or the toolbar button whose tooltip is **Run All SQL in Terminal**.
- To execute only selected SQL, use **Run Selected SQL in Terminal** in the editor's right-click menu.
- The target terminal must be named `duckdb` and already running DuckDB at a ready prompt, with no unfinished SQL or other pending input. Do not give a PowerShell prompt this name.
- Multiple matching terminals trigger a picker. Missing terminals produce a message instead of opening a new shell.
- Source text, including unsaved edits, is sent unchanged with Enter. End SQL statements with semicolons. The whole-file command ignores selections and runs every statement, including any writes.
- Results, authentication, database selection, and output formatting belong to the existing terminal session. No credentials or new database connections are created by this helper.
- The other DuckDB extension's **Run** controls still open that extension's results tab.

Run tests with `npm test` from this directory. Package locally with `npx @vscode/vsce package --no-dependencies --allow-missing-repository --skip-license`, then install the generated VSIX through VS Code's **Extensions: Install from VSIX** command. This private helper is not intended for Marketplace publication.