task :before_assets_precompile do
  system('bin/yarn')
end

Rake::Task['assets:precompile'].enhance ['before_assets_precompile']
