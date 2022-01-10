require 'ejs'
require 'execjs'
require 'fileutils'
require 'json'
require 'redcarpet'

namespace :project do

  # Usage: rake project:load['oral-history']
  #        rake project:load['oral-history','ui']
  #        rake project:load['oral-history','assets']
  desc "Load project by key: Builds main index.html and project.js which contains all project data (metadata, pages, templates)"
  task :load, [:project_key, :scope] => :environment do |task, args|
    args.with_defaults project_key: 'sample'
    args.with_defaults scope: 'all'

    # Validate project
    project_path = Rails.root.join('project', args[:project_key])
    unless File.directory?(project_path)
      puts "No project directory found for: #{args[:project_key]}"
      exit
    end

    # Get project
    project_json = get_project_json(args[:project_key])

    # Ensure public project directory exists
    public_project_path = Rails.root.join('public', args[:project_key])
    unless File.directory?(public_project_path)
      FileUtils.mkdir_p(public_project_path)
    end

    # Ensure assets folder exists
    public_assets_path = Rails.root.join('public', args[:project_key], 'assets')
    unless File.directory?(public_assets_path)
      FileUtils.mkdir_p(public_assets_path)
    end

    # Updates html and config in public folder
    if args[:scope] == "ui" || args[:scope] == "all"

      # Add pages (parse markdown -> html)
      pages = get_pages(args[:project_key])
      project_json['pages'] = pages

      # Write project data to file
      save_project_to_file(args[:project_key], project_json)

      # Write layouts
      load_layouts(project_json, args[:project_key])
    end

    # Copies assets to public folder
    if args[:scope] == "assets" || args[:scope] == "all"

      # Copy assets
      copy_assets(args[:project_key])
    end
  end

  def copy_assets(project_key)
    src_dir = Rails.root.join('project', project_key, 'assets/')
    dest_dir = Rails.root.join('public', project_key, 'assets/')

    # empty the destination dir
    FileUtils.rm_rf("#{dest_dir}.", secure: true)

    # copy file tree over
    FileUtils.copy_entry src_dir, dest_dir
  end

  def get_pages(project_key)
    page_files = Rails.root.join('project', project_key, 'pages', '**/*.md')
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    pages = {}

    Dir.glob(page_files).each do |page_file|
      content = File.read(page_file)
      html = markdown.render(content)
      # preserve .ejs markup
      html.gsub! '&lt;%', '<%'
      html.gsub! '%&gt;', '%>'
      pages[File.basename(page_file)] = html
    end

    return pages
  end

  def get_project_json(project_key)
    # Validate project file
    project_file = Rails.root.join('project', project_key, 'project.json')
    if !File.exist? project_file
      puts "Project json file is required: #{project_file}"
      exit
    end

    # Read project file
    project_file = File.read(project_file)

    # Parse project file
    JSON.parse(project_file)
  end

  def load_layouts(project, project_key)
    layout_files = Rails.root.join('project', project_key, 'layouts', '*.html')

    Dir.glob(layout_files).each do |layout_file|
      content = File.read(layout_file)
      compiled = EJS.evaluate(content, :project => project, :project_key => project_key)
      target_file = Rails.root.join('public', 'assets', File.basename(layout_file))
      File.open(target_file, 'w') { |file| file.write(compiled) }
    end

  end

  def save_project_to_file(project_key, project)
    json_string = project.to_json
    js_string = "window.PROJECT = #{json_string};"
    project_js_file = Rails.root.join('public', project_key, 'project.js')
    File.open(project_js_file, 'w') { |file| file.write(js_string) }
  end

end
