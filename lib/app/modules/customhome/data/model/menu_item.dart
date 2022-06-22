class MenusItem {
  int? code;
  String? libelle;
  String? icon;
  bool? isSelected = false;
  bool isVisible;

  MenusItem({
    this.code,
    this.libelle,
    this.icon,
    this.isSelected,
    this.isVisible = true,
  });
}