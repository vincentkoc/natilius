# typed: false
# frozen_string_literal: true

# Homebrew formula for Natilius
# To use: brew tap vincentkoc/tap && brew install natilius
# Or: brew install vincentkoc/tap/natilius

class Natilius < Formula
  desc "Automated one-click Mac developer environment setup"
  homepage "https://github.com/vincentkoc/natilius"
  url "https://github.com/vincentkoc/natilius/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "5cfaf91d3d83526150953039445868a12c46bb0662557b02ad26ef1a043ee8f4"
  license "GPL-3.0-or-later"
  head "https://github.com/vincentkoc/natilius.git", branch: "main"

  # No dependencies required - natilius handles its own deps

  def install
    # Install main script
    bin.install "natilius.sh" => "natilius"

    # Install library files
    (libexec/"lib").install Dir["lib/*.sh"]

    # Install modules
    (libexec/"modules").install Dir["modules/*"]

    # Install profiles
    (libexec/"profiles").install Dir["profiles/*"]

    # Install completions
    bash_completion.install "completions/natilius-completion.bash" => "natilius"
    zsh_completion.install "completions/natilius-completion.zsh" => "_natilius"

    # Install example config
    (share/"natilius").install ".natiliusrc.example"

    # Create wrapper that sets NATILIUS_HOME
    (bin/"natilius").unlink
    (bin/"natilius").write <<~EOS
      #!/bin/bash
      export NATILIUS_HOME="#{libexec}"
      exec "#{libexec}/natilius.sh" "$@"
    EOS
    (bin/"natilius").chmod 0755

    # Install main script to libexec
    libexec.install "natilius.sh"
  end

  def post_install
    # Copy example config to user home if not exists
    user_config = "#{ENV["HOME"]}/.natiliusrc"
    unless File.exist?(user_config)
      ohai "Creating default config at ~/.natiliusrc"
      cp "#{share}/natilius/.natiliusrc.example", user_config
    end
  end

  def caveats
    <<~EOS
      To get started with Natilius:

        natilius --help        # Show available commands
        natilius doctor        # Check system readiness
        natilius --check       # Dry run (preview changes)
        natilius setup         # Run full setup

      Configuration file: ~/.natiliusrc
      Edit this file to customize which modules and packages to install.

      Available profiles:
        natilius --profile minimal   # Quick setup, essentials only
        natilius --profile devops    # Kubernetes, Terraform, cloud tools
        natilius --profile developer # Full dev environment
    EOS
  end

  test do
    assert_match "Natilius", shell_output("#{bin}/natilius version")
  end
end
