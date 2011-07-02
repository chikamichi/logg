Feature: Templates support

  Logg + Tilt = templates support for building nice logging messages

  Scenario: Inline template
    Given a file named "04_inline_template.rb" with:
    """
    # encoding: utf-8
    require 'logg'
    require 'ostruct'

    class Foo
      include Logg::Machine

      log.as(:http_response) do |response|
        tpl = <<-TPL
    %h2 Query log report
    %span.status
      Status:
      = status
    %span.body
      Response:
      = body
    %br/
        TPL
        puts render_inline(tpl, :as => :haml, :data => response)
      end
    end

    response = OpenStruct.new(:status => 200, :body => 'bar')
    Foo.log.http_response(response)
    """
    When I run `ruby 04_inline_template.rb`
    Then the output should not contain "error"
    And  the output should contain "<h2>Query log report</h2>\n<span class='status'>\n  Status:\n  200\n</span>\n<span class='body'>\n  Response:\n  bar\n</span>\n<br />\n"

  Scenario: External template with an extension
    Given a file named "05_external_template_with_extension.rb" with:
    """
    # encoding: utf-8
    require 'logg'
    require 'ostruct'
    require 'better/tempfile'

    class Foo
      include Logg::Machine

      # For the sake of this example, the template file is being created
      # within the custom logger, as a tempfile, but one would rather use
      # a legacy file and streamline this method!
      log.as(:http_response) do |response|
        tpl = <<-TPL
    %h2 Query log report
    %span.status
      Status:
      = status
    %span.body
      Response:
      = body
    %br/
        TPL
        Better::Tempfile.open(['LoggExample', ".haml"]) do |f|
          f.write(tpl)
          f.rewind
          puts render(f.path, :data => response)
        end
      end
    end

    response = OpenStruct.new(:status => 200, :body => 'bar')
    Foo.log.http_response(response)
    """
    When I run `ruby 05_external_template_with_extension.rb`
    Then the output should not contain "error"
    And  the output should contain "<h2>Query log report</h2>\n<span class='status'>\n  Status:\n  200\n</span>\n<span class='body'>\n  Response:\n  bar\n</span>\n<br />\n"

  Scenario: External template without an extension (or custom ext)
    Given a file named "06_external_template_without_extension.rb" with:
    """
    # encoding: utf-8
    require 'logg'
    require 'ostruct'
    require 'better/tempfile'

    class Foo
      include Logg::Machine

      # For the sake of this example, the template file is being created
      # within the custom logger, as a tempfile, but one would rather use
      # a legacy file and streamline this method!
      log.as(:http_response) do |response|
        tpl = <<-TPL
    %h2 Query log report
    %span.status
      Status:
      = status
    %span.body
      Response:
      = body
    %br/
        TPL
        Better::Tempfile.open('LoggExample') do |f|
          f.write(tpl)
          f.rewind
          puts render(f.path, :as => :haml, :data => response)
        end
      end
    end

    response = OpenStruct.new(:status => 200, :body => 'bar')
    Foo.log.http_response(response)
    """
    When I run `ruby 06_external_template_without_extension.rb`
    Then the output should not contain "error"
    And  the output should contain "<h2>Query log report</h2>\n<span class='status'>\n  Status:\n  200\n</span>\n<span class='body'>\n  Response:\n  bar\n</span>\n<br />\n"

  Scenario: Template with locals
    Given a file named "07_template_with_locals.rb" with:
    """
    # encoding: utf-8
    require 'logg'
    require 'ostruct'

    class Foo
      include Logg::Machine

      log.as(:hello) do |who|
        tpl = <<-TPL
    = [x.to_s.capitalize, y.to_s].join(' ')
        TPL
        puts render_inline(tpl, :as => :haml, :locals => { :x => :hello, :y => who })
      end
    end

    Foo.log.hello('World')
    """
    When I run `ruby 07_template_with_locals.rb`
    Then the output should not contain "error"
    And  the output should contain "Hello World"
