# Windows 11 to Linux Mint migration guide

Status: approved plan; operator execution not started

Target: Linux Mint 22.3 Cinnamon 64-bit on desktop PC `ryupol`

Estimated time: 2–3 hours plus downloads

> **Destructive boundary:** installation intentionally erases the internal disk. Do not select **Erase disk and install Linux Mint** until both USB boot checks and every live-session check below pass.

This is an operator guide, not an AI automation script. An agent may explain steps and record sanitized evidence, but the person at the PC must select disks, enter credentials, change firmware settings, and approve erasure.

## Agreed outcome

- Replace Windows completely; no personal files or installed applications need preservation.
- Use two separate 32 GB or larger USB drives. Keep the Windows USB unchanged after verification.
- Use the Mint installer's default layout, without full-disk encryption or Timeshift.
- Keep UEFI Secure Boot enabled. Disable it only after a recorded NVIDIA-module or boot-verification failure.
- Enable automatic desktop login. System changes still require the main account's password.
- Treat this as a normal personal/gaming PC. Docker, Tailscale, and AI Passport stay stopped until the Start AI Passport launcher is used.

## Prepare

1. Buy two distinct 32 GB or larger USB drives. A current example is about ฿415 each, or ฿830 total; prices vary.
2. Have the Windows PC, its linked Microsoft-account login, reliable internet, and another computer available if recovery media must be recreated.
3. Keep a private note outside this repository for the Windows edition and activation status. Never store usernames, passwords, recovery keys, or product keys in project files.

## Gate 1 — record Windows recovery facts

Time: 10 minutes.

1. Open **Settings → System → Activation**. Record privately the exact edition
   (Home or Pro) and whether the digital license is linked to the Microsoft
   account. Microsoft's [activation guide](https://support.microsoft.com/en-us/windows/activate-windows-11305dbc-ef5d-1c08-3ba7-4c7a2cb8f404)
   documents linking and same-edition reactivation.
2. If it is not linked, sign in with the intended Microsoft account and confirm the linked status.
3. Optionally record non-secret hardware facts: CPU, RAM, NVIDIA model, internal disk model/capacity, network adapter, UEFI mode, and Secure Boot state.
4. Do not search for or store a product key unless Windows reports there is no digital license. A same-edition reinstall on the same motherboard can normally skip the key and reactivate online.

Pass: exact edition and linked-license status are recorded privately.

## Gate 2 — create and boot USB 1: Windows installer

Time: 30–60 minutes.

1. Download Microsoft's official Media Creation Tool from the [Windows 11 download page](https://www.microsoft.com/software-download/windows11).
2. Create installation media on USB 1. Creation erases that USB.
3. Boot it through the PC's one-time UEFI boot menu.
4. Confirm the Windows Setup language screen appears. Do **not** begin installation; shut down.
5. Label it **Windows 11 Recovery — do not erase** and retain it unchanged.

This USB reinstalls Windows; it does not back up personal files or applications.
Microsoft's [Recovery Drive guide](https://support.microsoft.com/en-US/Windows/Experience/backup-recovery/recovery-drive)
also says personal files are excluded, which is acceptable because this migration
deliberately permits data erasure.

Pass: USB 1 reaches Windows Setup in UEFI mode and is labelled.

## Gate 3 — create and verify USB 2: Linux Mint

Time: 30–60 minutes.

