class Blurb
  class BaseClass
    CAMPAIGN_TYPE_CODES = {
      sp: 'sp',
      sb: 'hsa',
      sd: 'sd'
    }.freeze

    private

    def execute_request(api_path: '', request_type:, payload: {})
      request = Request.new(
        url: "#{@base_url}#{api_path}",
        request_type: request_type,
        payload: payload,
        headers: @headers
      )

      request.make_request
    end
  end
end 
