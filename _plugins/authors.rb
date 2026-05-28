module Jekyll
  class AuthorPageGenerator < Generator
    safe true

    def generate(site)
      authors = site.posts.docs.map { |post| post.data['author'] }.compact.uniq
      authors.each do |author|
        site.pages << AuthorPage.new(site, site.source, author)
      end
    end
  end

  class AuthorPage < Page
    def initialize(site, base, author)
      @site = site
      @base = base
      display_author = author == 'Juan Manuel Ramallo' ? 'Juanma' : author
      @dir = File.join('author', Utils.slugify(display_author))
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'author.html')
      self.data['author'] = author
      self.data['display_author'] = display_author
      self.data['title'] = "By #{display_author}"
    end
  end
end
