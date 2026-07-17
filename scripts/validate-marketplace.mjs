#!/usr/bin/env node

import { access, readFile, readdir, stat } from "node:fs/promises";
import path from "node:path";
import process from "node:process";

const root = process.cwd();
const failures = [];

function fail(message) {
  failures.push(message);
}

async function exists(target) {
  try {
    await access(target);
    return true;
  } catch {
    return false;
  }
}

async function readJson(relativePath) {
  try {
    return JSON.parse(await readFile(path.join(root, relativePath), "utf8"));
  } catch (error) {
    fail(`${relativePath}: ${error.message}`);
    return null;
  }
}

function frontmatter(markdown) {
  const match = markdown.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  if (!match) return null;

  const fields = {};
  for (const line of match[1].split(/\r?\n/)) {
    const field = line.match(/^([a-z][a-z0-9-]*):\s*(.+)$/i);
    if (field) fields[field[1]] = field[2].replace(/^(["'])(.*)\1$/, "$2").trim();
  }
  return fields;
}

async function walk(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    if (entry.name === ".git") continue;
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...(await walk(fullPath)));
    else files.push(fullPath);
  }
  return files;
}

function safePluginSource(source) {
  return typeof source === "string" && /^\.\/plugins\/[a-z0-9][a-z0-9-]*$/.test(source);
}

async function validateMarketplace() {
  const marketplace = await readJson(".claude-plugin/marketplace.json");
  if (!marketplace) return;

  if (!marketplace.name || !marketplace.description || !marketplace.owner?.name) {
    fail(".claude-plugin/marketplace.json: name, description, and owner.name are required");
  }
  if (!Array.isArray(marketplace.plugins) || marketplace.plugins.length === 0) {
    fail(".claude-plugin/marketplace.json: plugins must be a non-empty array");
    return;
  }

  const names = new Set();
  const declaredSources = new Set();
  for (const plugin of marketplace.plugins) {
    const label = plugin.name || "<unnamed>";
    if (!plugin.name || names.has(plugin.name)) fail(`marketplace: duplicate or missing plugin name: ${label}`);
    names.add(plugin.name);

    if (!safePluginSource(plugin.source)) {
      fail(`marketplace ${label}: source must be a safe ./plugins/<name> path`);
      continue;
    }
    declaredSources.add(plugin.source);

    const sourcePath = path.join(root, plugin.source);
    const sourceStat = await stat(sourcePath).catch(() => null);
    if (!sourceStat?.isDirectory()) {
      fail(`marketplace ${label}: source directory does not exist: ${plugin.source}`);
      continue;
    }

    const manifestPath = path.posix.join(plugin.source, ".claude-plugin/plugin.json");
    const manifest = await readJson(manifestPath);
    if (!manifest) continue;

    for (const field of ["name", "description", "homepage"]) {
      if (plugin[field] !== manifest[field]) fail(`${label}: marketplace and manifest ${field} differ`);
    }
    if (plugin.author?.name !== manifest.author?.name) fail(`${label}: marketplace and manifest author differ`);
    if (!/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/.test(manifest.version || "")) {
      fail(`${label}: manifest version is not valid semver: ${manifest.version || "<missing>"}`);
    }
    for (const field of ["description", "repository", "homepage", "license"]) {
      if (!manifest[field]) fail(`${label}: manifest ${field} is required`);
    }
    if (!(await exists(path.join(sourcePath, "README.md")))) fail(`${label}: plugin README.md is missing`);
  }

  const pluginDirectories = await readdir(path.join(root, "plugins"), { withFileTypes: true });
  for (const entry of pluginDirectories.filter((entry) => entry.isDirectory())) {
    const source = `./plugins/${entry.name}`;
    if (await exists(path.join(root, source, ".claude-plugin/plugin.json")) && !declaredSources.has(source)) {
      fail(`${source}: plugin manifest exists but the plugin is absent from the marketplace`);
    }
  }
}

async function validateFrontmatter(files) {
  for (const file of files) {
    const relative = path.relative(root, file);
    const markdown = await readFile(file, "utf8");
    const fields = frontmatter(markdown);
    if (!fields) {
      fail(`${relative}: missing YAML frontmatter`);
      continue;
    }

    if (relative.endsWith("/SKILL.md")) {
      if (!fields.name) fail(`${relative}: frontmatter name is required`);
      if (!fields.description) fail(`${relative}: frontmatter description is required`);
      const directoryName = path.basename(path.dirname(file));
      if (fields.name && fields.name !== directoryName) {
        fail(`${relative}: skill name must match directory (${directoryName})`);
      }
    } else if (relative.includes(`${path.sep}commands${path.sep}`) && !fields.description) {
      fail(`${relative}: command frontmatter description is required`);
    }
  }
}

async function validateMarkdownLinks(markdownFiles) {
  for (const file of markdownFiles) {
    const relative = path.relative(root, file);
    const markdown = await readFile(file, "utf8");
    const links = markdown.matchAll(/(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+["'][^"']*["'])?\)/g);

    for (const match of links) {
      const href = match[1];
      if (/^(?:https?:|mailto:|#)/i.test(href) || href.includes("${")) continue;
      const targetText = decodeURIComponent(href.split(/[?#]/, 1)[0]);
      if (!targetText) continue;
      const target = path.resolve(path.dirname(file), targetText);
      if (!(await exists(target))) fail(`${relative}: broken local link: ${href}`);
    }
  }
}

const allFiles = await walk(root);
const markdownFiles = allFiles.filter((file) => file.endsWith(".md"));
const componentFiles = markdownFiles.filter(
  (file) => file.endsWith(`${path.sep}SKILL.md`) || file.includes(`${path.sep}commands${path.sep}`),
);

await validateMarketplace();
await validateFrontmatter(componentFiles);
await validateMarkdownLinks(markdownFiles);

if (failures.length > 0) {
  console.error(`Marketplace validation failed with ${failures.length} issue(s):`);
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log("Marketplace, manifests, component frontmatter, and Markdown links are valid.");
