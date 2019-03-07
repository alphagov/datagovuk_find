task :before_assets_precompile do
  system('bin/yarn')
end

Rake::Task['assets:precompile'].enhance %w[before_assets_precompile]
