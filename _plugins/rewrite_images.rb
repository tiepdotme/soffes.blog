require 'mini_magick'

class Jekyll::Document
  def assets_url
    "/#{assets_path}"
  end

  def assets_path
    "assets/#{data['date'].strftime('%Y-%m-%d')}-#{data['slug']}/"
  end
end

class RewriteImages < Jekyll::Generator
  def generate(site)
    @site = site
    markdown_converter = @site.find_converter_instance(Jekyll::Converters::Markdown)

    site.posts.docs.each do |document|
      assets_url = document.assets_url
      document.content.gsub!(/(<img.*src=")(?!http)([^"]+\.(?:jpg|png|svg))(".*>)/, "\\1#{assets_url}\\2\\3")
      document.content.gsub!(/(<a.*href=")(?!http)([^"]+\.(?:jpg|png|svg))(".*>)/, "\\1#{assets_url}\\2\\3")
      document.content.gsub!(/!\[(.*)\]\((?!http)(.*)\)/, %(<img src="#{assets_url}\\2" alt="\\1">))

      if document.data['cover_image']
        path = document.assets_path + document.data['cover_image']
        document.data['cover_image'] = assets_url + document.data['cover_image']

        size = MiniMagick::Image.open(path).dimensions
        document.data['cover_image_width'] = size[0]
        document.data['cover_image_height'] = size[1]
      end
    end

    puts '        - Rewrite Images'
  end
end
