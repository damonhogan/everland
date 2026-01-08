Tools README

- Screenshot capture: `tools\vice_tests.ps1` supports `-CaptureScreenshots`. It will:
  - Prefer `nircmd.exe` if present (recommended for reliable capture).
  - Fall back to a built-in PowerShell capture routine if `nircmd` is not available (Windows only).

- To enable screenshots when running tests:

```powershell
.\tools\vice_tests.ps1 -Scenario conv -CaptureScreenshots
```

- Installing `nircmd`:
  - Download from: https://www.nirsoft.net/utils/nircmd.html and place `nircmd.exe` on your PATH.
  - Alternatively, install via Chocolatey: `choco install nircmd` (requires elevated prompt).

- Notes:
  - The PowerShell fallback uses `System.Windows.Forms` and `System.Drawing`; it works on Windows PowerShell and may require compatibility libraries on PowerShell 7+.
  - If you prefer ImageMagick or other tools, you can replace the capture block in `tools\vice_tests.ps1` with a call to `magick`/`convert` or any other screenshot utility.
  - ImageMagick: If `magick.exe` is installed, `tools\vice_tests.ps1` will use `magick screenshot: output.png` as a fallback before using the PowerShell capture. Install via:
    - Chocolatey (elevated): `choco install imagemagick`
    - Scoop (user): `scoop install imagemagick`
  - Example: to run the `conv` scenario and save screenshots:

```powershell
.\tools\vice_tests.ps1 -Scenario conv -CaptureScreenshots
```
