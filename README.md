<h1 align="center">OnePlus 12 System Server Mods - Magisk Module</h1>

<div align="center">
  <!-- Version -->
    <img src="https://img.shields.io/badge/Version-v1.0-blue.svg?longCache=true&style=popout-square"
      alt="Version" />
  <!-- Last Updated -->
    <img src="https://img.shields.io/badge/Updated-October%208,%202024-green.svg?longCache=true&style=flat-square"
      alt="_time_stamp_" />
  <!-- Min Magisk -->
    <img src="https://img.shields.io/badge/MinMagisk-24.0-red.svg?longCache=true&style=flat-square"
      alt="_time_stamp_" />
</div>

<div align="center">
  <strong>OnePlus 12 System Server Mods is a Magisk module designed for the OnePlus 12 that disables specific system server threads and subprocesses, such as <code>osense</code>, which are known to consume high amounts of CPU resources. This helps optimize battery life and enhance overall system performance.</strong>
</div>

<div align="center">
  <h3>
    <a href="https://github.com/Durocks/Oneplus-12-System-Server-Mods">
      Source Code
    </a>
  </h3>
</div>

### Background
Having a rooted OnePlus 12, I noticed executing the <code>top</code> command sometimes showed a constant 40-100% usage from the <code>system_server</code> main process. I therefore executed <code>top -H</code> to see what specific thread was causing the high CPU usage, and it turned out to be a thread called <code>osense.compress</code>, which according to the very little information I found, is a OnePlus process related to memory compression and processes management. I was able to stop the process by rebooting or killing <code>system_server</code> (Which of course triggered a System UI restart), but after a while, the CPU usage was back to 40-100%.

### What does the module do?
Simple, it modifies the <code>init.rc</code> file under <code>/system/etc/init/hw/</code>, commenting the lines that start the <code>osense</code> process. I still need some testing to be sure it's actually managing to stop the process. So far, I haven't seen it start again, and the CPU usage has been normal (Closer to 12%) when idle.

### Usage
1. **Installation**:
   - Download the latest version of the `OnePlus.12.System.Server.Mods` module zip file from the <a href="https://github.com/Durocks/Oneplus-12-System-Server-Mods/releases/">releases</a> section.
   - Open Magisk Manager and navigate to the **Modules** section.
   - Tap **Install from storage** and select the `OnePlus.12.System.Server.Mods.zip` file.

2. **Effect**:
   - Once installed, the module will disable resource-heavy system server threads to reduce CPU usage, helping to save battery and improve device responsiveness.

3. **Further Configuration**:
   - No additional configuration is required after installation. The module is designed to work out of the box.

### Contributions
Contributions are welcome! Feel free to submit issues or pull requests.

### Disclaimer
This module is intended for use with the OnePlus 12 and may not work properly on other devices. Use it at your own risk.
