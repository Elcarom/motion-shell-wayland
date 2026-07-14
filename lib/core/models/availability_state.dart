enum AvailabilityState {
  unknown,
  unavailable,
  disabled,
  enabled,
  loading,
  error;

  static AvailabilityState fromName(String? value) {
    for (final AvailabilityState item in values) {
      if (item.name == value) {
        return item;
      }
    }
    return AvailabilityState.unknown;
  }
}
