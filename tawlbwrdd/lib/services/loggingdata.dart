import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'dart:io';

class LoggingData {
  static LoggingData instance = new LoggingData();

  Map<String, dynamic> extra = <String, dynamic>{};
  Map<String, String> tags = <String, String>{};
  PackageInfo packageInfo;
  bool realDevice = true;
  bool debugMode = false;

  final SentryClient sentry = new SentryClient(
      dsn:
      'https://20e3e3b4a2154c038851e923b820c0ae:abc413b5bbaa40ab8175ae718f7f8264@sentry.io/1263972');

  LoggingData() {
    assert(debugMode = true);
    DeviceInfoPlugin plugin = new DeviceInfoPlugin();
    if (Platform.isIOS) {
      tags["ios"] = Platform.operatingSystemVersion;
      plugin.iosInfo.then((IosDeviceInfo info) {
        extra["deviceInfo"] = <String, dynamic>{
          "model": info.model,
          "name": info.name,
          "systemName": info.systemName,
          "systemVersion": info.systemVersion,
          "localizedModel": info.localizedModel,
          "identifierForVendor": info.identifierForVendor,
          "utsname": <String, String>{
            "sysname": info.utsname.sysname,
            "nodename": info.utsname.nodename,
            "release": info.utsname.release,
            "version": info.utsname.version,
            "machine": info.utsname.machine,
          }
        };
        tags["model"] = info.model;
        tags["realDevice"] = info.isPhysicalDevice.toString();
        realDevice = info.isPhysicalDevice;
      });
    }
    if (Platform.isAndroid) {
      tags["android"] = Platform.operatingSystemVersion;
      plugin.androidInfo.then((AndroidDeviceInfo info) {
        extra["deviceInfo"] = <String, dynamic>{
          "version": <String, dynamic>{
            "baseOS": info.version.baseOS,
            "codename": info.version.codename,
            "incremental": info.version.incremental,
            "previewSdkInt": info.version.previewSdkInt,
            "release": info.version.release,
            "sdkInt": info.version.sdkInt,
            "securityPatch": info.version.securityPatch,
          },
          "board": info.board,
          "bootloader": info.bootloader,
          "brand": info.brand,
          "device": info.device,
          "display": info.display,
          "fingerprint": info.fingerprint,
          "hardware": info.hardware,
          "host": info.host,
          "id": info.id,
          "manufacturer": info.manufacturer,
          "model": info.model,
          "product": info.product,
          "tags": info.tags,
          "type": info.type,
        };
        tags["model"] = info.model;
        tags["realDevice"] = info.isPhysicalDevice.toString();
        realDevice = info.isPhysicalDevice;
      });
    }
    tags["locale"] = Platform.localeName;
    packageInfo = new PackageInfo(
        version: "unknown", packageName: "unknown", buildNumber: "unknown");
    PackageInfo.fromPlatform().then((PackageInfo info) {
      tags["buildNumber"] = info.buildNumber;
      tags["packageName"] = info.packageName;
      packageInfo = info;
    });
  }


  set lastPath(String path) => extra["lastPath"] = path;
  String get lastPath => extra["lastPath"].toString();

  void logFlutterError(FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // Don't capture on emulators.
    if (realDevice && !debugMode) {
      final Event event = new Event(
          release: LoggingData.instance.packageInfo.version,
          exception: details.exception,
          stackTrace: details.stack,
          extra: LoggingData.instance.extra,
          tags: LoggingData.instance.tags
      );
      sentry.capture(event: event);
    }
  }

  void logError(FlutterErrorDetails details) {
    // Don't capture on emulators.
    if (realDevice && !debugMode) {
      final Event event = new Event(
          release: LoggingData.instance.packageInfo.version,
          exception: details.exception,
          stackTrace: details.stack,
          extra: LoggingData.instance.extra,
          tags: LoggingData.instance.tags
      );
      sentry.capture(event: event);
    }
  }
}
