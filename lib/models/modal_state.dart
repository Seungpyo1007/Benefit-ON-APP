class ModalState {
  final bool isOpen;
  final String type;
  final dynamic data;

  ModalState({
    required this.isOpen,
    required this.type,
    this.data,
  });
} 