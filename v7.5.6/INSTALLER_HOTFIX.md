# SMART DICOM Client Windows installer hotfix

The updated ZIP retains the v7.5.5 Tailscale MSI, Brainok Network Setup executable,
and SMART DICOM Client MSI byte for byte. It replaces the launcher and adds
`Configure-Brainok-Tailscale.ps1`.

The launcher now installs Tailscale, starts sign-in when needed, verifies the
Brainok Tailnet, enables Tailscale DNS, checks the server, runs Brainok Network
Setup, and installs the client. Existing authenticated Tailscale accounts are
preserved. A PC connected to a different Tailnet stops with a specific message.

The user may still need to authenticate in the Tailscale browser. A fully
unattended Tailnet join would require a reachable public bootstrap endpoint
that issues a one-time auth key after Brainok installer authentication.

Validation completed on macOS: ZIP extraction test, unchanged binary checksums,
and server health verification. Windows execution still needs a Windows PC.