1. Download the Linux Mint 22.3 Cinnamon 64-bit ISO and its checksum/signature
   files from the [official Linux Mint download page](https://linuxmint.com/download.php).
2. Verify authenticity and integrity with Mint's [ISO verification guide](https://linuxmint-installation-guide.readthedocs.io/en/latest/verify.html). Do not flash an unverified ISO.
3. Flash USB 2 with Etcher using Mint's [bootable media guide](https://linuxmint-installation-guide.readthedocs.io/en/latest/burn.html). Flashing erases that USB.
4. Label it **Linux Mint 22.3 Installer**.

Pass: checksum, signature, and Etcher verification succeed.

## Gate 4 — test the Mint live session

Time: 20 minutes.

1. Leave Secure Boot enabled. Boot USB 2 in UEFI mode and choose normal Linux Mint.
2. Before opening the installer, confirm:
   - Ethernet or Wi-Fi, DNS, and web browsing work;
   - display resolution/refresh, keyboard, mouse, audio, and clock are usable;
   - the internal disk has the expected model and capacity;
   - `lspci` shows the NVIDIA GPU and network adapter.
3. If normal boot fails, record the exact error and try compatibility mode once. Do not disable Secure Boot merely as a guess.
4. Stop if disk identity is ambiguous, input/display is unusable, or neither network path works.

Pass: every check succeeds or an explicitly accepted workaround is recorded.

## Install Linux Mint

Time: 25–45 minutes.

1. Start **Install Linux Mint** and follow Mint's [installation guide](https://linuxmint-installation-guide.readthedocs.io/en/latest/install.html).
   Connect to the network and select multimedia codecs if offered.
2. Identify the internal disk by recorded model and capacity. Choose **Erase disk and install Linux Mint** with the default layout. Do not enable encryption or advanced partitioning.
3. Set computer name `ryupol`. Choose the username and strong password interactively; never copy either into this repository.
4. Enable automatic login. This removes only the desktop-login prompt, not administrative password prompts.
5. Review the erase confirmation, install, reboot, and remove USB 2 only when prompted.

## First-boot health gate

Time: 30–60 minutes.

1. Use Update Manager to refresh and install system updates, then reboot manually.
2. Use [Driver Manager](https://linuxmint-installation-guide.readthedocs.io/en/latest/drivers.html)
   to install its recommended NVIDIA proprietary driver. Never use NVIDIA's
   standalone `.run` installer.
3. If prompted for Machine Owner Key enrollment, complete it on reboot. Keep Secure Boot enabled unless NVIDIA still fails and the exact error proves module-signature verification is the cause.
4. Run:

   ```bash
   hostname
   mokutil --sb-state
   nvidia-smi
   lspci -nnk | sed -n '/VGA\|3D\|Network/,/Kernel modules/p'
   ```

5. Recheck browser/network, audio, display, and one normal desktop application before AI Passport setup.

Expected: hostname is `ryupol`, Secure Boot is enabled, and `nvidia-smi` shows the RTX 3060.

## Prepare the host for AI Passport

Time: 30–60 minutes. Complete this post-install host setup before starting
Slice 0; it is the readiness gate for that slice.

1. Clone the repository into native Linux storage, such as `~/src/ryu-ai-passport`.
2. Install Docker Engine using Docker's [official Ubuntu instructions](https://docs.docker.com/engine/install/ubuntu/). Mint is Ubuntu-based; confirm Docker's current codename mapping before adding the repository.
3. Add only the trusted main account to the `docker` group, then sign out/in. Docker-group membership grants root-equivalent control.
4. Install the NVIDIA Container Toolkit using its [official guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), configure Docker, and prove GPU access with a pinned CUDA container running `nvidia-smi`.
5. Disable automatic Docker startup after verification:

   ```bash
   sudo systemctl disable --now docker.service docker.socket
   systemctl is-enabled docker.service docker.socket
   systemctl is-active docker.service docker.socket
   ```

Expected: both units are disabled and inactive. During early slices Docker may be started manually; the finished project uses password-prompted desktop launchers.

Tailscale is installed and enrolled in Slice 3. It will also be disabled at boot and controlled by the launchers.

## Record completion

Add only sanitized outcomes to `HANDOFF.md`: migration date/Mint version; hostname; Secure Boot, NVIDIA, and Docker GPU-test results; confirmation that USB 1 booted and was retained; and accepted hardware workarounds. Never record credentials, keys, or device identifiers.

Do not begin Slice 0 until all pre-install, first-boot, and host-readiness gates
above pass. Docker and NVIDIA Container Toolkit installation, the pinned GPU
container test, and disabling Docker at boot are post-Mint-install work, but
they are prerequisites—not work within Slice 0.

## Windows rollback

Time: 45–120 minutes plus updates.

1. Boot USB 1 in UEFI mode and install the exact Windows edition recorded in Gate 1.
2. Choose **I don't have a product key**. Delete Linux partitions only after confirming the internal disk, then let Setup recreate its default layout.
3. Go online and sign in with the Microsoft account linked to the license. Check **Settings → System → Activation**.
4. If needed, run Activation Troubleshooter and select the current device. A motherboard replacement or different edition may require separate license resolution.

The digital license restores activation, not files or applications. This plan accepts a clean reinstall.

## Stop conditions

Stop before disk erasure if either USB cannot boot, the Mint ISO cannot be verified, the internal disk is ambiguous, critical live hardware fails, or activation facts are missing. After installation, stop AI Passport setup if the NVIDIA host driver or container GPU test fails; fix that layer before adding application containers.
