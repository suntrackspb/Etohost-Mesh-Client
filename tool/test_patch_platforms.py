import pathlib
import tempfile
import unittest
from unittest.mock import patch

import patch_platforms


class PatchNameTest(unittest.TestCase):
    def test_xcode_product_names_preserve_variables_and_repair_old_patch(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            project = root / "macos/Runner.xcodeproj/project.pbxproj"
            scheme = project.parent / "xcshareddata/xcschemes/Runner.xcscheme"
            scheme.parent.mkdir(parents=True)
            project.write_text(
                'echo "$PRODUCT_NAME.app"\n'
                'echo "$Meshex.app"\n'
                'echo "$OTHER_PRODUCT.app"\n'
                'path = old_name.app;\n'
                'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/old_name.app/'
                '$(BUNDLE_EXECUTABLE_FOLDER_PATH)/old_name";\n'
            )
            scheme.write_text('BuildableName="old_name.app"')
            with patch.object(patch_platforms, "ROOT", root):
                patch_platforms.patch_name()
                result = project.read_text()
                self.assertEqual(result.count('$PRODUCT_NAME.app'), 2)
                self.assertIn('$OTHER_PRODUCT.app', result)
                self.assertIn('path = Meshex.app;', result)
                self.assertIn('/Meshex.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Meshex', result)
                self.assertEqual(scheme.read_text(), 'BuildableName="Meshex.app"')
                patch_platforms.patch_name()
                self.assertEqual(project.read_text(), result)


if __name__ == "__main__":
    unittest.main()
