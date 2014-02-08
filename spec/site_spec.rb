require File.expand_path("../../app", __FILE__)
require "sitespec"

Sitespec.configuration.application = App

describe "This site" do
  include Sitespec

  it "provides the following files" do
    get "/2013/10/31/1.html"
    get "/2013/10/31/2.html"
    get "/2013/10/31/3.html"
    get "/2013/10/31/4.html"
    get "/2013/10/31/5.html"
    get "/2013/10/31/6.html"
    get "/2013/10/31/7.html"
    get "/2013/10/31/8.html"
    get "/2013/10/31/9.html"
    get "/2013/10/31/10.html"
    get "/2013/10/31/11.html"
    get "/2013/10/31/12.html"
    get "/2013/10/31/13.html"
    get "/2013/10/31/14.html"
    get "/2013/10/31/15.html"
    get "/2013/11/03/16.html"
    get "/2013/11/06/17.html"
    get "/2013/11/10/18.html"
    get "/2013/11/10/19.html"
    get "/2013/11/12/20.html"
    get "/2013/11/25/21.html"
    get "/2013/12/04/22.html"
    get "/2013/12/05/23.html"
    get "/2013/12/11/24.html"
    get "/2013/12/14/25.html"
    get "/2013/12/14/26.html"
    get "/2013/12/24/27.html"
    get "/2013/12/26/28.html"
    get "/2014/01/16/29.html"
    get "/2014/01/19/30.html"
    get "/2014/01/30/31.html"
    get "/2014/01/30/32.html"
    get "/2014/02/02/33.html"
    get "/2014/02/06/34.html"
    get "/2014/02/09/35.html"
    get "/images/favicon.ico"
    get "/images/rejasupotaro.jpg"
    get "/images/arrow.png"
    get "/index.html"
    get "/stylesheets/all.css"
    get "/feed.xml"
  end
end
