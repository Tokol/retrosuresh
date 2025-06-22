import 'package:web/web.dart' as web;
import 'dart:js' as js;

class WebDeviceInfo {
  static Future<Map<String, dynamic>> getAllDetails() async {
    final nav = web.window.navigator;
    final screen = web.window.screen;
    final ua = nav.userAgent ?? '';

    return {
      'device': _getDeviceDetails(ua),
      'os': _getOSDetails(ua),
      'browser': _getBrowserDetails(ua),
      'screen': {
        'resolution': '${screen.width}×${screen.height}',
        'pixelRatio': web.window.devicePixelRatio,
        'colorDepth': '${screen.colorDepth} bits',
        'orientation': _getScreenOrientation(),
      },
      'hardware': await _getHardwareInfo(ua),
      'network': _getNetworkInfo(),
      'battery': await _getBatteryStatus(),
      'platform': {
        'touchSupport': _getTouchSupport(),
        'language': nav.language ?? 'Unknown',
      }
    };
  }

  static Map<String, dynamic> _getDeviceDetails(String ua) {
    // Apple Devices
    if (ua.contains('Macintosh') && ua.contains('Apple')) {
      final chipInfo = _getAppleChipInfo(ua);
      return {
        'manufacturer': 'Apple',
        'model': _detectMacModel(ua) ?? 'Mac',
        'type': 'Desktop/Laptop',
        'chip': chipInfo['type'],
        'chipModel': chipInfo['model'],
        'year': _getDeviceYear(ua),
        'isRetina': _checkRetinaDisplay(),
      };
    }

    // iPhone
    if (ua.contains('iPhone')) {
      return {
        'manufacturer': 'Apple',
        'model': _getIPhoneModel(ua),
        'type': 'Mobile',
        'chip': 'Apple A-series',
        'year': _getDeviceYear(ua),
      };
    }

    // iPad
    if (ua.contains('iPad')) {
      return {
        'manufacturer': 'Apple',
        'model': _getIPadModel(ua),
        'type': 'Tablet',
        'chip': _getIPadChip(ua),
        'year': _getDeviceYear(ua),
      };
    }


    if (ua.contains('Android')) {
      return _getAndroidDeviceDetails(ua);
    }


    // Windows/Linux PC
    return {
      'manufacturer': _getPCManufacturer(ua),
      'model': 'PC',
      'type': 'Desktop',
      'chip': _getPCChipArchitecture(ua),
    };
  }



