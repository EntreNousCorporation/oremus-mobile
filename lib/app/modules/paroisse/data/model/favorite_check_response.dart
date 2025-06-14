class FavoriteCheckResponse {
  int? identifier;
  bool? isUserFavorite;

  FavoriteCheckResponse({this.identifier, this.isUserFavorite});

  FavoriteCheckResponse.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    isUserFavorite = json['isUserFavorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['isUserFavorite'] = isUserFavorite;
    return data;
  }
}