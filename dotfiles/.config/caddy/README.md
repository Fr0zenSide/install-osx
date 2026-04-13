# Caddy Local Dev

After installing Caddy, trust the local CA:
```
sudo caddy trust
```

This adds Caddy's self-signed root cert to macOS Keychain.
All *.test domains will show green lock in Safari.
