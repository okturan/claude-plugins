#!/usr/bin/env node

import { access, mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const outputPath = path.join(root, "docs", "marketplace-map.svg");
const check = process.argv.includes("--check");

const proofCopy = {
  "files-organizer": {
    lines: [
      "Scans macOS storage, flags duplicate and misplaced files,",
      "and writes a standalone HTML file map.",
    ],
  },
  "project-health": {
    lines: [
      "Scores a Git repository across nine documented categories",
      "and shows the evidence behind every deduction.",
    ],
  },
  "human-writing": {
    lines: [
      "Drafts plain prose and rewrites common AI-writing patterns",
      "without inventing details or changing technical claims.",
    ],
  },
  "shape-the-work": {
    lines: [
      "Routes by the result needed now, not task duration,",
      "and checks each child before the handoff.",
    ],
  },
};

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

async function exists(target) {
  try {
    await access(target);
    return true;
  } catch {
    return false;
  }
}

async function countFiles(directory, predicate = () => true) {
  if (!(await exists(directory))) return 0;
  const entries = await readdir(directory, { withFileTypes: true });
  let count = 0;
  for (const entry of entries) {
    const target = path.join(directory, entry.name);
    if (entry.isDirectory()) count += await countFiles(target, predicate);
    else if (predicate(target)) count += 1;
  }
  return count;
}

async function readMarketplace() {
  const marketplace = JSON.parse(
    await readFile(path.join(root, ".claude-plugin", "marketplace.json"), "utf8"),
  );

  const plugins = [];
  for (const entry of marketplace.plugins) {
    const pluginRoot = path.join(root, entry.source);
    const manifest = JSON.parse(
      await readFile(path.join(pluginRoot, ".claude-plugin", "plugin.json"), "utf8"),
    );
    const visual = proofCopy[manifest.name];
    if (!visual) throw new Error(`missing visual proof copy for ${manifest.name}`);

    plugins.push({
      ...manifest,
      ...visual,
      counts: {
        commands: await countFiles(path.join(pluginRoot, "commands"), (file) => file.endsWith(".md")),
        agents: await countFiles(path.join(pluginRoot, "agents"), (file) => file.endsWith(".md")),
        skills: await countFiles(path.join(pluginRoot, "skills"), (file) => file.endsWith("SKILL.md")),
      },
    });
  }

  return { marketplace, plugins };
}

function pluralize(count, singular) {
  return `${count} ${singular}${count === 1 ? "" : "s"}`;
}

function pluginRow(plugin, y) {
  const title = plugin.name.replaceAll("-", " ");
  const [line1, line2] = plugin.lines.map(escapeXml);
  const contents = [
    pluralize(plugin.counts.commands, "command"),
    plugin.counts.agents > 0 ? pluralize(plugin.counts.agents, "agent") : null,
    pluralize(plugin.counts.skills, "skill"),
  ]
    .filter(Boolean)
    .join(" / ");

  return `<g transform="translate(56 ${y})">
    <line x1="0" y1="0" x2="1168" y2="0" class="rule" />
    <rect x="0" y="18" width="4" height="52" fill="#226554" />
    <text x="20" y="39" class="row-title">${escapeXml(title)}</text>
    <text x="20" y="62" class="version">v${escapeXml(plugin.version)}</text>
    <text x="306" y="38" class="body">${line1}</text>
    <text x="306" y="62" class="body">${line2}</text>
    <text x="900" y="50" class="contents mono">${escapeXml(contents)}</text>
  </g>`;
}

function render({ marketplace, plugins }) {
  const skillTotal = plugins.reduce((sum, plugin) => sum + plugin.counts.skills, 0);
  const pluginTotal = plugins.length;
  const rows = plugins.map((plugin, index) => pluginRow(plugin, 278 + index * 88)).join("\n");

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="720" viewBox="0 0 1280 720" role="img" aria-labelledby="title desc">
  <title id="title">Contents of the okturan Claude plugin repository</title>
  <desc id="desc">${pluginTotal} Claude Code plugins and ${skillTotal} reusable skills, counted from the repository files.</desc>
  <defs>
    <style>
      text { fill: #1c1917; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
      .repo { fill: #226554; font-size: 14px; font-weight: 650; }
      .hero { font-size: 40px; font-weight: 680; letter-spacing: -0.7px; }
      .sub { fill: #57534e; font-size: 17px; }
      .column { fill: #78716c; font-size: 11px; font-weight: 700; letter-spacing: 1.2px; }
      .row-title { font-size: 23px; font-weight: 650; text-transform: capitalize; }
      .version { fill: #78716c; font-size: 12px; font-weight: 600; }
      .body { fill: #44403c; font-size: 16px; }
      .contents { fill: #44403c; font-size: 13px; }
      .code { font-size: 14px; }
      .footer { fill: #78716c; font-size: 12px; }
      .rule { stroke: #c9c5bd; stroke-width: 1; }
      .mono { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
    </style>
  </defs>
  <rect width="1280" height="720" fill="#f4f1ea" />
  <text x="56" y="46" class="repo mono">okturan / ${escapeXml(marketplace.name)}</text>
  <text x="56" y="99" class="hero">Claude Code plugins and agent skills</text>
  <text x="56" y="132" class="sub">${pluginTotal} plugins and ${skillTotal} reusable skills, counted from the files in this repository.</text>
  <text x="56" y="174" class="column">INSTALL INDIVIDUAL SKILLS</text>
  <g transform="translate(56 186)">
    <rect width="548" height="44" rx="4" fill="#fffefa" stroke="#c9c5bd" />
    <text x="16" y="28" class="code mono">npx skills@latest add okturan/claude-plugins</text>
  </g>
  <text x="620" y="174" class="column">ADD THE CLAUDE CODE MARKETPLACE</text>
  <g transform="translate(620 186)">
    <rect width="604" height="44" rx="4" fill="#fffefa" stroke="#c9c5bd" />
    <text x="16" y="28" class="code mono">/plugin marketplace add okturan/claude-plugins</text>
  </g>
  <text x="56" y="266" class="column">PLUGIN</text>
  <text x="362" y="266" class="column">WHAT IT DOES</text>
  <text x="956" y="266" class="column">CONTENTS</text>
  ${rows}
  <line x1="56" y1="630" x2="1224" y2="630" class="rule" />
  <text x="56" y="674" class="footer">Generated from .claude-plugin/marketplace.json and each plugin manifest.</text>
  <text x="1224" y="674" text-anchor="end" class="footer mono">node scripts/render-marketplace-proof.mjs --check</text>
</svg>
`;
}

const data = await readMarketplace();
const output = render(data);

if (check) {
  const current = await readFile(outputPath, "utf8").catch(() => "");
  if (current !== output) {
    console.error("docs/marketplace-map.svg is stale; regenerate it with node scripts/render-marketplace-proof.mjs");
    process.exit(1);
  }
  console.log("Marketplace proof matches the manifests.");
} else {
  await mkdir(path.dirname(outputPath), { recursive: true });
  await writeFile(outputPath, output);
  console.log(`Wrote ${path.relative(root, outputPath)}`);
}
