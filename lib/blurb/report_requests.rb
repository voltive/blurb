class Blurb
  class ReportRequests < BaseClass
    def initialize(base_url:, headers:)
      @base_url = "#{base_url}/reporting"
      @headers = headers
    end

    def create(payload)
      execute_request(
        api_path: '/reports',
        request_type: :post,
        payload: payload
      )
    end

    def retrieve(report_id)
      execute_request(
        api_path: "/reports/#{report_id}",
        request_type: :get
      )
    end
  end
end
