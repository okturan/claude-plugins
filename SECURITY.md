# Security policy

## Supported version

The default branch and the plugin versions currently declared in their manifests receive best-effort security fixes. Older commits and copied skill installations are not supported versions; update the marketplace or reinstall the affected skill before reporting an issue that may already be fixed.

## Reporting a vulnerability

Use GitHub's **Report a vulnerability** form in the repository Security tab. Do not open a public issue for a vulnerability.

Useful reports include:

- unsafe path, symlink, or shell handling in the file-organizer scripts;
- a way for untrusted repository or file content to override a documented safety boundary;
- marketplace or plugin-manifest integrity problems;
- unintended disclosure of filenames, file contents, credentials, or host details; and
- an install or update path that executes code outside the documented plugin source.

Include the affected plugin, platform, reproduction steps, impact, and the smallest safe proof of concept. Do not attach private files, API keys, credentials, or full directory inventories. Please allow reasonable time for investigation before public disclosure.

Prompt output that is merely undesirable, subjective, or stylistically imperfect is not a security vulnerability unless it crosses a stated trust boundary or exposes data.
