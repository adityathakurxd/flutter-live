
# Flutter Live

![livestream with 100ms-V2](https://user-images.githubusercontent.com/53579386/198332974-6df8a8ac-b2dd-4778-81e0-8cd5ac56a14d.png)

An example app on how to integrate 100ms into our Flutter project to build a simple live-streaming application. Using the app, anyone can go live from their mobile device.

## Setup the project on the 100ms dashboard

100ms Live Streaming SDK lets you add two-way interactive live streams to your product.

**📺 Watch the Setup Video here:** [https://youtu.be/GJ94-BaszpQ](https://youtu.be/GJ94-BaszpQ)

## Setup the project locally

Fork the repository and clone the project to your system.

In the `join_service.dart` file, add your `roomId` and replace with your token endpoint (as obtained by the steps above).

```dart
String roomId = "<Your Room ID>";
Uri endPoint = Uri.parse(
        "<Token endpoint>/api/token");
```

## Project Demo
With this done, you’re all set to test your app and go live using your mobile device.

Run the app on an emulator or your own device with USB Debugging enabled and click on the ‘Go Live!’ button.

### To view the live stream:
-   Return to the 100ms dashboard.
-   Using the side navigation go to the rooms, and click on the room used (in our case the room name was ‘flutter’).
-   Click on ‘Join Room’ and copy the link next to the Hls-Viewer role.
-   Paste the link in the browser and wait for the stream to start!

**📺 Watch the Project Demo here:** [https://youtu.be/Z6dCaR7e_6E](https://youtu.be/Z6dCaR7e_6E)

## Conclusion
Read the complete guide here: https://www.100ms.live/blog/flutter-streaming. 

Start by exploring the [Interactive Live Streaming docs](https://www.100ms.live/docs/flutter/v2/foundation/live-streaming).

Have a question? Ask the team on Discord [here](https://discord.com/invite/kGdmszyzq2).

