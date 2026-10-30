"""Validate generated platform identity and release filenames without a build."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class BrandingTests(unittest.TestCase):
    def test_generated_platform_names_and_identifiers(self):
        patch = load('platform_patch', 'tool/patch_platforms.py')
        with tempfile.TemporaryDirectory() as tmp:
            patch.ROOT = Path(tmp)
            files = {
                'android/app/src/main/AndroidManifest.xml': '<application android:label="meshex"/>',
                'android/app/build.gradle.kts': 'namespace = "ru.meshex.meshex"\napplicationId = "ru.meshex.meshex"',
                'ios/Runner/Info.plist': '<plist><dict><key>CFBundleName</key><string>meshex</string></dict></plist>',
                'ios/Runner.xcodeproj/project.pbxproj': 'PRODUCT_BUNDLE_IDENTIFIER = ru.meshex.meshex;\nPRODUCT_BUNDLE_IDENTIFIER = ru.meshex.meshex.RunnerTests;',
                'macos/Runner/Configs/AppInfo.xcconfig': 'PRODUCT_NAME = meshex\nPRODUCT_BUNDLE_IDENTIFIER = ru.meshex.meshex\nPRODUCT_COPYRIGHT = old',
                'macos/Runner.xcodeproj/project.pbxproj': 'path = meshex.app;\nTEST_HOST = "$(BUILT_PRODUCTS_DIR)/meshex.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/meshex";',
                'linux/CMakeLists.txt': 'set(BINARY_NAME "meshex")\nset(APPLICATION_ID "ru.meshex.meshex")',
            }
            for name, content in files.items():
                file = patch.ROOT / name
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text(content)
            patch.patch_name()
            patch.patch_app_id()
            first = {name: (patch.ROOT / name).read_text() for name in files}
            patch.patch_name()
            patch.patch_app_id()
            self.assertEqual(first, {name: (patch.ROOT / name).read_text() for name in files})
            self.assertIn('android:label="Meshex"', first['android/app/src/main/AndroidManifest.xml'])
            self.assertIn('applicationId = "ru.meshex.app"', first['android/app/build.gradle.kts'])
            self.assertIn('ru.meshex.app.RunnerTests', first['ios/Runner.xcodeproj/project.pbxproj'])
            self.assertIn('PRODUCT_NAME = Meshex', first['macos/Runner/Configs/AppInfo.xcconfig'])
            self.assertIn('/Meshex.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Meshex', first['macos/Runner.xcodeproj/project.pbxproj'])
            self.assertIn('APPLICATION_ID "ru.meshex.app"', first['linux/CMakeLists.txt'])

    def test_release_manifest_uses_new_build_filenames(self):
        release = load('fetch_release', 'tools/fetch_release.py')
        expected = {
            'meshex-android.apk', 'meshex-android-universal.apk', 'meshex-ios.ipa',
            'meshex-windows.zip', 'meshex-macos.zip', 'meshex-linux.tar.gz',
        }
        self.assertEqual(set(release.KEYS), expected)
        files = {name: {'name': name, 'size': 1} for name in expected}
        manifest = release.build_release('0.1.14', {'published_at': '2026-10-30T00:00:00Z'}, files)
        self.assertEqual(set(manifest['files']), {'android', 'android-universal', 'ios', 'windows', 'macos', 'linux'})
        self.assertTrue(all(f['name'].startswith('meshex-') for f in manifest['files'].values()))


if __name__ == '__main__':
    unittest.main()
