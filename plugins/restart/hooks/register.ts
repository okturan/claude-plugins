import type { Register } from 'claude-code'

import { argsOfPsLine, relaunchArgs, shQuote } from './relaunch'

// Finds this session's own process (the first ancestor whose program is claude or a
// versions/<x.y.z> binary) and prints its pid and its full command line.
const FIND_SELF = `p=$PPID; i=0
while [ "$p" -gt 1 ] && [ $i -lt 8 ]; do
  c=$(ps -o args= -p "$p")
  case "$(echo "$c" | awk '{print $1}')" in
    claude|*/claude|*/versions/[0-9]*) echo "$p"; echo "$c"; exit 0;;
  esac
  p=$(ps -o ppid= -p "$p" | tr -d ' '); i=$((i+1))
done
exit 1`

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'restart',
      description: 'Reopen this session on the newest installed Claude Code (same conversation, same flags)',
    })
    return next(e)
  })

  on('command.run', { command: 'restart' }, async $ => {
    const pane = await $.env.get('HERDR_PANE_ID')
    const herdr = (await $.env.get('HERDR_BIN_PATH')) ?? 'herdr'
    const sessionId = await $.session.id()

    const self = await $.process.run(['/bin/sh', '-c', FIND_SELF])
    if (self.exitCode !== 0) return { text: "restart: could not find this session's process, nothing changed." }
    const [pidLine, psLine] = self.stdout.trim().split('\n')
    const pid = Number(pidLine)
    const cmd = ['claude', ...relaunchArgs(argsOfPsLine(psLine ?? ''), sessionId)].map(shQuote).join(' ')

    const installed = (await $.process.run(['/bin/sh', '-lc', 'claude --version'])).stdout.trim().split(' ')[0]
    const running = (await $.session.version()).version
    const versions = installed && installed !== running ? `${running} → ${installed}` : `${running} (already the newest installed)`

    if (!pane) {
      return { text: `restart: not in a herdr pane, so it can't reopen itself here. Exit and run:\n${cmd}` }
    }

    // The helper runs in its own session: it ends this process with SIGTERM (the same
    // clean shutdown as closing the terminal), waits for it to go, then types the
    // command into the same pane. A mod's own /exit does not end the session.
    const watcher = `sleep 1; kill -TERM ${pid} 2>/dev/null; i=0
while kill -0 ${pid} 2>/dev/null; do sleep 0.5; i=$((i+1)); [ $i -eq 20 ] && kill -INT ${pid} 2>/dev/null; [ $i -gt 120 ] && exit 0; done
sleep 0.5; ${shQuote(herdr)} pane run ${shQuote(pane)} ${shQuote(cmd)}`
    await $.process.run(['/bin/sh', '-c', `perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' /bin/sh -c ${shQuote(watcher)} </dev/null >/dev/null 2>&1 &`])

    return { text: `Restarting ${versions}\n${cmd}` }
  }).catch(async ($, e, next) => ({ text: `restart failed, nothing changed: ${String(next.error).slice(0, 200)}` }))
}