  static Map<String, dynamic> _getAndroidDeviceDetails(String ua) {
    // Default values for unknown Android devices
    var result = {
      'manufacturer': 'Unknown Android Manufacturer',
      'model': 'Android Device',
      'type': 'Mobile',
      'chip': 'Unknown',
    };

    // Samsung Galaxy devices
    if (ua.contains('SM-')) {
      result['manufacturer'] = 'Samsung';
      result['model'] = 'Galaxy ${ua.split('SM-')[1].split(' ')[0]}';
      result['chip'] = 'Exynos/Snapdragon';
    }
    // Google Pixel devices
    else if (ua.contains('Pixel')) {
      result['manufacturer'] = 'Google';
      result['model'] = _getPixelModel(ua);
      result['chip'] = 'Google Tensor';
    }
    // Xiaomi devices
    else if (ua.contains('Mi ') || ua.contains('Redmi ') || ua.contains('POCO')) {
      result['manufacturer'] = 'Xiaomi';
      result['model'] = _getXiaomiModel(ua);
      result['chip'] = 'Snapdragon/Mediatek';
    }
    // OnePlus devices
    else if (ua.contains('ONEPLUS')) {
      result['manufacturer'] = 'OnePlus';
      result['model'] = _getOnePlusModel(ua);
      result['chip'] = 'Snapdragon';
    }
    // Oppo devices
    else if (ua.contains('CPH') || ua.contains('OPPO')) {
      result['manufacturer'] = 'Oppo';
      result['model'] = _getOppoModel(ua);
      result['chip'] = 'Snapdragon/Mediatek';
    }
    // Vivo devices
    else if (ua.contains('Vivo') || ua.contains('vivo')) {
      result['manufacturer'] = 'Vivo';
      result['model'] = _getVivoModel(ua);
      result['chip'] = 'Snapdragon/Mediatek';
    }
    // Huawei devices
    else if (ua.contains('Huawei') || ua.contains('HUAWEI')) {
      result['manufacturer'] = 'Huawei';
      result['model'] = _getHuaweiModel(ua);
      result['chip'] = 'Kirin/Snapdragon';
    }
    // Realme devices
    else if (ua.contains('RMX')) {
      result['manufacturer'] = 'Realme';
      result['model'] = _getRealmeModel(ua);
      result['chip'] = 'Snapdragon/Mediatek';
    }
    // Motorola devices
    else if (ua.contains('Moto') || ua.contains('XT')) {
      result['manufacturer'] = 'Motorola';
      result['model'] = _getMotorolaModel(ua);
      result['chip'] = 'Snapdragon';
    }
    // Sony Xperia devices
    else if (ua.contains('XQ-') || ua.contains('Sony')) {
      result['manufacturer'] = 'Sony';
      result['model'] = _getSonyModel(ua);
      result['chip'] = 'Snapdragon';
    }
    // Asus devices
    else if (ua.contains('ASUS') || ua.contains('ZenFone')) {
      result['manufacturer'] = 'Asus';
      result['model'] = _getAsusModel(ua);
      result['chip'] = 'Snapdragon';
    }
    // Nokia devices
    else if (ua.contains('Nokia')) {
      result['manufacturer'] = 'Nokia';
      result['model'] = _getNokiaModel(ua);
      result['chip'] = 'Snapdragon';
    }
    // LG devices
    else if (ua.contains('LM-') || ua.contains('LG')) {
      result['manufacturer'] = 'LG';
      result['model'] = _getLGModel(ua);
      result['chip'] = 'Snapdragon';
    }

    // Try to extract model number from Build string as fallback
    if (result['model'] == 'Android Device') {
      final modelMatch = RegExp(r'Build/([a-zA-Z0-9]+)').firstMatch(ua);
      if (modelMatch != null) {
        result['model'] = modelMatch.group(1)!;
      }
    }

    return result;
  }

// Helper methods for specific manufacturers
  static String _getXiaomiModel(String ua) {
    if (ua.contains('Mi ')) {
      final modelMatch = RegExp(r'Mi (\d+)').firstMatch(ua);
      return modelMatch != null ? 'Mi ${modelMatch.group(1)}' : 'Mi Series';
    }
    if (ua.contains('Redmi ')) {
      final modelMatch = RegExp(r'Redmi (\w+)').firstMatch(ua);
      return modelMatch != null ? 'Redmi ${modelMatch.group(1)}' : 'Redmi Series';
    }
    if (ua.contains('POCO')) {
      final modelMatch = RegExp(r'POCO (\w+)').firstMatch(ua);
      return modelMatch != null ? 'POCO ${modelMatch.group(1)}' : 'POCO Series';
    }
    return 'Xiaomi Device';
  }

  static String _getOnePlusModel(String ua) {
    final modelMatch = RegExp(r'ONEPLUS (\w+)').firstMatch(ua);
    return modelMatch != null ? 'OnePlus ${modelMatch.group(1)}' : 'OnePlus Device';
  }

  static String _getOppoModel(String ua) {
    final modelMatch = RegExp(r'(CPH\d+)').firstMatch(ua);
    return modelMatch != null ? 'Oppo ${modelMatch.group(1)}' : 'Oppo Device';
  }

  static String _getVivoModel(String ua) {
    final modelMatch = RegExp(r'vivo (\w+)').firstMatch(ua);
    return modelMatch != null ? 'Vivo ${modelMatch.group(1)}' : 'Vivo Device';
  }

  static String _getHuaweiModel(String ua) {
    if (ua.contains('P ')) {
      final modelMatch = RegExp(r'P (\d+)').firstMatch(ua);
      return modelMatch != null ? 'P${modelMatch.group(1)}' : 'P Series';
    }
    if (ua.contains('Mate ')) {
      final modelMatch = RegExp(r'Mate (\d+)').firstMatch(ua);
      return modelMatch != null ? 'Mate ${modelMatch.group(1)}' : 'Mate Series';
    }
    if (ua.contains('Nova ')) {
      final modelMatch = RegExp(r'Nova (\w+)').firstMatch(ua);
      return modelMatch != null ? 'Nova ${modelMatch.group(1)}' : 'Nova Series';
    }
    return 'Huawei Device';
  }

  static String _getRealmeModel(String ua) {
    final modelMatch = RegExp(r'(RMX\d+)').firstMatch(ua);
    return modelMatch != null ? 'Realme ${modelMatch.group(1)}' : 'Realme Device';
  }

  static String _getMotorolaModel(String ua) {
    final modelMatch = RegExp(r'(XT\d+)').firstMatch(ua);
    return modelMatch != null ? 'Moto ${modelMatch.group(1)}' : 'Moto Device';
  }

