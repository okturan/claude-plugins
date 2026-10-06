import { expect, test } from 'claude-code/testing'

import { argsOfPsLine, relaunchArgs, shQuote } from './relaunch'

const ID = '3f16a0e2-07d4-4d6f-9c7d-242450e38448'

test('keeps permission and model flags, swaps the resume target', async () => {
  const args = argsOfPsLine('claude --dangerously-skip-permissions --resume powerup')
  expect(relaunchArgs(args, ID)).toEqual(['--dangerously-skip-permissions', '--resume', ID])
})

test('keeps valued flags with their values and drops a positional prompt', async () => {
  const args = ['--model', 'claude-opus-5-5[1m]', '--chrome', '-c', 'fix the bug']
  expect(relaunchArgs(args, ID)).toEqual(['--model', 'claude-opus-5-5[1m]', '--chrome', '--resume', ID])
})

test('handles --flag=value and a versioned binary path', async () => {
  const args = argsOfPsLine('/Users/okan/.local/share/claude/versions/2.1.284 --permission-mode=acceptEdits --session-id abc')
  expect(relaunchArgs(args, ID)).toEqual(['--permission-mode=acceptEdits', '--resume', ID])
})

test('quotes what sh would expand', async () => {
  expect(shQuote('claude-opus-5-5[1m]')).toBe(`'claude-opus-5-5[1m]'`)
  expect(shQuote('--chrome')).toBe('--chrome')
})
