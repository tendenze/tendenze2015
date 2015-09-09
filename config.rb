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

page "/bands/*", :layout => "fluid"
# Disable layout for modal band pages
page "/bandmodals/*", :layout => false

# ignore "bands.html.erb"

ready do
  # Generate full-screen band pages and modal pages
  data.bands.main.sort_by{ |d| d["name"].downcase }.each_with_index do |data, index|
    name_id = data["name"].gsub(/[^a-zA-Z1-9]/,"").downcase
    color_index = index % 3
    proxy "bands/#{name_id}.html", "bands.html",
      :locals => { :name_id => name_id, :data => data, :color_index => color_index },
      :ignore => true
    proxy "bandmodals/#{name_id}.html", "bands.html",
      :locals => { :name_id => name_id, :data => data, :color_index => color_index },
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

  def get_data_array(path)
    complete_path = "data/#{path}"
    return Dir.entries(complete_path)
      .select{ |f| File.file?(File.join(complete_path, f)) }
      .map{ |f| get_data(path, File.basename(f, ".md")) }
  end

  def partial_embed(embed_code)
    if embed_code
      case embed_code
      when /^*.youtu.*be\/(.*)$/
        return partial "partials/youtube_embed", :locals => { :source => $1 }
      when /^.*bandcamp.com/
        fields = embed_code.split("|")
        return partial "partials/bandcamp_embed", :locals => {
          :source     => fields[0],
          :album_link => fields[1],
          :album_name => fields[2]
        }
      when /^.*soundcloud.com\/(tracks\/.*)$/
        return partial "partials/soundcloud_embed", :locals => { :track_code => $1 }
      when /^https:\/\/vimeo.com\/(.*)$/
        return partial "partials/vimeo_embed", :locals => { :video_code => $1 }
      end
    end
    return nil
  end
end