  static String _getSonyModel(String ua) {
    final modelMatch = RegExp(r'(XQ-\w+)').firstMatch(ua);
    return modelMatch != null ? 'Xperia ${modelMatch.group(1)}' : 'Xperia Device';
  }

  static String _getAsusModel(String ua) {
    if (ua.contains('ZenFone')) {
      final modelMatch = RegExp(r'ZenFone (\w+)').firstMatch(ua);
      return modelMatch != null ? 'ZenFone ${modelMatch.group(1)}' : 'ZenFone';
    }
    return 'Asus Device';
  }

  static String _getNokiaModel(String ua) {
    final modelMatch = RegExp(r'Nokia (\w+)').firstMatch(ua);
    return modelMatch != null ? 'Nokia ${modelMatch.group(1)}' : 'Nokia Device';
  }

  static String _getLGModel(String ua) {
    final modelMatch = RegExp(r'(LM-\w+)').firstMatch(ua);
    return modelMatch != null ? 'LG ${modelMatch.group(1)}' : 'LG Device';
  }

  static Map<String, String> _getAppleChipInfo(String ua) {
    final chipMatch = RegExp(r'(M[1-4]|A\d+)(?: Max| Pro| Ultra| Bionic)?').firstMatch(ua);
    return {
      'type': chipMatch != null ? 'Apple Silicon' : 'Intel',
      'model': chipMatch?.group(1) ?? 'Unknown',
    };
  }

  static String? _detectMacModel(String ua) {
    if (ua.contains('MacBookAir')) return 'MacBook Air';
    if (ua.contains('MacBookPro')) return 'MacBook Pro';
    if (ua.contains('MacBook')) return 'MacBook';
    if (ua.contains('Macmini')) return 'Mac Mini';
    if (ua.contains('iMac')) return 'iMac';
    if (ua.contains('MacPro')) return 'Mac Pro';
    return null;
  }

  static String _getIPhoneModel(String ua) {
    final modelMatch = RegExp(r'iPhone(\d+),').firstMatch(ua);
    return modelMatch != null ? 'iPhone ${modelMatch.group(1)}' : 'iPhone';
  }

  static String _getIPadModel(String ua) {
    final modelMatch = RegExp(r'iPad(\d+),').firstMatch(ua);
    return modelMatch != null ? 'iPad ${modelMatch.group(1)}' : 'iPad';
  }

  static String _getIPadChip(String ua) {
    return ua.contains('Mac') ? 'M-series' : 'A-series';
  }

  static String _getPixelModel(String ua) {
    final modelMatch = RegExp(r'Pixel (\d+)').firstMatch(ua);
    return modelMatch != null ? 'Pixel ${modelMatch.group(1)}' : 'Pixel';
  }

  static String _getPCManufacturer(String ua) {
    if (ua.contains('Surface')) return 'Microsoft';
    if (ua.contains('Xbox')) return 'Microsoft';
    if (ua.contains('PlayStation')) return 'Sony';
    if (ua.contains('Linux')) return 'Linux PC';
    if (ua.contains('Chromebook')) return 'Google';
    return 'Unknown Manufacturer';
  }

  static String _getPCChipArchitecture(String ua) {
    if (ua.contains('ARM64')) return 'ARM 64-bit';
    if (ua.contains('ARM')) return 'ARM';
    if (ua.contains('Win64') || ua.contains('x64')) return 'x64';
    if (ua.contains('x86') || ua.contains('i686')) return 'x86';
    return 'Unknown';
  }

  static String? _getDeviceYear(String ua) {
    final yearMatch = RegExp(r'(20\d{2})').firstMatch(ua);
    return yearMatch?.group(1);
  }

  static bool _checkRetinaDisplay() {
    try {
      return web.window.devicePixelRatio > 1;
    } catch (e) {
      return false;
    }
  }

