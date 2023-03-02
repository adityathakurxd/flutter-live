import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../services/sdk_initializer.dart';

class UserDataStore extends ChangeNotifier
    implements HMSUpdateListener, HMSActionResultListener {
  HMSVideoTrack? remoteVideoTrack;
  HMSTrack? localAudioTrack;
  HMSVideoTrack? localTrack;
  bool _disposed = false;
  late HMSPeer localPeer;
  String? streamURL;
  bool isRoomEnded = false;
  bool isLive = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  void onError({required HMSException error}) {}

  void leaveRoom() async {

    //Checking whether the peer has permission to stop HLS
    if ((localPeer.role.permissions.hlsStreaming ?? false) && isLive) {
      SdkInitializer.hmssdk.stopHlsStreaming(hmsActionResultListener: this);
    }

    //Calling leave method to leave the room
    SdkInitializer.hmssdk.leave(hmsActionResultListener: this);
  }

  void startHLSStreaming(){
    //Checking whether the peer has permission to stop HLS
    if (localPeer.role.permissions.hlsStreaming ?? false) {
      SdkInitializer.hmssdk.startHlsStreaming(hmsActionResultListener: this);
    }
  }
  @override
  void onJoin({required HMSRoom room}) {
    for (HMSPeer each in room.peers!) {
      if (each.isLocal) {
        localPeer = each;
        break;
      }
    }

    isLive = room.hmshlsStreamingState?.running ?? false;
    if ((localPeer.role.permissions.hlsStreaming??false) && !isLive) {
      SdkInitializer.hmssdk.startHlsStreaming(hmsActionResultListener: this);
    }
    if (isLive) {
      String? hlsm3u8Url = room.hmshlsStreamingState?.variants[0]?.hlsStreamUrl;
      streamURL = hlsm3u8Url;
    }
    notifyListeners();
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        break;
      case HMSPeerUpdate.peerLeft:
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        break;
    }
    notifyListeners();
  }

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    isLive = room.hmshlsStreamingState?.running ?? false;
    switch (update) {
      case HMSRoomUpdate.hlsStreamingStateUpdated:
        if (isLive) {
          String? hlsm3u8Url =
              room.hmshlsStreamingState?.variants[0]?.hlsStreamUrl;
          streamURL = hlsm3u8Url;
          notifyListeners();
        }
        break;
    }
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    switch (trackUpdate) {
      case HMSTrackUpdate.trackAdded:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (peer.isLocal) localAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (peer.isLocal) {
            localTrack = track as HMSVideoTrack; 
          } else {
            remoteVideoTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackRemoved:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (peer.isLocal) localAudioTrack = null;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (peer.isLocal) {
            localTrack = null;
          } else {
            remoteVideoTrack = null;
          }
        }
        break;
      case HMSTrackUpdate.trackMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (peer.isLocal) localAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (peer.isLocal) {
            localTrack = track as HMSVideoTrack;
          } else {
             remoteVideoTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackUnMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (peer.isLocal) localAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (peer.isLocal) {
            localTrack = track as HMSVideoTrack;
          } else {
            remoteVideoTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackDescriptionChanged:
        break;
      case HMSTrackUpdate.trackDegraded:
        break;
      case HMSTrackUpdate.trackRestored:
        break;
      case HMSTrackUpdate.defaultUpdate:
        break;
    }
    notifyListeners();
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  void startListen() {
    SdkInitializer.hmssdk.addUpdateListener(listener: this);
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {
    // TODO: implement onAudioDeviceChanged
  }

  @override
  void onHMSError({required HMSException error}) {
    // TODO: implement onHMSError
  }

  @override
  void onException(
      {required HMSActionResultListenerMethod methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        print("Leave room error ${hmsException.message}");
        break;
      case HMSActionResultListenerMethod.hlsStreamingStarted:
        print("HLS Stream start error ${hmsException.message}");
        break;

      case HMSActionResultListenerMethod.hlsStreamingStopped:
        print("HLS Stream stop error ${hmsException.message}");
        break;

      case HMSActionResultListenerMethod.startAudioShare:
        print("Audio share error ${hmsException.message}");
        break;
      case HMSActionResultListenerMethod.switchCamera:
        print("Switch camera error ${hmsException.message}");
        break;
    }
  }

  @override
  void onSuccess(
      {required HMSActionResultListenerMethod methodType,
      Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.hlsStreamingStarted:
        //If start HLS streaming call is successful, you'll get an update in onRoomUpdate
        //Documentation: https://www.100ms.live/docs/flutter/v2/how--to-guides/record-and-live-stream/hls#how-to-display-hls-stream-and-get-hls-state-in-room
        print("HLS Stream started successfully");
        break;

      case HMSActionResultListenerMethod.hlsStreamingStopped:
        isLive = false;
        print("HLS Stream stopped successfully");
        break;

      case HMSActionResultListenerMethod.leave:
        isRoomEnded = true;
        notifyListeners();
        print("Room left successfully");
        break;
    }
  }
}
