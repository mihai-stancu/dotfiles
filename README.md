# dotfiles

Bootstrap a fresh Ubuntu install:

```bash
curl -fsSL https://github.com/curatorium/steward/releases/latest/download/steward \
	-o /usr/local/bin/steward && chmod +x /usr/local/bin/steward

tmp="$(mktemp -d)"
curl -fsSL https://github.com/mihai-stancu/dotfiles/archive/refs/heads/main.tar.gz \
	| tar -xz -C "$tmp" --strip-components=1

for src in "$tmp"/.* "$tmp"/[A-Z]*; do
	name="$(basename "$src")"
	[[ -e "$src" && "$name" != "." && "$name" != ".." ]] || continue
	[ -d "$src" ] && cp -r "$src" ~/"$name" || cp "$src" ~/"$name"
done
[ -d "$tmp/.config" ] && mkdir -p ~/.config && cp -r "$tmp/.config"/* ~/.config/
rm -rf "$tmp"

steward ~/Stewardfile
```
