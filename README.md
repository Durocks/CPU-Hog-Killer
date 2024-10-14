<h1 align="center">CPU Hog Killer - Magisk Module</h1>

<div align="center">
  <!-- Version -->
    <img src="https://img.shields.io/badge/Version-v1.0-blue.svg?longCache=true&style=popout-square"
      alt="Version" />
  <!-- Last Updated -->
    <img src="https://img.shields.io/badge/Updated-October%2014,%202024-green.svg?longCache=true&style=flat-square"
      alt="_time_stamp_" />
  <!-- Min Magisk -->
    <img src="https://img.shields.io/badge/MinMagisk-24.0-red.svg?longCache=true&style=flat-square"
      alt="_time_stamp_" />
</div>

<div align="center">
  <strong>CPU Hog Killer is a Magisk module designed to monitor CPU usage on your device, automatically identifying and terminating processes that consume excessive CPU resources. This helps improve battery life and overall system performance.</strong>
</div>

<div align="center">
  <h3>
    <a href="https://github.com/Durocks/CPU-Hog-Killer">
      Source Code
    </a>
  </h3>
</div>

### Background
Having a rooted device, I noticed executing the <code>top</code> command sometimes showed rogue processes consuming high amounts of CPU resources. This led to increased heat and battery drain. The **CPU Hog Killer** module was created to automate the detection and termination of these processes, ensuring a more efficient and responsive device.

### What does the module do?
The module continuously monitors CPU usage, calculating the average usage of running processes. If any process exceeds a defined CPU usage threshold, it is automatically terminated, helping to maintain system stability and performance.

### Usage
1. **Installation**:
   - Download the latest version of the `CPU_Hog_Killer.zip` module from the <a href="https://github.com/Durocks/CPU-Hog-Killer/releases/">releases</a> section.
   - Open Magisk Manager and navigate to the **Modules** section.
   - Tap **Install from storage** and select the `CPU_Hog_Killer.zip` file.

2. **Effect**:
   - Once installed, the module will actively monitor CPU usage, terminating any processes that exceed the defined CPU threshold, effectively reducing resource consumption.

3. **Further Configuration**:
   - No additional configuration is required after installation. The module operates automatically.

### Contributions
Contributions are welcome! Feel free to submit issues or pull requests.

### Disclaimer
This module is intended for use on rooted devices and may not function correctly on all devices. Use it at your own risk.
