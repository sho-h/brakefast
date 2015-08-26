require 'brakefast/brakeman'

module Brakefast
  class Rack
    include Dependency

    def initialize(app)
      @app = app
      @brakeman_run = false
    end

    def call(env)
      return @app.call(env) unless Brakefast.enable?
      if !@brakeman_run
        Brakefast::Brakeman.run(Rails.root.to_s)
        @brakeman_run = true
      end
      Brakefast.start_request
      status, headers, response = @app.call(env)

      response_body = nil
      if Brakefast.notification?
        if !file?(headers) && !sse?(headers) && !empty?(response) &&
            status == 200 && !response_body(response).frozen? && html_request?(headers, response)
          response_body = response_body(response)
          append_to_html_body(response_body, footer_note) if Brakefast.add_footer
          append_to_html_body(response_body, Brakefast.gather_inline_notifications)
          headers['Content-Length'] = response_body.bytesize.to_s
        end
        Brakefast.perform_out_of_channel_notifications(env)
      end
      [status, headers, response_body ? [response_body] : response]
    ensure
      Brakefast.end_request
    end

    # fix issue if response's body is a Proc
    def empty?(response)
      # response may be ["Not Found"], ["Move Permanently"], etc.
      if rails?
        (response.is_a?(Array) && response.size <= 1) ||
          !response.respond_to?(:body) ||
          !response_body(response).respond_to?(:empty?) ||
          response_body(response).empty?
      else
        body = response_body(response)
        body.nil? || body.empty?
      end
    end

    def append_to_html_body(response_body, content)
      if response_body.include?('</body>')
        position = response_body.rindex('</body>')
        response_body.insert(position, content)
      else
        response_body << content
      end
    end

    def footer_note
      "<div #{footer_div_attributes}>" + Brakefast.footer_info.uniq.join("<br>") + "</div>"
    end

    def file?(headers)
      headers["Content-Transfer-Encoding"] == "binary"
    end

    def sse?(headers)
      headers["Content-Type"] == "text/event-stream"
    end

    def html_request?(headers, response)
      headers['Content-Type'] && headers['Content-Type'].include?('text/html') && response_body(response).include?("<html")
    end

    def response_body(response)
      if rails?
        Array === response.body ? response.body.first : response.body
      else
        response.first
      end
    end

    private
    def footer_div_attributes
<<EOF
data-is-brakefast-footer ondblclick="this.parentNode.removeChild(this);" style="position: fixed; bottom: 0pt; left: 0pt; cursor: pointer; border-style: solid; border-color: rgb(153, 153, 153);
 -moz-border-top-colors: none; -moz-border-right-colors: none; -moz-border-bottom-colors: none;
 -moz-border-left-colors: none; -moz-border-image: none; border-width: 2pt 2pt 0px 0px;
 padding: 5px; border-radius: 0pt 10pt 0pt 0px; background: none repeat scroll 0% 0% rgba(200, 200, 200, 0.8);
 color: rgb(119, 119, 119); font-size: 18px; font-family: 'Arial', sans-serif; z-index:9999;"
EOF
    end
  end
end
