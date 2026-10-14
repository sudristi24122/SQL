const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const vm = require('node:vm');

function createTerminal(name = 'duckdb') {
    return {
        name,
        sent: [],
        shown: [],
        show(preserveFocus) { this.shown.push(preserveFocus); },
        sendText(text, execute) { this.sent.push({ text, execute }); }
    };
}

function setup(options = {}) {
    const commands = new Map();
    const warnings = [];
    const terminal = createTerminal();
    const document = {
        languageId: options.languageId || 'sql',
        uri: { path: '/lesson.sql' },
        getText: (selection) => selection ? 'SELECT 2;' : (options.sql ?? 'SELECT 1;\r\nSELECT 2;')
    };
    let lensProvider;
    const api = {
        workspace: {
            isTrusted: options.trusted ?? true,
            openTextDocument: async () => document
        },
        window: {
            activeTextEditor: { document, selection: { isEmpty: options.emptySelection ?? false } },
            terminals: options.terminals ?? [terminal],
            showWarningMessage: async (message) => warnings.push(message),
            showQuickPick: options.pick || (async (items) => items[0])
        },
        commands: {
            registerCommand(name, handler) {
                commands.set(name, handler);
                return { dispose() {} };
            }
        },
        languages: {
            registerCodeLensProvider(selector, provider) {
                lensProvider = provider;
                return { dispose() {} };
            }
        },
        Range: class Range {},
        CodeLens: class CodeLens {
            constructor(range, command) { this.command = command; }
        }
    };
    const sandbox = { module: { exports: {} }, require: () => api };
    vm.runInNewContext(readFileSync(path.join(__dirname, 'extension.js'), 'utf8'), sandbox);
    sandbox.module.exports.activate({ subscriptions: [] });
    return { api, document, terminal, commands, warnings, lensProvider };
}

test('Run All sends the entire editor buffer and Enter to DuckDB, not active PowerShell', async () => {
    const state = setup();
    const powershell = createTerminal('powershell');
    state.api.window.terminals.push(powershell);
    state.api.window.activeTerminal = powershell;
    await state.commands.get('sqlTerminalRunner.runAll')();
    assert.deepEqual(state.terminal.sent, [{ text: 'SELECT 1;\r\nSELECT 2;', execute: true }]);
    assert.deepEqual(state.terminal.shown, [true]);
    assert.equal(powershell.sent.length, 0);
});

test('selection command sends only the selection', async () => {
    const state = setup();
    await state.commands.get('sqlTerminalRunner.runSelection')();
    assert.deepEqual(state.terminal.sent, [{ text: 'SELECT 2;', execute: true }]);
});

test('CodeLens uses its own document even when another SQL editor is active', async () => {
    const state = setup();
    const lens = state.lensProvider.provideCodeLenses(state.document)[0];
    state.api.window.activeTextEditor.document = { languageId: 'sql', getText: () => 'SELECT 99;' };
    await state.commands.get(lens.command.command)(...lens.command.arguments);
    assert.equal(state.terminal.sent[0].text, 'SELECT 1;\r\nSELECT 2;');
});

test('never falls back to PowerShell or an exited DuckDB terminal', async () => {
    const powershell = createTerminal('powershell');
    const closed = createTerminal();
    closed.exitStatus = { code: 0 };
    const state = setup({ terminals: [powershell, closed] });
    await state.commands.get('sqlTerminalRunner.runAll')();
    assert.equal(state.warnings.length, 1);
    assert.equal(powershell.sent.length + closed.sent.length, 0);
});

test('multiple DuckDB sessions require an explicit selection', async () => {
    const first = createTerminal();
    const second = createTerminal();
    const state = setup({ terminals: [first, second], pick: async (items) => items[1] });
    await state.commands.get('sqlTerminalRunner.runAll')();
    assert.equal(first.sent.length, 0);
    assert.equal(second.sent.length, 1);
});

test('canceling the terminal picker sends nothing', async () => {
    const first = createTerminal();
    const second = createTerminal();
    const state = setup({ terminals: [first, second], pick: async () => undefined });
    await state.commands.get('sqlTerminalRunner.runAll')();
    assert.equal(first.sent.length + second.sent.length, 0);
});

test('rejects a terminal closed while the picker is open', async () => {
    const first = createTerminal();
    const second = createTerminal();
    const state = setup({ terminals: [first, second], pick: async (items) => {
        first.exitStatus = { code: 0 };
        return items[0];
    } });
    await state.commands.get('sqlTerminalRunner.runAll')();
    assert.equal(first.sent.length, 0);
    assert.equal(state.warnings.length, 1);
});

test('empty SQL, non-SQL documents, and untrusted workspaces send nothing', async () => {
    for (const options of [{ sql: '  \r\n' }, { languageId: 'plaintext' }, { trusted: false }]) {
        const state = setup(options);
        await state.commands.get('sqlTerminalRunner.runAll')();
        assert.equal(state.terminal.sent.length, 0);
    }
});

test('empty selection does not accidentally run the whole file', async () => {
    const state = setup({ emptySelection: true });
    await state.commands.get('sqlTerminalRunner.runSelection')();
    assert.equal(state.terminal.sent.length, 0);
    assert.equal(state.warnings.length, 1);
});

test('toolbar manifest points at the tested Run All command', () => {
    const manifest = JSON.parse(readFileSync(path.join(__dirname, 'package.json'), 'utf8'));
    assert.equal(manifest.contributes.menus['editor/title'][0].command, 'sqlTerminalRunner.runAll');
    assert.equal(manifest.capabilities.untrustedWorkspaces.supported, false);
});