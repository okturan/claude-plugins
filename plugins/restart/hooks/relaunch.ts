// Builds the command that reopens this session: the flags it was launched with, minus
// whatever picked the conversation or ran a one-off prompt, plus --resume <this id>.

// Flags that take a value in the next token.
const VALUED = new Set([
  '--model', '--permission-mode', '--resume', '-r', '--session-id', '--add-dir',
  '--settings', '--mcp-config', '--append-system-prompt', '--system-prompt',
  '--allowedTools', '--allowed-tools', '--disallowedTools', '--disallowed-tools',
  '--agent', '--agents', '--fallback-model', '--plugin-dir', '--effort', '--name', '-n',
  '--setting-sources', '--output-format', '--input-format', '--max-turns',
])

// Flags dropped because the restart chooses the conversation itself or is interactive.
const DROP = new Set(['--resume', '-r', '--continue', '-c', '--session-id', '--fork-session', '-p', '--print'])

/** The arguments after the executable, rebuilt for a restart of `sessionId`. */
export function relaunchArgs(args: readonly string[], sessionId: string): string[] {
  const out: string[] = []
  for (let i = 0; i < args.length; i++) {
    const a = args[i]
    const eq = a.startsWith('--') ? a.indexOf('=') : -1
    const flag = eq > 0 ? a.slice(0, eq) : a
    const takesValue = eq < 0 && VALUED.has(flag)
    if (!a.startsWith('-')) continue // a positional prompt: not repeated
    if (DROP.has(flag)) {
      if (takesValue) i++
      continue
    }
    out.push(a)
    if (takesValue && i + 1 < args.length) out.push(args[++i])
  }
  return [...out, '--resume', sessionId]
}

/** Single quotes for sh, so `claude-opus-5-5[1m]` and the like survive. */
export function shQuote(s: string): string {
  return /^[\w@%+=:,./-]+$/.test(s) ? s : `'${s.replace(/'/g, `'\\''`)}'`
}

/** The tokens after the executable in a `ps -o args=` line. */
export function argsOfPsLine(line: string): string[] {
  const parts = line.trim().split(/\s+/)
  return parts.slice(1)
}
