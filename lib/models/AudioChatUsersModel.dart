import 'package:on_audio_query/on_audio_query.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AudioChatUsersModel extends ParseObject implements ParseCloneable {
  static final String keyTableName = "AudioChatUsers";
  static const String keyRoomPassword = 'password';
  AudioChatUsersModel() : super(keyTableName);
  //static const String keyCurrentlyPlayingSong = 'currentlyPlayingSong';

  AudioChatUsersModel.clone() : this();

  @override
  AudioChatUsersModel clone(Map<String, dynamic> map) =>
      AudioChatUsersModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";
  static final String keyYoutubeId = "youTubeId";
  static final String keyLiveStreaming = "liveStream";
  static final String keyLiveStreamingId = "liveStreamId";

  static final String keyJoinedUser = "joined_user";
  static final String keyJoinedUserId = "joined_user_id";
  static final String keyJoinedUserUID = "joined_user_uid";

  static final String keyCanTalk = "can_talk";

  static final String keyLeftRoom = "left_room";
  static final String keyUserSelfMutedAudioIds = "user_self_muted_audio";

  static final String keyUserMutedByHostIds = "users_muted_by_host_audio";

  static final String keySeatIndex = "co_host_seat_index";

  static final String keyEnabledVideo = "enabled_video";
  static final String keyEnabledAudio = "enabled_audio";
  static final String keyRoomLocked = "room_locked";
  bool get getCurrentPlayingSong => get<bool>('currentPlayingSong') ?? false;
  bool get getPlayingSong => get<bool>('isPlaying') ?? false;

  set setCurrentPlayingSong(bool value) => set<bool>('currentPlayingSong', value);
  set setPlayingSong(bool value) => set<bool>('isPlaying', value);

  String get getCurrentPlayingSongUrl => get<String>('currentPlayingSongUrl') ?? ''; // Adjust the type to String

  set setCurrentPlayingSongUrl(String value) => set<String>('currentPlayingSongUrl', value); // Adjust the type to String

  // static final String keyRoomPassword = "room_password";
  static const String keyAudio = 'audio'; // Add this line

  ParseFileBase? get getAudio => get<ParseFileBase>(keyAudio);

  set setAudio(ParseFileBase audioFile) =>
      set<ParseFileBase>(keyAudio, audioFile);
  bool? get getRoomLocked {
    bool? roomLocked = get<bool>(keyRoomLocked);
    if (roomLocked != null) {
      return roomLocked;
    } else {
      return false;
    }
  }

  String? get getRoomPassword {
    String? roomPassword = get<String>(keyRoomPassword);
    if (roomPassword != null) {
      return roomPassword;
    } else {
      return '';
    }
  }

  void setRoomPassword(String password) {
    set<String>(keyRoomPassword, password);
  }

  set setRoomLocked(bool roomLocked) {
    set<bool>(keyRoomLocked, roomLocked);
  }

  Future<void> lockRoomWithPassword(String password) async {
    try {
      setRoomPassword(password);
      // setRoomLocked(true);
      await save();
      print("Room is now locked with password: $password");
    } catch (e) {
      print("Error locking room: $e");
      rethrow;
    }
  }

  Future<void> unlockRoom() async {
    try {
      setRoomPassword('');
      // setRoomLocked(false);
      await save();
      print("Room is now unlocked");
    } catch (e) {
      print("Error unlocking room: $e");
      rethrow;
    }
  }

  bool? get getEnabledAudio {
    bool? enabledAudio = get<bool>(keyEnabledAudio);
    if (enabledAudio != null) {
      return enabledAudio;
    } else {
      return true;
    }
  }

  // set setCurrentPlayingSong(bool Song) {
  //   set<bool>(keyCurrentlyPlayingSong, Song);
  // }
  //
  // bool? get getCurrentPlayingSong {
  //   bool? enableSong = get<bool>(keyCurrentlyPlayingSong);
  //   if (enableSong != null) {
  //     return enableSong;
  //   } else {
  //     return true;
  //   }
  // }

  void setYoutubeId(String youTubeId) => set<String>(keyYoutubeId, youTubeId);

  String? get getYoutubeId => get<String>(keyYoutubeId);

  set setEnabledAudio(bool enabledAudio) =>
      set<bool>(keyEnabledAudio, enabledAudio);

  bool? get getEnabledVideo {
    bool? enabledVideo = get<bool>(keyEnabledVideo);
    if (enabledVideo != null) {
      return enabledVideo;
    } else {
      return false;
    }
  }

  set setEnabledVideo(bool enabledVideo) =>
      set<bool>(keyEnabledVideo, enabledVideo);

  int? get getSeatIndex => get<int>(keySeatIndex);

  set setSeatIndex(int seatIndex) => set<int>(keySeatIndex, seatIndex);

  List<dynamic>? get getUserMutedByHostIds {
    List<dynamic>? users = get<List<dynamic>>(keyUserMutedByHostIds);
    if (users != null && users.length > 0) {
      return users;
    } else {
      return [];
    }
  }

  set addUserMutedByHostIds(String userId) =>
      setAddUnique(keyUserMutedByHostIds, userId);

  set removeUserMutedByHostIds(String userId) =>
      setRemove(keyUserMutedByHostIds, userId);

  List<dynamic>? get getUserSelfMutedAudioIds {
    List<dynamic>? users = get<List<dynamic>>(keyUserSelfMutedAudioIds);
    if (users != null && users.length > 0) {
      return users;
    } else {
      return [];
    }
  }

  set addUserSelfMutedAudioIds(String userId) =>
      setAddUnique(keyUserSelfMutedAudioIds, userId);

  set removeUserSelfMutedAudioIds(String userId) =>
      setRemove(keyUserSelfMutedAudioIds, userId);

  ParseUser? get joinedUser => get<ParseUser>('joinedUser');
  set joinedUser(ParseUser? value) => set<ParseUser>('joinedUser', value!);

  UserModel? get getJoinedUser => get<UserModel>(keyJoinedUser);

  set setJoinedUser(UserModel author) => set<UserModel>(keyJoinedUser, author);

  removeJoinedUser() => set(keyJoinedUser, null);

  String? get getJoinedUserId => get<String>(keyJoinedUserId);

  set setJoinedUserId(String authorId) =>
      set<String>(keyJoinedUserId, authorId);

  removeJoinedUserId() => set(keyJoinedUserId, null);

  int? get getJoinedUserUid => get<int>(keyJoinedUserUID);

  set setJoinedUserUid(int authorUid) => set<int>(keyJoinedUserUID, authorUid);

  removeJoinedUserUid() => set(keyJoinedUserUID, null);

  LiveStreamingModel? get getLiveStreaming =>
      get<LiveStreamingModel>(keyLiveStreaming);

  set setLiveStreaming(LiveStreamingModel liveStreaming) =>
      set<LiveStreamingModel>(keyLiveStreaming, liveStreaming);

  String? get getLiveStreamingId => get<String>(keyLiveStreamingId);

  set setLiveStreamingId(String liveStreamingId) =>
      set<String>(keyLiveStreamingId, liveStreamingId);

  bool? get getCanUserTalk {
    bool? canTalk = get<bool>(keyCanTalk);
    if (canTalk != null) {
      return canTalk;
    } else {
      return false;
    }
  }

  set setCanUserTalk(bool canTalk) => set<bool>(keyCanTalk, canTalk);

  bool? get getLetTheRoom {
    bool? leftRoom = get<bool>(keyLeftRoom);
    if (leftRoom != null) {
      return leftRoom;
    } else {
      return false;
    }
  }

  set setLetTheRoom(bool leftRoom) => set<bool>(keyLeftRoom, leftRoom);

// void setRoomPassword(String password) {
//   set<String>(keyRoomPassword, password);
// }
// void setRoomLocked(bool roomLocked) {
//   set<bool>(keyRoomLocked, roomLocked);
// }
//   Future<void> lockRoomWithPassword(String password) async {
//     try {
//       setRoomPassword(password);
//       setRoomLocked(true);
//       await save();
//       print("Room is now locked with password: $password");
//     } catch (e) {
//       print("Error locking room: $e");
//       rethrow;
//     }
//
// }
}
