target 'TrainersConnect' do
  use_frameworks!
  pod 'Alamofire', '~> 5.10.1'
  # pod 'SwiftySensors'
  pod 'SwiftySensorsTrainers'
  pod 'Signals'
  pod 'SwiftySensors', :git => 'https://github.com/kinetic-fit/sensors-swift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
    end
  end
  projects = installer.aggregate_targets
   .map{ |t| t.user_project }
   .uniq{ |p| p.path }
   .push(installer.pods_project)
#   installer.pods_project.targets.each do |target|
#    flutter_additional_ios_build_settings(target)
#   end

  projects.each do |project|
   project.build_configurations.each do |config|
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] =
   'arm64'
    config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
   end

   project.save()
 end
end

