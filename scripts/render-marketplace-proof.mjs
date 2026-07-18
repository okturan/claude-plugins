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
    label: "MAP · DEDUPLICATE · REORGANIZE",
    lines: ["Disk and folder inventory", "Duplicate and orphan detection", "Interactive HTML file map"],
    accent: "#22d3ee",
  },
  "project-health": {
    label: "SCORE · DIAGNOSE · PRIORITIZE",
    lines: ["Nine-category repository audit", "Weighted score out of 100", "Actionable health report"],
    accent: "#a78bfa",
  },
  "human-writing": {
    label: "DETECT · REWRITE · KEEP VOICE",
    lines: ["AI-tell detection catalog", "Two-pass /humanize command", "Specifics without invented detail"],
    accent: "#fb7185",
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

function metric(label, value, x, y, accent) {
  return `<g transform="translate(${x} ${y})">
    <rect width="92" height="54" rx="12" fill="#111827" stroke="#334155" />
    <text x="46" y="23" text-anchor="middle" class="metric-value" fill="${accent}">${value}</text>
    <text x="46" y="41" text-anchor="middle" class="metric-label">${label}</text>
  </g>`;
}

function pluginCard(plugin, x) {
  const title = plugin.name.replaceAll("-", " ");
  const [line1, line2, line3] = plugin.lines.map(escapeXml);
  return `<g transform="translate(${x} 226)">
    <rect width="352" height="322" rx="24" fill="#0f172a" stroke="#334155" stroke-width="2" />
    <rect x="1" y="1" width="350" height="7" rx="4" fill="${plugin.accent}" />
    <circle cx="42" cy="51" r="18" fill="${plugin.accent}" fill-opacity="0.16" />
    <circle cx="42" cy="51" r="7" fill="${plugin.accent}" />
    <text x="72" y="48" class="card-title">${escapeXml(title)}</text>
    <text x="72" y="68" class="version">v${escapeXml(plugin.version)}</text>
    <text x="24" y="104" class="label" fill="${plugin.accent}">${escapeXml(plugin.label)}</text>
    <text x="24" y="140" class="body">${line1}</text>
    <text x="24" y="166" class="body">${line2}</text>
    <text x="24" y="192" class="body">${line3}</text>
    ${metric("COMMANDS", plugin.counts.commands, 24, 232, plugin.accent)}
    ${metric("AGENTS", plugin.counts.agents, 130, 232, plugin.accent)}
    ${metric("SKILLS", plugin.counts.skills, 236, 232, plugin.accent)}
  </g>`;
}

function render({ marketplace, plugins }) {
  const skillTotal = plugins.reduce((sum, plugin) => sum + plugin.counts.skills, 0);
  const pluginTotal = plugins.length;
  const cards = plugins.map((plugin, index) => pluginCard(plugin, 56 + index * 389)).join("\n");

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="720" viewBox="0 0 1280 720" role="img" aria-labelledby="title desc">
  <title id="title">okturan plugin marketplace capability map</title>
  <desc id="desc">Three installable Claude Code plugins and four reusable agent skills, generated from the repository marketplace and plugin manifests.</desc>
  <defs>
    <linearGradient id="background" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#020617" />
      <stop offset="0.52" stop-color="#0b1120" />
      <stop offset="1" stop-color="#111827" />
    </linearGradient>
    <radialGradient id="glow" cx="50%" cy="0" r="80%">
      <stop offset="0" stop-color="#2563eb" stop-opacity="0.28" />
      <stop offset="1" stop-color="#020617" stop-opacity="0" />
    </radialGradient>
    <style>
      text { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
      .eyebrow { fill: #93c5fd; font-size: 15px; font-weight: 700; letter-spacing: 2.2px; }
      .hero { fill: #f8fafc; font-size: 42px; font-weight: 760; }
      .sub { fill: #94a3b8; font-size: 18px; }
      .card-title { fill: #f8fafc; font-size: 24px; font-weight: 720; text-transform: capitalize; }
      .version { fill: #64748b; font-size: 12px; font-weight: 650; }
      .label { font-size: 11px; font-weight: 760; letter-spacing: 1.2px; }
      .body { fill: #cbd5e1; font-size: 16px; }
      .metric-value { font-size: 22px; font-weight: 760; }
      .metric-label { fill: #64748b; font-size: 9px; font-weight: 700; letter-spacing: 0.8px; }
      .footer-title { fill: #e2e8f0; font-size: 15px; font-weight: 700; }
      .footer-body { fill: #94a3b8; font-size: 14px; }
      .mono { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
    </style>
  </defs>
  <rect width="1280" height="720" fill="url(#background)" />
  <rect width="1280" height="720" fill="url(#glow)" />
  <text x="56" y="55" class="eyebrow">${escapeXml(marketplace.name)} · OWNER-AUTHORED MARKETPLACE</text>
  <text x="56" y="108" class="hero">Small tools with sharp boundaries.</text>
  <text x="56" y="145" class="sub">${pluginTotal} installable plugins · ${skillTotal} reusable skills · one validated cross-platform contract</text>
  <g transform="translate(56 174)">
    <rect width="548" height="34" rx="17" fill="#172554" stroke="#1d4ed8" />
    <text x="18" y="22" class="footer-body mono" fill="#bfdbfe">npx skills@latest add okturan/claude-plugins</text>
  </g>
  <g transform="translate(620 174)">
    <rect width="604" height="34" rx="17" fill="#1e1b4b" stroke="#6d28d9" />
    <text x="18" y="22" class="footer-body mono" fill="#ddd6fe">/plugin marketplace add okturan/claude-plugins</text>
  </g>
  ${cards}
  <g transform="translate(56 581)">
    <rect width="1168" height="91" rx="18" fill="#0b1220" stroke="#1e293b" />
    <text x="24" y="32" class="footer-title">Repository contract</text>
    <text x="24" y="59" class="footer-body">marketplace.json → plugin manifests → skills, commands and agents → macOS + Linux CI</text>
    <text x="772" y="32" class="footer-title">Distribution</text>
    <text x="772" y="59" class="footer-body">skills.sh for reusable skills · Claude Code for full plugins</text>
  </g>
  <text x="56" y="703" fill="#475569" font-size="11">Generated from .claude-plugin/marketplace.json and each plugin manifest; verified by scripts/render-marketplace-proof.mjs --check</text>
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
