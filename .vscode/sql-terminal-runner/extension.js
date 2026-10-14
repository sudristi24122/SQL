const vscode = require('vscode');

function isDuckDbTerminal(terminal) {
    return terminal.name.trim().toLowerCase() === 'duckdb'
        && terminal.exitStatus === undefined;
}

async function runSql(uri, selectionOnly) {
    if (!vscode.workspace.isTrusted) {
        return;
    }

    const editor = vscode.window.activeTextEditor;
    const document = uri && !selectionOnly
        ? await vscode.workspace.openTextDocument(uri)
        : editor?.document;

    if (!document || document.languageId !== 'sql') {
        await vscode.window.showWarningMessage('Open a SQL file first.');
        return;
    }

    if (selectionOnly && editor.selection.isEmpty) {
        await vscode.window.showWarningMessage('Select the SQL to run first.');
        return;
    }

    const sql = document.getText(selectionOnly ? editor.selection : undefined);
    if (!sql.trim()) {
        await vscode.window.showWarningMessage('There is no SQL to run.');
        return;
    }

    const terminals = vscode.window.terminals.filter(isDuckDbTerminal);
    if (terminals.length === 0) {
        await vscode.window.showWarningMessage(
            'No open terminal named duckdb. Start DuckDB in a terminal, name it duckdb, and retry.'
        );
        return;
    }

    let terminal = terminals[0];
    if (terminals.length > 1) {
        const selected = await vscode.window.showQuickPick(
            terminals.map((candidate, index) => ({
                label: candidate.name,
                description: `Terminal ${index + 1}${candidate === vscode.window.activeTerminal ? ' (active)' : ''}`,
                terminal: candidate
            })),
            { placeHolder: 'Select the DuckDB session to run this SQL in' }
        );
        if (!selected) {
            return;
        }
        terminal = selected.terminal;
    }

    if (!vscode.workspace.isTrusted
        || !vscode.window.terminals.includes(terminal)
        || !isDuckDbTerminal(terminal)) {
        await vscode.window.showWarningMessage('The DuckDB terminal is no longer available.');
        return;
    }

    terminal.show(true);
    terminal.sendText(sql, true);
}

function activate(context) {
    context.subscriptions.push(
        vscode.commands.registerCommand('sqlTerminalRunner.runAll', (uri) => runSql(uri, false)),
        vscode.commands.registerCommand('sqlTerminalRunner.runSelection', () => runSql(undefined, true)),
        vscode.languages.registerCodeLensProvider(
            [{ language: 'sql', scheme: 'file' }, { language: 'sql', scheme: 'untitled' }],
            {
                provideCodeLenses(document) {
                    return [new vscode.CodeLens(new vscode.Range(0, 0, 0, 0), {
                        title: 'Run All in Terminal',
                        command: 'sqlTerminalRunner.runAll',
                        arguments: [document.uri]
                    })];
                }
            }
        )
    );
}

module.exports = { activate };