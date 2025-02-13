enum OptionType {
  repostajes,
  mantenimientos,
  facturas;

  factory OptionType.fromString(String type) {
    switch (type) {
      case 'repostajes':
        return OptionType.repostajes;
      case 'mantenimientos':
        return OptionType.mantenimientos;
      case 'facturas':
        return OptionType.facturas;
      default:
        throw ArgumentError('Invalid option type: $type');
    }
  }
}

