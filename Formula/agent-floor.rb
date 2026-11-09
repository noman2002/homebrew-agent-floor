class AgentFloor < Formula
  desc "Pixel office for Claude Code agents: one needs-you queue, approvals, replay"
  homepage "https://github.com/noman2002/agent-floor-releases"
  url "https://github.com/noman2002/agent-floor-releases/releases/download/v0.2.3/agent-floor-0.2.3.tar.gz"
  sha256 "09ea82fc489fef6e6444437a45fa0ab747b18744adda265599decfb180f61ac3"
  license :cannot_represent

  depends_on :macos
  # No hard `node` dependency on purpose: it would upgrade the user's Homebrew node.
  # The launcher below finds any working Node >= 22.5 (fnm, nvm, volta, Homebrew, PATH).

  def install
    libexec.install Dir["*"]
    (bin/"agent-floor").write <<~SH
      #!/bin/sh
      # Find a working Node >= 22.5 with node:sqlite. Remember it for `brew services` (no fnm/nvm on its PATH).
      home="${AGENT_FLOOR_HOME:-$HOME/.agent-floor}"
      remembered=""
      [ -r "$home/node-path" ] && remembered="$(cat "$home/node-path")"
      for n in "$AGENT_FLOOR_NODE" "$remembered" "$(command -v node 2>/dev/null)" \
               "${FNM_DIR:-$HOME/.local/share/fnm}/aliases/default/bin/node" \
               "$HOME/Library/Application Support/fnm/aliases/default/bin/node" \
               "$HOME/.volta/bin/node" "#{HOMEBREW_PREFIX}/opt/node/bin/node" /usr/local/bin/node; do
        [ -n "$n" ] && [ -x "$n" ] || continue
        flag=""
        if ! "$n" -e 'require("node:sqlite")' >/dev/null 2>&1; then
          "$n" --experimental-sqlite -e 'require("node:sqlite")' >/dev/null 2>&1 || continue
          flag="--experimental-sqlite"
        fi
        real="$("$n" $flag -p 'process.execPath' 2>/dev/null)"
        if [ -n "$real" ] && [ "$real" != "$remembered" ] && mkdir -p "$home" 2>/dev/null; then
          printf '%s\n' "$real" > "$home/node-path" 2>/dev/null || true
        fi
        exec "$n" $flag --no-warnings=ExperimentalWarning "#{opt_libexec}/dist/cli.js" "$@"
      done
      echo "agent-floor: needs Node.js 22.5 or newer (e.g. 'fnm install --lts' or 'brew install node')." >&2
      exit 1
    SH
  end

  service do
    run [opt_bin/"agent-floor", "start", "--autostart"]
    keep_alive crashed: true
    log_path var/"log/agent-floor.log"
    error_log_path var/"log/agent-floor.log"
  end

  def caveats
    <<~EOS
      First run (pairs this browser):
        agent-floor start --open

      Run at login instead of a terminal:
        brew services start agent-floor
      (use this OR `agent-floor autostart`, not both)

      Pair another device: "Pair phone" in a paired browser,
      or `agent-floor pair` and click Allow in the macOS dialog.

      Claude Code plugin (optional, watches every session):
        /plugin marketplace add #{opt_libexec}/plugin-marketplace
        /plugin install agent-floor@agent-floor

      Guide: #{opt_libexec}/README.md
    EOS
  end

  test do
    assert_match "agent-floor", shell_output("#{bin}/agent-floor --help")
  end
end
