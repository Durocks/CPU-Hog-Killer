<h1 align="center">CPU Hog Killer - Magisk Module</h1>

<div align="center">
  <!-- Version -->
    <img src="https://img.shields.io/badge/Version-v1.6-blue.svg?longCache=true&style=popout-square"
      alt="Version" />
  <!-- Last Updated -->
    <img src="https://img.shields.io/badge/Updated-October%2018,%202024-green.svg?longCache=true&style=flat-square"
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
• **Keeps an Eye on CPU Usage**: Monitors running processes and calculates their average CPU usage.<br><br>
• **Auto-Kills Rogue Processes**: If a process consistently uses more CPU than a set threshold, the module will terminate it.<br><br>
• **Improves Battery Life**: Aims to reduce battery drain and heat by keeping resource-heavy apps in check.<br><br>
• **Notifies you about killed processes**: It notifies you when it kills a process, so you can both be kept in the loop about what's going on with your device, and be alerted when an app is constantly restarting on it's own and eating the CPU, so you can take some action, like restricting it's battery usage permissions.

### How does it work?

Let's say a rogue app is using 100% of a CPU in the background, while you're not even using your phone. This magisk module runs a constant non CPU intensive script. Every certain amount of time, it checks if your screen is off, and if it is, it will start monitoring the running processes / apps. First, it will get the top 5 CPU intensive processes / apps, each with their CPU usage. It will give them a certain amount of chances to turn that CPU usage down, while calculating how much CPU they are using on average, and if they don't, after they reach a certain amount of chances, it will check if their average CPU usage is over a pre determined threshold. If it is, the process will be killed, and the user will receive a notification about the CPU intensive process / app that was killed, so they can remove their battery usage permissions.

This way, no mattery what Android phone brand you have, what custom ROM you might have installed, or what firmware version, you can rest assured your phone will run cool, and the battery will not be consumed by background processes / apps.

### FAQ
1. Why does it keep notifying me of a killed process?

    If that happens, then you have yourself a rogue app or process. If it's an app, open it's App Info, and restrict it's battery usage.

2. Does it create a log anywhere, so I can see what it's doing?

    Yes, it does: /sdcard/cpu_hog_killer.log

3. Why is my phone restarting on its own?

    This means the `system_server` process was killed by CPU Hog Killer. This should only happen if it's CPU usage is very high for a long period of time, likely caused by a rogue `thread` hiding behind `system_server`, which isn't normal. My module will kill it so the phone can restart and the CPU usage can (Temporarily) go back to normal. Still, you should investigate why that's happening. You can do so by disabling `CPU Hog Killer` and executing `top -H` in Termux with `su` permissions, to check which malicious threads are hiding behind `system_server`. You might need for them to actually be running, though.

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
