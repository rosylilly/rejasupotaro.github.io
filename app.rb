require "builder"
require "padrino"
require "rack-livereload"
require "redcarpet"
require "sass"
require "slim"
require "yaml"

class App < Padrino::Application
  register Padrino::Helpers
  register Padrino::Rendering
  use Rack::LiveReload unless defined?(RSpec)
  use Rack::Static, urls: ["/images"]

  set :author, "rejasupotaro"
  set :blog_description, "deliver value to customers continuously or die;"
  set :blog_title, "Rejasupoem"
  set :scss, views: "#{root}/stylesheets", load_paths: ["#{root}/stylesheets"]
  set :show_exceptions, false
  set :site_url, "http://rejasupotaro.github.io/"
  set :slim, pretty: true
  set :markdown, fenced_code_blocks: true

  disable :logging
  enable :reloader

  get "/stylesheets/all.css" do
    content_type "text/css"
    scss :all
  end

  get "/index.html" do
    slim :index, locals: { articles: articles }
  end

  get "/:year/:month/:day/:title.html" do
    path = "#{articles_path}/#{params[:year]}-#{params[:month]}-#{params[:day]}-#{params[:title]}.md"
    slim :show, locals: { article: Article.new(path) }
  end

  get "/feed.xml" do
    builder :feed, locals: { articles: articles }
  end

  error do |exception|
    raise exception
  end

  helpers do
    def articles
      Dir.glob("#{articles_path}/*.md").sort.reverse.map {|path| Article.new(path) }
    end

    def articles_path
      "#{settings.root}/articles"
    end
  end

  class Article
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def title
      File.basename(segments[3], ".md")
    end

    def date
      Date.new(*segments[0, 3].map(&:to_i))
    end

    def url
      date.strftime("/%Y/%m/%d/#{title}.html")
    end

    def front_matter
      front_matter_and_body[0]
    end

    def body
      content = front_matter_and_body[1]
      return unfold_twitter(content)
    end

    private

    def segments
      @segments ||= File.basename(path).split("-", 4)
    end

    def front_matter_and_body
      @front_matter_and_body ||= begin
        matters = {}
        content = File.read(path).sub(/\A(---\s*\n.*?\n?)^---\s*$\n?/m) do
          matters = YAML.load($1)
          ""
        end
        [matters, content]
      end
    end

    def unfold_twitter content
      content.gsub! /(\{% oembed https:\/\/twitter\.com\/\w+\/status\/[[:digit:]]+\ %})/ do
        "<blockquote class=\"twitter-tweet\" lang=\"en\"><a href=\"#{$1}\"></a></blockquote><script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"
      end
      return content
    end
  end
end
