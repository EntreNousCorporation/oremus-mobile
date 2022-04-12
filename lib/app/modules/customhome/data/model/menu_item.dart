class MenuItem {
  int? code;
  String? libelle;
  String? icon;
  bool? isSelected = false;
  bool isVisible;

  MenuItem({
    this.code,
    this.libelle,
    this.icon,
    this.isSelected,
    this.isVisible = true,
  });
}