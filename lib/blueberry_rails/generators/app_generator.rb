require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module BlueberryRails
  class AppGenerator < Rails::Generators::AppGenerator

    class_option :database, type: :string, aliases: '-d', default: 'postgresql',
      desc: "Preconfigure for selected database " \
            "(options: #{DATABASES.join('/')})"

    # class_option :github, :type => :string, :aliases => '-G', :default => nil,
    #  :desc => 'Create Github repository and add remote origin pointed to repo'

    class_option :bootstrap, type: :boolean, aliases: '-b', default: false,
      desc: 'Include bootstrap 3'

    class_option :devise, type: :boolean, aliases: '-D', default: true,
      desc: 'Include and generate devise'

    class_option :devise_model, type: :string, aliases: '-M', default: 'User',
      desc: 'Name of devise model to generate'

    class_option :skip_test_unit, type: :boolean, aliases: '-T', default: true,
      desc: 'Skip Test::Unit files'

    class_option :skip_turbolinks, type: :boolean, default: true,
      desc: "Skip turbolinks gem"

    class_option :skip_bundle, type: :boolean, aliases: "-B", default: true,
      desc: "Don't run bundle install"

    class_option :gulp, type: :boolean, aliases: '-g', default: false,
      desc: 'Include Gulp asset pipeline'

    class_option :capistrano, type: :boolean, aliases: '-c', default: false,
      desc: 'Include Capistrano'

    class_option :administration, type: :boolean, aliases: '-a', default: false,
      desc: 'Include Admin part of application'

    class_option :fontcustom, type: :boolean, aliases: '-fc', default: false,
      desc: 'Include Fontcustom'

    class_option :translation_engine, type: :boolean, aliases: '-te', default: false,
      desc: 'Include Tranlsation Engine'

    class_option :custom_errors, type: :boolean, aliases: '-ce', default: false,
      desc: 'Include Errors Controller'

    def finish_template
      if options[:administration] && (!options[:devise] || !options[:bootstrap])
        raise 'Administration depends on bootstrap and devise!'
      end
      invoke :blueberry_customization
      super
    end

    def blueberry_customization
      invoke :customize_gemfile
      invoke :setup_database
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_staging_environment
      invoke :create_views
      invoke :create_assets
      invoke :configure_app
      invoke :remove_routes_comment_lines
      invoke :setup_gems
      invoke :setup_git
      invoke :setup_gulp
      invoke :setup_admin
      invoke :rake_tasks
      invoke :setup_custom_errors
      invoke :setup_initializers
      invoke :setup_fontcustom
    end

    def customize_gemfile
      bundle_command 'install'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end

      build :create_database
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :configure_generators
      build :raise_on_unpermitted_parameters
      build :configure_i18n_logger
      build :configure_mailcatcher
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :generate_rspec
      build :configure_rspec
      build :setup_rspec_support_files
      build :test_factories_first
      build :configure_travis
      build :init_guard
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
    end

    def setup_initializers
      say 'Setting up initializers'
      build :copy_initializers
    end

    def setup_fontcustom
      if options[:fontcustom]
        say 'Setting up fontcustom'
        build :copy_fontcustom_config
      end
    end

    def setup_admin
      if options[:administration]
        build :setup_admin
      end
    end

    def setup_custom_errors
      if options[:custom_errors]
        say 'Setting up custom errors'
        build :copy_custom_errors
      end
    end

    def create_views
      build :create_partials_directory
      build :create_application_layout
    end

    def create_assets
      if options[:bootstrap]
        build :copy_assets_directory
      else
        build :copy_print_style
      end
    end

    def configure_app
      build :secret_token
      build :disable_xml_params
      build :setup_mailer_hosts
      build :create_pryrc
      build :add_ruby_version_file
      build :hound_config
      build :configure_i18n
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def setup_gems
      say 'Setting up SimpleForm'
      build :configure_simple_form
      if options[:devise]
        say 'Setting up devise'
        build :install_devise
        build :replace_users_factory
        build :replace_root_controller_spec
      end
      if options[:capistrano]
        say 'Setting up Capistrano'
        build :setup_capistrano
      end
    end

    def setup_git
      say 'Initializing git'
      build :setup_gitignore
      build :init_git
    end

    def setup_gulp
      if options[:gulp]
        say 'Adding Gulp asset pipeline'
        build :gulp_files
      end
    end

    def rake_tasks
      build :copy_rake_tasks
    end

    def run_bundle
    end

    protected

    def get_builder_class
      BlueberryRails::AppBuilder
    end
  end
end
