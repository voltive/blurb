class Blurb
  class ExportRequests < BaseClass
    def initialize(base_url:, headers:)
      @base_url = base_url
      @headers = headers
    end

    def create(campaign_type, record_type, state_filter=['ENABLED', 'PAUSED'])
      execute_export_request(
        api_path: "/#{record_type}/export",
        request_type: :post,
        payload: { ad_product_filter: [campaign_type], state_filter: Array.wrap(state_filter).map(&:upcase) },
        record_type: record_type
      )
    end

    def retrieve(record_type, export_id)
      execute_export_request(
        api_path: "/exports/#{export_id}",
        request_type: :get,
        record_type: record_type
      )
    end

    private

    def execute_export_request(api_path: '', request_type:, payload: {}, record_type:)
      record_type_header = "application/vnd.#{record_type.downcase}export.v1+json"

      new_headers = @headers.dup
      new_headers.merge!(
        'Accept' => record_type_header,
        'Content-Type' => record_type_header
      )

      Request.new(
        url: "#{@base_url}#{api_path}",
        request_type: request_type,
        payload: payload,
        headers: new_headers
      ).make_request
    end
  end
end
