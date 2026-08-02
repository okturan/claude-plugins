#!/usr/bin/env node

import { mkdtemp, mkdir, readFile, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import process from "node:process";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const outputDirectory = path.join(root, "docs", "examples");
const check = process.argv.includes("--check");

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd || root,
    env: options.env || process.env,
    encoding: "utf8",
    maxBuffer: 4 * 1024 * 1024,
  });

  if (result.status !== 0) {
    const detail = [result.stdout, result.stderr].filter(Boolean).join("\n").trim();
    throw new Error(`${command} ${args.join(" ")} failed${detail ? `:\n${detail}` : ""}`);
  }

  return result.stdout;
}

async function captureFileOrganizer() {
  const fixtureRoot = await mkdtemp(path.join(tmpdir(), "plugin-example-files-"));

  try {
    await mkdir(path.join(fixtureRoot, "alpha"));
    await mkdir(path.join(fixtureRoot, "beta"));
    await writeFile(path.join(fixtureRoot, "alpha", "report.txt"), "same duplicate payload\n");
    await writeFile(path.join(fixtureRoot, "beta", "report.txt"), "same duplicate payload\n");
    await writeFile(path.join(fixtureRoot, "alpha", "note.md"), "a standalone note\n");

    const raw = run("bash", [
      path.join(root, "plugins", "files-organizer", "scripts", "find-duplicates.sh"),
      fixtureRoot,
      "1",
    ]).replaceAll(fixtureRoot, "./sample-files");

    const hash = raw.match(/--- Duplicate group \(MD5: ([^)]+)\) ---/)?.[1];
    const required = [
      "Scanning file sizes...",
      "Hashing potential duplicates...",
      "[23 B] ./sample-files/alpha/report.txt",
      "[23 B] ./sample-files/beta/report.txt",
      "Duplicate groups found: 1",
      "Bytes used by copies beyond the first: 23 B",
    ];
    for (const value of required) {
      if (!raw.includes(value)) throw new Error(`file-organizer fixture output is missing: ${value}`);
    }
    if (!hash) throw new Error("file-organizer fixture did not produce a duplicate hash");

    return {
      filename: "files-organizer.svg",
      title: "files-organizer · duplicate scan",
      subtitle: "Three-file fixture used by the repository test suite",
      description: "A real deterministic run finding one pair of identical files.",
      lines: [
        ["prompt", "$ bash find-duplicates.sh ./sample-files 1"],
        ["muted", "Scanning file sizes..."],
        ["muted", "Hashing potential duplicates..."],
        ["heading", "=== DUPLICATE GROUPS ==="],
        ["output", `--- Duplicate group (MD5: ${hash}) ---`],
        ["output", "  [23 B] ./sample-files/alpha/report.txt"],
        ["output", "  [23 B] ./sample-files/beta/report.txt"],
        ["blank", ""],
        ["heading", "=== SUMMARY ==="],
        ["good", "Duplicate groups found: 1"],
        ["good", "Bytes used by copies beyond the first: 23 B"],
      ],
      footer: "Live fixture output · paths and timestamp normalized",
    };
  } finally {
    await rm(fixtureRoot, { recursive: true, force: true });
  }
}

