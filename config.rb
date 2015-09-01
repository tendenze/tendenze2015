###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'css'

set :js_dir, 'js'

set :images_dir, 'img'

set :markdown_engine, :redcarpet

# set :relative_links, true

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

# Disable layout for band pages (they open in modals)
page "/bands/*", :layout => false

ready do
  # Generate band pages
  get_md_files("data/bands").each_with_index do |name, index|
    data = get_data("bands", name)
    proxy "bands/#{name}.html", "bands.html",
      :locals => { :name => name, :data => data, :even => index.even? },
      :ignore => true
  end
end

require 'yaml'

helpers do
  # Create links on the bootstrap navbar (highlighted for the active page)
  def nav_link_to(link, url, opts={})
    if url_for(current_resource.url) == url_for(url)
      prefix = '<li class="active">'
    else
      prefix = '<li>'
    end
    prefix + link_to(link, url, opts) + '</li>'
  end

  # Render a markdown file and return the generated HTML
  def include_markdown(filename)
    f = File.open(filename)
    contents = f.read
    f.close
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(contents)
  end

  # Get data from mixed yml/markdown files
  def get_data(prefix, name)
    f = File.open("data/#{prefix}/#{name}.md")
    contents = f.read
    f.close
    metadata = YAML.load(contents)
    metadata["text"] = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(contents.gsub(/---(.|\n)*---/, ""))
    return metadata
  end

  def get_md_files(path)
    return Dir.entries(path)
      .select{ |f| File.file?(File.join(path, f)) }
      .map{ |f| File.basename(f, ".md") }
      .sort_by{ |f| File.basename(f) }
  end
end