  static String _getScreenOrientation() {
    try {
      return web.window.screen.orientation?.type ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  static Future<Map<String, dynamic>> _getHardwareInfo(String ua) async {
    final nav = web.window.navigator;
    return {
      'cpu': {
        'cores': nav.hardwareConcurrency ?? 0,
        'architecture': _getCpuArchitecture(ua),
      },
      'memory': '${nav.deviceMemory ?? 0}GB',
      'gpu': await _getGpuInfo(),
      'storage': _getStorageInfo(),
    };
  }

  static String _getCpuArchitecture(String ua) {
    if (ua.contains('M1') || ua.contains('M2') || ua.contains('M3') || ua.contains('M4')) {
      return 'Apple Silicon';
    }
    if (ua.contains('ARM')) return 'ARM';
    if (ua.contains('x64') || ua.contains('Win64')) return 'x64';
    if (ua.contains('x86')) return 'x86';
    return 'Unknown';
  }

  static Future<Map<String, dynamic>> _getGpuInfo() async {
    try {
      final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
      final gl = canvas.getContext('webgl') ?? canvas.getContext('experimental-webgl');

      if (gl == null) return {'error': 'WebGL not available'};

      final basicInfo = {
        'vendor': _getWebGLParameter(gl, 'VENDOR'),
        'renderer': _getWebGLParameter(gl, 'RENDERER'),
      };

      try {
        final debugInfo = js.context.callMethod('eval', [
          'gl.getExtension("WEBGL_debug_renderer_info")'
        ]);

        if (debugInfo != null) {
          return {
            ...basicInfo,
            'unmasked_vendor': _getWebGLParameter(gl, debugInfo['UNMASKED_VENDOR_WEBGL']),
            'unmasked_renderer': _getWebGLParameter(gl, debugInfo['UNMASKED_RENDERER_WEBGL']),
          };
        }
      } catch (e) {
        return basicInfo;
      }

      return basicInfo;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Map<String, dynamic> _getStorageInfo() {
    try {
      return {
        'estimatedStorage': _estimateStorage(),
        'storageApi': _checkStorageApi(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static String _estimateStorage() {
    try {
      if (js.context.hasProperty('navigator') &&
          js.context['navigator'].hasProperty('deviceMemory')) {
        final memory = js.context['navigator']['deviceMemory'];
        return memory != null ? '${memory}GB (estimated)' : 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  static String _checkStorageApi() {
    try {
      return js.context.callMethod('eval', [
        "'storage' in navigator && 'estimate' in navigator.storage"
      ]) ? 'Available' : 'Not available';
    } catch (e) {
      return 'Unknown';
    }
  }

  static String _getWebGLParameter(web.RenderingContext gl, dynamic param) {
    try {
      final result = js.context.callMethod('eval', [
        param is String ? 'gl.getParameter(gl.$param)' : 'gl.getParameter($param)'
      ]);
      return result?.toString() ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  static Map<String, dynamic> _getNetworkInfo() {
    try {
      final connection = js.context['navigator']['connection'];
      if (connection != null) {
        return {
          'type': connection['type'] ?? 'Unknown',
          'effectiveType': connection['effectiveType'] ?? 'Unknown',
          'downlink': connection['downlink'] ?? 'Unknown',
          'rtt': connection['rtt'] ?? 'Unknown',
          'saveData': connection['saveData'] ?? false,
        };
      }
      return {'status': 'Connection API not available'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _getBatteryStatus() async {
    try {
      final battery = await js.context['navigator']['getBattery']();
      return {
        'level': '${(battery['level'] * 100).round()}%',
        'charging': battery['charging'],
        'chargingTime': battery['chargingTime'] != double.infinity
            ? '${battery['chargingTime']} seconds'
            : 'Not charging',
      };
    } catch (e) {
      return {'error': 'Battery API not supported'};
    }
  }

  static bool _getTouchSupport() {
    try {
      return web.window.navigator.maxTouchPoints > 0;
    } catch (e) {
      return false;
    }
  }

  static Map<String, String> _getOSDetails(String ua) {
    // Windows Client Versions
    final windowsVersion = {
      'Windows NT 11.0': '11',
      'Windows NT 10.0': ua.contains('Touch') ? '10 (Touch)' : '10',
      'Windows NT 6.3': '8.1',
      'Windows NT 6.2': '8',
      'Windows NT 6.1': '7',
      'Windows NT 6.0': 'Vista',
      'Windows NT 5.2': 'XP x64/Server 2003',
      'Windows NT 5.1': 'XP',
      'Windows NT 5.0': '2000',
      'Windows NT 4.0': 'NT 4.0',
      'Windows 98': '98',
      'Windows 95': '95',
      'Windows CE': 'CE',
    };

    // Check for client versions first
    for (final entry in windowsVersion.entries) {
      if (ua.contains(entry.key)) {
        return {
          'name': 'Windows',
          'version': entry.value,
          'edition': _getWindowsEdition(ua),
        };
      }
    }

    // Windows Server Versions
    final serverVersions = {
      'Windows Server 2008': '2008',
      'Windows Server 2012': '2012',
      'Windows Server 2016': '2016',
      'Windows Server 2019': '2019',
      'Windows Server 2022': '2022',
      'Windows Server 2025': '2025',
    };

    for (final entry in serverVersions.entries) {
      if (ua.contains(entry.key)) {
        return {
          'name': 'Windows Server',
          'version': entry.value,
          'edition': _getWindowsEdition(ua),
        };
      }
    }

    // Special Windows variants
    if (ua.contains('Windows Phone')) {
      return {
        'name': 'Windows Phone',
        'version': _getWindowsPhoneVersion(ua),
      };
    }

    if (ua.contains('Xbox')) {
      return {
        'name': 'Xbox OS',
        'version': _getXboxVersion(ua),
      };
    }

    // Mac OS detection
    if (ua.contains('Mac OS X')) {
      final version = RegExp(r'Mac OS X (\d+_\d+)').firstMatch(ua)?.group(1);
      return {
        'name': 'macOS',
        'version': version?.replaceAll('_', '.') ?? 'Unknown',
      };
    }

    // Android/Linux detection
    if (ua.contains('Linux')) {
      return ua.contains('Android')
          ? {'name': 'Android', 'version': _getAndroidVersion(ua)}
          : {'name': 'Linux', 'version': _getLinuxDistro(ua)};
    }

    // Chrome OS detection
    if (ua.contains('CrOS')) {
      return {
        'name': 'Chrome OS',
        'version': _getChromeOSVersion(ua),
      };
    }

    return {'name': 'Unknown', 'version': 'Unknown'};
  }

  static String _getWindowsEdition(String ua) {
    if (ua.contains('Win')) {
      if (ua.contains('Pro')) return 'Pro';
      if (ua.contains('Enterprise')) return 'Enterprise';
      if (ua.contains('Education')) return 'Education';
      if (ua.contains('Home')) return 'Home';
      if (ua.contains('SE')) return 'SE';
      if (ua.contains('N')) return 'N Edition';
      if (ua.contains('IoT')) return 'IoT';
      if (ua.contains('Datacenter')) return 'Datacenter';
    }
    return 'Standard';
  }

  static String _getWindowsPhoneVersion(String ua) {
    final versionMatch = RegExp(r'Windows Phone (\d+\.\d+)').firstMatch(ua);
    return versionMatch?.group(1) ?? 'Unknown';
  }

  static String _getXboxVersion(String ua) {
    if (ua.contains('Xbox One')) return 'One';
    if (ua.contains('Xbox Series X')) return 'Series X';
    if (ua.contains('Xbox Series S')) return 'Series S';
    return 'Unknown';
  }

  static String _getAndroidVersion(String ua) {
    final match = RegExp(r'Android (\d+)').firstMatch(ua);
    return match?.group(1) ?? 'Unknown';
  }

  static String _getLinuxDistro(String ua) {
    if (ua.contains('Ubuntu')) return 'Ubuntu';
    if (ua.contains('Fedora')) return 'Fedora';
    if (ua.contains('Debian')) return 'Debian';
    if (ua.contains('CentOS')) return 'CentOS';
    if (ua.contains('Red Hat')) return 'Red Hat';
    if (ua.contains('Arch')) return 'Arch';
    return 'Linux';
  }

  static String _getChromeOSVersion(String ua) {
    final match = RegExp(r'CrOS (\S+)').firstMatch(ua);
    return match?.group(1) ?? 'Unknown';
  }

  static Map<String, String> _getBrowserDetails(String ua) {
    if (ua.contains('Edg/')) return {'name': 'Edge', 'version': _getVersion(ua, 'Edg/')};
    if (ua.contains('Chrome/')) return {'name': 'Chrome', 'version': _getVersion(ua, 'Chrome/')};
    if (ua.contains('Firefox/')) return {'name': 'Firefox', 'version': _getVersion(ua, 'Firefox/')};
    if (ua.contains('Safari/') && !ua.contains('Chrome/')) {
      return {'name': 'Safari', 'version': _getVersion(ua, 'Version/')};
    }
    if (ua.contains('OPR/')) return {'name': 'Opera', 'version': _getVersion(ua, 'OPR/')};
    if (ua.contains('Brave/')) return {'name': 'Brave', 'version': _getVersion(ua, 'Brave/')};
    return {'name': 'Unknown', 'version': 'Unknown'};
  }

  static String _getVersion(String ua, String prefix) {
    final versionPart = ua.split(prefix)[1];
    return versionPart.split(' ')[0].split(';')[0];
  }
}