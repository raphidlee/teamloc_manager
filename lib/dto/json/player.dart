class Player {
  MemberInfo memberInfo;
  int lineColor;
  String status;
  Player(this.memberInfo, this.lineColor, [this.status = "InPlay"]);
}

class MemberInfo {
  String id;
  String nickName;
  MemberInfo(this.id, this.nickName);
}
