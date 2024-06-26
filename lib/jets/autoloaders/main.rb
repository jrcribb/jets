module Jets
  class Autoloaders
    # For app code files. IE: app/events
    class Main
      class << self
        extend Memoist
        delegate :config, to: "Jets.project"

        def loader
          loader = Zeitwerk::Loader.new
          loader.tag = "jets.main"
          loader
        end
        memoize :loader

        def configure(root = Jets.root)
          full_path = proc { |path| "#{root}/#{path}" }
          autoload_paths = config.autoload_paths.map(&full_path)
          extension_paths = config.extension_paths.map(&full_path)
          load_paths = autoload_paths + extension_paths

          load_paths.each do |path|
            next if already_configured_dir?(path)
            next unless File.directory?(path)
            loader.push_dir(path)
          end

          ignore_paths = config.ignore_paths.map(&full_path)
          ignore_paths.each do |path|
            loader.ignore(path)
          end
        end

        def already_configured_dir?(path)
          all_loaders = Zeitwerk::Registry.loaders
          already_configured_dirs = all_loaders.map(&:dirs).flatten

          # Normalize the path to avoid trailing slashes issues
          normalized_path = File.expand_path(path)

          # Check the path and its parent directories
          while normalized_path != "/"
            return true if already_configured_dirs.include?(normalized_path)
            normalized_path = File.dirname(normalized_path)
          end

          # Check the root directory explicitly
          already_configured_dirs.include?("/")
        end

        # Call at end
        def setup
          loader.on_load do |cpath, value, abspath|
            next unless abspath.include?("/extensions/")
            if abspath.include?("/app")
              Jets::Lambda::Functions.extend(value)
            elsif abspath.include?("/shared")
              Jets::Stack.extend(value)
            end
          end

          loader.setup

          # Eager load extensions first
          full_path = proc { |path| "#{Jets.root}/#{path}" }
          extension_paths = config.extension_paths.map(&full_path)
          extension_paths.each do |path|
            loader.eager_load_dir(path) if File.directory?(path)
          end

          # Eager load rest of jets managed code.
          # Needed for CloudFormation templates.
          loader.eager_load
        end
      end
    end
  end
end
