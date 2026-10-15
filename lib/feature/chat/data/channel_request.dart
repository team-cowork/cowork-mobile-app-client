import '../domain/enums/channel_type.dart';
import 'channel_view_type.dart';

/// `POST /channels` 요청 본문.
class CreateChannelRequest {
  const CreateChannelRequest({
    required this.teamId,
    required this.name,
    required this.type,
    required this.isPrivate,
  });

  final int teamId;
  final String name;
  final ChannelType type;
  final bool isPrivate;

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'name': name,
    'type': serverTypeOf(type),
    'viewType': viewTypeOf(type),
    'isPrivate': isPrivate,
  };
}
