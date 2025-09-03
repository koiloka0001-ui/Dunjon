const fs = require("fs");
const path = require("path");

const SRC = path.join(__dirname, "events.json");
const OUT_DIR = path.join(__dirname, "..", "game-godot", "autoload");
const OUT = path.join(OUT_DIR, "Events.gd");

function toConstName(name){
  return name.toUpperCase().replace(/[^A-Z0-9]+/g, "_");
}

function main() {
  const spec = JSON.parse(fs.readFileSync(SRC, "utf8"));
  if (!spec.events || !Array.isArray(spec.events)) {
    throw new Error("events.json missing 'events' array");
  }
  fs.mkdirSync(OUT_DIR, { recursive: true });

  const lines = [];
  lines.push("# Auto-generated from tools/events.json. Do not edit.\n");
  lines.push("class_name Events");
  lines.push("");

  // String constants
  for (const e of spec.events) {
    const cname = toConstName(e.name);
    lines.push(`const ${cname} = "${e.name}"`);
  }
  lines.push("");

  // Payload dictionary
  lines.push("const PAYLOAD = {");
  spec.events.forEach((e, i) => {
    const comma = i < spec.events.length - 1 ? "," : "";
    const payloadPairs = Object.entries(e.payload || {})
      .map(([k, v]) => `"${k}":"${v}"`)
      .join(", ");
    lines.push(`\t"${e.name}": { ${payloadPairs} }${comma}`);
  });
  lines.push("}");
  lines.push("");

  fs.writeFileSync(OUT, lines.join("\n"), "utf8");
  console.log(`✅ Generated ${path.relative(process.cwd(), OUT)}`);
}

main();
