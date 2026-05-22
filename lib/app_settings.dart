class AppSettings {
  static const String otpBackendUrl = "https://script.google.com/macros/s/AKfycbxekgPLE6FcZ2d0hG8WJ5WjslHAHoJX6mB9zPcQ1-AZ2gdv6ObEvGNg33gcFqKQIb4L3g/exec";
  static double fontScaleValue = 2.0;
  static double sfxVolumeValue = 40.0;

  static double get textScale {
    return 0.8 + (fontScaleValue * 0.1);
  }

  static double get sfxRatio => sfxVolumeValue / 100.0;
}