class AppSettings {
  static const String otpBackendUrl = "https://script.google.com/macros/s/AKfycbyZQilpS2ZKsOvHtXwOBFjWnAwgo0ptOXgG00CDRmY-0LSYo5hnZl1wSCBYmda1Cgr1qw/exec";
  static double fontScaleValue = 2.0;
  static double sfxVolumeValue = 40.0;

  static double get textScale {
    return 0.8 + (fontScaleValue * 0.1);
  }

  static double get sfxRatio => sfxVolumeValue / 100.0;
}