async function captureShapeTheWork() {
  const fixtureRoot = await mkdtemp(path.join(tmpdir(), "plugin-example-shape-"));

  try {
    const projectRoot = path.join(fixtureRoot, "project");
    const startDirectory = path.join(projectRoot, "services", "api");
    const fakeHome = path.join(fixtureRoot, "home");
    const fakeBin = path.join(fixtureRoot, "bin");
    const openspecSkill = path.join(projectRoot, ".codex", "skills", "openspec-explore");
    const wayfinderSkill = path.join(fakeHome, ".agents", "skills", "wayfinder");

    await mkdir(startDirectory, { recursive: true });
    await mkdir(openspecSkill, { recursive: true });
    await mkdir(wayfinderSkill, { recursive: true });
    await mkdir(fakeBin, { recursive: true });
    await writeFile(path.join(openspecSkill, "SKILL.md"), "fixture\n");
    await writeFile(path.join(wayfinderSkill, "SKILL.md"), "fixture\n");
    await symlink(path.join(root, "scripts", "fixtures", "shape-work-openspec"), path.join(fakeBin, "openspec"));
    run("git", ["init", "-q"], { cwd: projectRoot });

    const raw = run(
      "bash",
      [
        path.join(
          root,
          "plugins",
          "shape-the-work",
          "skills",
          "shape-the-work",
          "scripts",
          "check-dependencies.sh",
        ),
        "--json",
        startDirectory,
      ],
      {
        env: {
          ...process.env,
          FAKE_OPENSPEC_ROOT: projectRoot,
          SHAPE_WORK_HOME_ROOT: fakeHome,
          SHAPE_WORK_CODEX_ROOT: path.join(fakeHome, ".codex"),
          PATH: `${fakeBin}:${process.env.PATH || ""}`,
        },
      },
    );

    const report = JSON.parse(raw);
    const byName = new Map(report.skills.map((skill) => [skill.name, skill]));
    const openspec = byName.get("openspec-explore");
    const wayfinder = byName.get("wayfinder");
    const longHorizon = byName.get("long-horizon-prompting");

    if (openspec?.status !== "ready" || !openspec.detail.includes("9.9.9-test")) {
      throw new Error("shape-the-work fixture did not report OpenSpec Explore as ready");
    }
    if (
      wayfinder?.status !== "needs-setup" ||
      !wayfinder.detail.includes("grilling, domain-modeling, docs/agents/issue-tracker.md contract")
    ) {
      throw new Error("shape-the-work fixture did not report the expected Wayfinder prerequisites");
    }
    if (longHorizon?.status !== "missing") {
      throw new Error("shape-the-work fixture did not report Long-Horizon Prompting as missing");
    }

    return {
      filename: "shape-the-work.svg",
      title: "shape-the-work · readiness check",
      subtitle: "Controlled project with one ready, one incomplete, and one missing route",
      description: "A real dependency-checker run against the repository's controlled fixture.",
      lines: [
        ["prompt", "$ check-dependencies.sh --json ./project/services/api"],
        ["heading", "STATUS       SKILL                       DETAIL"],
        ["good", "ready        openspec-explore"],
        ["output", "             openspec 9.9.9-test resolved ./project"],
        ["blank", ""],
        ["warn", "needs-setup  wayfinder"],
        ["output", "             missing: grilling, domain-modeling, tracker contract"],
        ["output", "             setup helper not found"],
        ["blank", ""],
        ["bad", "missing      long-horizon-prompting"],
        ["output", "             skill not found"],
      ],
      footer: "Live fixture output · temporary paths shortened",
    };
  } finally {
    await rm(fixtureRoot, { recursive: true, force: true });
  }
}

function projectHealthSnapshot() {
  const categories = [
    ["Repository & Git", 15, 15, ""],
    ["Project Structure", 15, 15, ""],
    ["Code Quality", 15, 15, ""],
    ["Config & Environment", 10, 10, ""],
    ["Data & Database", 10, 10, "N/A"],
    ["Documentation", 8, 10, "no changelog"],
    ["Testing & CI", 12, 15, "no local pre-commit check"],
    ["Dependencies", 5, 5, ""],
    ["Security", 5, 5, ""],
  ];
  const score = categories.reduce((sum, [, value]) => sum + value, 0);
  const maximum = categories.reduce((sum, [, , value]) => sum + value, 0);
  if (score !== 95 || maximum !== 100) throw new Error("project-health snapshot totals are inconsistent");

  const lines = [
    ["prompt", "$ /project-health    claude-plugins @ 7e3e5d6"],
    ["good", `OVERALL SCORE  ${score} / ${maximum}`],
    ["blank", ""],
  ];
  for (const [name, value, max, note] of categories) {
    const bar = "#".repeat(Math.round((value / max) * 10)).padEnd(10, "-");
    const scoreText = `${value}/${max}`.padStart(5);
    const noteText = note ? `  ${note}` : "";
    lines.push([value === max ? "output" : "warn", `${name.padEnd(22)} ${scoreText}  [${bar}]${noteText}`]);
  }
  lines.push(["blank", ""]);
  lines.push(["warn", "Next: add a changelog and a local pre-commit check."]);

  return {
    filename: "project-health.svg",
    title: "project-health · repository audit",
    subtitle: "Actual audit of this repository at main commit 7e3e5d6",
    description: "A real project-health score with all nine categories and two documented deductions.",
    lines,
    footer: "Audited 2026-08-02 · scoring evidence documented beside this capture",
  };
}

function humanWritingRevision() {
  return {
    filename: "human-writing.svg",
    title: "human-writing · README revision",
    subtitle: "Exact text from commits 7ecdf43 and 1759db3",
    description: "A real before-and-after revision from the human-writing plugin README.",
    lines: [
      ["prompt", "$ git diff 7ecdf43..1759db3 -- plugins/human-writing/README.md"],
      ["blank", ""],
      ["minus", "− BEFORE · 7ecdf43"],
      ["minus", "Write outward-facing prose that reads like a person wrote it,"],
      ["minus", "and strip AI tells from existing drafts."],
      ["blank", ""],
      ["plus", "+ AFTER · 1759db3"],
      ["plus", "Draft plain outward-facing prose."],
      ["plus", "Rewrite existing text without sanding away the author's voice"],
      ["plus", "or changing technical claims."],
      ["blank", ""],
      ["muted", "Same scope. Shorter opening. Concrete constraints kept."],
    ],
    footer: "Repository history, not sample marketing copy",
  };
}

