# Smartphone Industry Traps: A Simple IT Solution for Faster Data Transfer

The smartphone industry has matured, but even the latest products in 2024 are filled with USB 2.0 devices. If you accidentally fall prey to screen, processor, memory, or battery technology, how would you breakthrough this massive limitation? This article will take on this challenge and provide a simple IT solution. This solution must be as simple as possible, without requiring a pre-installed runtime environment, and the operation logic should be as close as possible to file transfer over a data cable (MTP).

## Tutorial Difficulty: Medium-High

* Requires some experience with CMD and PowerShell
* Needs modification of Android system app power consumption/electricity management functions
* Requires access to developer options

## Advantages of the Solution

* Saves the cost of a WiFi 6/6E/7 router, yet faster than a router in the way of your computer and phone
* Since FTP transmission does not affect MTP, this solution can achieve simultaneous FTP + MTP or FTP + ADB pull-push line transmission, thereby:
    + Significantly increasing the peak transfer speed of USB 3.0 phones
    + Slightly increasing the peak transfer speed of USB 2.0 phones

## Expected Transfer Speeds

Advertisements claim that WiFi 6 (802.11ax) at 6 GHz offers speeds of up to 10 Gbps / 1250 MBps. However, in reality, the base speed of WiFi 6 at 5 GHz frequency is only 1.2 Gbps / 1200 Mbps / 150 MBps, the mobile phone gets transmission window to talk to your PC, and same in the other way.

According to tests by PCHardware on multiple routers, the maximum speed achieved at 5 GHz was 839 Mbps / 104.9 MBps. It is clear that these speeds are far lower than advertised claims and significantly less than the remaining 250 MBps of USB 3.0, which is dragged down by MTP, but much faster than the 42 MBps of USB 2.0.

Figure: Comparison of the speeds of multiple WiFi 6 routers, source: [PCHardware](https://www.pcmag.com/news/how-fast-is-wi-fi-6)
  - ![PCHardware_WiFi6.png](PCHardware_WiFi6.png)

Therefore, the expected transfer speed is around 100 MBps / 800 Mbps, with a maximum of 150 MBps / 1200 Mbps. It also reflects the extent to which phones without a simple USB 3.0 port are crippled.

### Use Cases

- **α**: Downloading HQ videos to your computer, then transfer the videos to your mobile device for viewing. This generates high sequential read/write demands of several times 16-90 GB per month from the computer to the mobile device.

- **β**: Exporting all photos and recorded footages from the mobile device to a computer, or importing it from a computer for backup, representing high sequential read/write and random read/write demands of 100-400 GB depending on your profession.

- **γ**: During setting up your new smartphones, using recovery tools like TWRP to create "full-system checkpoint" backups, then transferring them to a computer for storage. This generates random and sequential read/write demands of 50-200 GB per month from the mobile device to the computer.

### Prerequisites

* **Compatibility**: The solution must at least support UTF-8 file names
* **Ease-of-use**: The solution must allow for the transfer of more than one file at once.
* **Speed**: Smartphones must have at least UFS 3.0 storage chips.
* **Stability**: The transfer protocol must be highly stable, preferably more stable than MTP.
* **Speed**: Computers should at least support WiFi 6, ideally WiFi 6E or higher.
* **Stability**: The transfer process must ensure proper cooling on the smartphone side to maintain both speed and stability.
* **Speed**: Content creators should use solid-state drives (SSDs) on their computers.

-----

# Steps

To minimize lengthy analysis of transmission speed, this article will present the tutorial steps upfront and analyze them later.

### Overview of the following steps

1. Check your phone's highest supported WiFi specification.
2. Ensure that your computer's motherboard supports the latest WiFi standard and update its wireless network card (and its driver) if necessary.
3. Install [Servers Ultimate](https://play.google.com/store/apps/details?id=com.icecoldapps.serversultimate) on your phone and set up a simple FTP server.
4. Configure your phone's hotspot its maximum supported specifications
5. Configuring your phone's power-saving setting os it doesn't shut your trnasmission down
5. Disable WiFi and mobile data on your phone and create a WiFi 6/802.11ax hotspot.
6. Connect your computer to the phone's hotspot.
7. Download the scripts and run them

**Note:** No additional firewall settings are required on Windows.

### Checking Your Phone and Computer's Highest Supported WiFi Version

Search for your phone's model in a browser and find the "802.11" or "WiFi" specifications on the "Technical Specification / Specs" page.
- "802.11ax", "ax", "WiFi 6" states that your device supports WiFi 6
- "802.11ax+", "axE", "WiFi 6+"，"WiFi 6E" states that your device supports WiFi 6 Extended（basically faster than WiFi 6）
- "802.11be"，"be"，"WiFi 7" states that your device supports WiFi 7

Example images:
- Oneplus Ace 3 WiFi specs: ![check-WiFi-Specs-at-manufacturer.png](check-WiFi-Specs-at-manufacturer.png)
- Oneplus 8 WiFi specs: ![check-WiFi-Specs-at-manufacturer-2.png](check-WiFi-Specs-at-manufacturer-2.png)
- Xiaomi 12 WiFi specs: ![check-WiFi-Specs-at-manufacturer-2.png](check-WiFi-Specs-at-manufacturer-3.png)

Other phones supporting WiFi 6 can be found at:
- Techrankup - List of smartphones with WiFi 6 support: <insert link URL>
- Huawei devices supporting WiFi 6/WiFi 6+: <insert link URL>

Newer Intel platforms have exclusive access to WiFi 7 netcards like BE200NGW and Killer BE1750x. Currently, no WiFi 7 solutions exist for AMD's latest x670/b650 platforms. You can find the latest wireless drivers on the motherboard or laptop manufacturer's website.
