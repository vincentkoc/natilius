# VHS Tape - Natilius Demo
# Run: cd docs/assets && vhs demo.tape
# Output: demo.gif
#
# Most commands run live, only brew install and actual setup are simulated

Output demo.gif

Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 50ms

# Start clean
Hide
Type "clear"
Enter
Show
Sleep 500ms

# Simulated: Install via Homebrew (we don't actually install)
Type "brew install vincentkoc/tap/natilius"
Enter
Sleep 300ms
Hide
Type `echo "==> Tapping vincentkoc/tap"; sleep 0.2; echo "==> Downloading natilius"; sleep 0.2; echo "==> Installing natilius"; sleep 0.2; echo "🍺 natilius was successfully installed!"`
Enter
Show
Sleep 1.5s

Hide
Type "clear"
Enter
Show
Sleep 300ms

# Live: Show version
Type "natilius version"
Enter
Sleep 2s

Hide
Type "clear"
Enter
Show
Sleep 300ms

# Live: Show doctor
Type "natilius doctor"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show
Sleep 300ms

# Live: Show profiles
Type "natilius profiles"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show
Sleep 300ms

# Live: Show modules
Type "natilius modules"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show
Sleep 300ms

# Live: Dry run with profile
Type "natilius --profile devops setup --check"
Enter
Sleep 4s

Hide
Type "clear"
Enter
Show
Sleep 300ms

# Simulated: Actual setup (we don't run real setup)
Type "natilius --profile devops setup"
Enter
Sleep 300ms
Hide
Type "bash ./demo-setup.sh"
Enter
Show
Sleep 3s