function renderCapture(capture) {
  const lineHeight = 23;
  const firstLineY = 184;
  const lineMarkup = capture.lines
    .map(([kind, value], index) => {
      if (kind === "blank") return "";
      return `    <text x="70" y="${firstLineY + index * lineHeight}" class="terminal ${kind}">${escapeXml(value)}</text>`;
    })
    .filter(Boolean)
    .join("\n");

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="600" viewBox="0 0 1080 600" role="img" aria-labelledby="title desc">
  <title id="title">${escapeXml(capture.title)}</title>
  <desc id="desc">${escapeXml(capture.description)}</desc>
  <defs>
    <filter id="shadow" x="-10%" y="-10%" width="120%" height="130%">
      <feDropShadow dx="0" dy="8" stdDeviation="12" flood-color="#1c1917" flood-opacity="0.14" />
    </filter>
    <style>
      text { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
      .eyebrow { fill: #226554; font-size: 12px; font-weight: 750; letter-spacing: 1.4px; }
      .title { fill: #1c1917; font-size: 31px; font-weight: 700; letter-spacing: -0.35px; }
      .subtitle { fill: #57534e; font-size: 15px; }
      .terminal { fill: #d8dee9; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 15px; }
      .prompt { fill: #a7c080; font-weight: 650; }
      .heading { fill: #d3c6aa; font-weight: 700; }
      .output { fill: #d8dee9; }
      .good, .plus { fill: #a7c080; }
      .warn { fill: #dbbc7f; }
      .bad, .minus { fill: #e67e80; }
      .muted { fill: #859289; }
      .footer { fill: #78716c; font-size: 12px; }
      .footer-code { fill: #78716c; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 11px; }
    </style>
  </defs>
  <rect width="1080" height="600" fill="#f4f1ea" />
  <text x="48" y="34" class="eyebrow">REPRODUCIBLE EVIDENCE</text>
  <text x="48" y="74" class="title">${escapeXml(capture.title)}</text>
  <text x="48" y="101" class="subtitle">${escapeXml(capture.subtitle)}</text>
  <g filter="url(#shadow)">
    <rect x="48" y="126" width="984" height="396" rx="9" fill="#151b1a" />
    <path d="M48 135a9 9 0 0 1 9-9h966a9 9 0 0 1 9 9v28H48z" fill="#202725" />
    <circle cx="70" cy="145" r="5" fill="#e67e80" />
    <circle cx="88" cy="145" r="5" fill="#dbbc7f" />
    <circle cx="106" cy="145" r="5" fill="#a7c080" />
    <text x="540" y="150" text-anchor="middle" class="footer-code">captured output</text>
${lineMarkup}
  </g>
  <text x="48" y="562" class="footer">${escapeXml(capture.footer)}</text>
  <text x="1032" y="562" text-anchor="end" class="footer-code">node scripts/render-plugin-examples.mjs --check</text>
</svg>
`;
}

const captures = [
  await captureFileOrganizer(),
  projectHealthSnapshot(),
  humanWritingRevision(),
  await captureShapeTheWork(),
];

const marketplace = JSON.parse(
  await readFile(path.join(root, ".claude-plugin", "marketplace.json"), "utf8"),
);
const marketplaceNames = marketplace.plugins.map((plugin) => plugin.name).sort();
const captureNames = captures.map((capture) => path.basename(capture.filename, ".svg")).sort();
if (JSON.stringify(captureNames) !== JSON.stringify(marketplaceNames)) {
  throw new Error(
    `plugin example coverage differs from the marketplace: captures=${captureNames.join(", ")} marketplace=${marketplaceNames.join(", ")}`,
  );
}

let stale = false;
for (const capture of captures) {
  const outputPath = path.join(outputDirectory, capture.filename);
  const output = renderCapture(capture);

  if (check) {
    const current = await readFile(outputPath, "utf8").catch(() => "");
    if (current !== output) {
      console.error(`${path.relative(root, outputPath)} is stale; regenerate with node scripts/render-plugin-examples.mjs`);
      stale = true;
    }
  } else {
    await mkdir(outputDirectory, { recursive: true });
    await writeFile(outputPath, output);
    console.log(`Wrote ${path.relative(root, outputPath)}`);
  }
}

if (stale) process.exit(1);
if (check) console.log("Plugin example captures match their fixtures and documented snapshots.");
