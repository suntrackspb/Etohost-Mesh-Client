# Called by patch_platforms.py after Flutter generates the iOS host project.
begin
  require 'xcodeproj'
rescue LoadError
  # Homebrew CocoaPods keeps its gems outside the default Ruby gem path.
  homes = Dir.glob('/opt/homebrew/Cellar/cocoapods/*/libexec') + Dir.glob('/usr/local/Cellar/cocoapods/*/libexec')
  raise if homes.empty?
  Gem.use_paths(Gem.dir, Gem.path + [homes.sort.last])
  require 'xcodeproj'
end
require 'fileutils'
root = File.expand_path('..', __dir__)
project = Xcodeproj::Project.open(File.join(root, 'ios/Runner.xcodeproj'))
runner = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target missing' unless runner
source = File.join(root, 'native/ios_widgets')
dest = File.join(root, 'ios/MeshexWidgets')
FileUtils.mkdir_p(dest)
Dir.glob(File.join(source, '*')).each { |file| FileUtils.cp(file, dest) }
# Merge with any existing host entitlements.
entitlements = File.join(root, 'ios/Runner/Runner.entitlements')
values = File.exist?(entitlements) ? Xcodeproj::Plist.read_from_path(entitlements) : {}
values['com.apple.security.application-groups'] = ((values['com.apple.security.application-groups'] || []) + ['group.ru.meshex.app']).uniq
Xcodeproj::Plist.write_to_path(values, entitlements)
info = File.join(root, 'ios/Runner/Info.plist')
plist = Xcodeproj::Plist.read_from_path(info)
urls = plist['CFBundleURLTypes'] ||= []
urls << {'CFBundleURLName'=>'ru.meshex.app.widgets', 'CFBundleURLSchemes'=>['meshex']} unless urls.any? { |v| (v['CFBundleURLSchemes'] || []).include?('meshex') }
Xcodeproj::Plist.write_to_path(plist, info)
target = project.targets.find { |t| t.name == 'MeshexWidgets' }
unless target
  target = project.new_target(:app_extension, 'MeshexWidgets', :ios, '17.0')
  group = project.main_group.new_group('MeshexWidgets', 'MeshexWidgets')
  target.source_build_phase.add_file_reference(group.new_file('MeshexWidgets.swift'))
  group.new_file('Info.plist')
  group.new_file('Widgets.entitlements')
  runner.add_dependency(target)
  embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed App Extensions' } || runner.new_copy_files_build_phase('Embed App Extensions')
  embed.dst_subfolder_spec = '13'
  embed.add_file_reference(target.product_reference).settings = {'ATTRIBUTES'=>['RemoveHeadersOnCopy']}
end
# Embed before Flutter's thinning phase: placing it after creates an Info.plist cycle.
embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed App Extensions' }
thin = runner.build_phases.find { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
if embed && thin
  runner.build_phases.delete(embed)
  runner.build_phases.insert(runner.build_phases.index(thin), embed)
end
runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end
target.build_configurations.each do |config|
  host = runner.build_configurations.find { |v| v.name == config.name } || runner.build_configurations.first
  settings = config.build_settings
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'ru.meshex.app.widgets'
  settings['INFOPLIST_FILE'] = 'MeshexWidgets/Info.plist'
  settings['CODE_SIGN_ENTITLEMENTS'] = 'MeshexWidgets/Widgets.entitlements'
  settings['SWIFT_VERSION'] = '5.0'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['SKIP_INSTALL'] = 'YES'
  settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  settings['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  settings['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  settings['CODE_SIGN_STYLE'] = host.build_settings['CODE_SIGN_STYLE'] || 'Automatic'
  settings['DEVELOPMENT_TEAM'] = host.build_settings['DEVELOPMENT_TEAM'] if host.build_settings['DEVELOPMENT_TEAM']
  # Inherit Flutter version variables without linking Flutter into the extension.
  settings.delete('FLUTTER_BUILD_NUMBER')
  settings.delete('FLUTTER_BUILD_NAME')
  generated = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' } || project.main_group.new_file('Flutter/Generated.xcconfig')
  config.base_configuration_reference = generated

end
attributes = project.root_object.attributes['TargetAttributes'] ||= {}
[runner, target].each do |item|
  target_attributes = attributes[item.uuid] ||= {}
  capabilities = target_attributes['SystemCapabilities'] ||= {}
  capabilities['com.apple.ApplicationGroups.iOS'] = {'enabled' => 1}
end
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.save_as(project.path, 'MeshexWidgets', true)
puts 'ios widgets: installed'
