require 'blurb/request_collection'

class Blurb
  class HistoryRequest < RequestCollection
    FROM_DATE = DateTime.now - 30
    TO_DATE = DateTime.now
    MAX_COUNT = 200.freeze
    MIN_COUNT = 50.freeze

    def initialize(base_url:, headers:)
      @base_url = base_url
      @headers = headers
    end

    def retrieve(
      from_date: FROM_DATE,
      to_date: TO_DATE,
      event_types:,
      count: MAX_COUNT,
      sort_direction: 'DESC',
      page_offset: 0
    )

      count = MIN_COUNT if count < MIN_COUNT
      count = MAX_COUNT if count > MAX_COUNT

      payload = {
        sort: {
          key: 'DATE',
          direction: sort_direction
        },
        fromDate: from_date.strftime('%Q').to_i,
        toDate: to_date.strftime('%Q').to_i,
        eventTypes: event_types,
        count: count,
        pageOffset: page_offset
      }

      execute_request(
        api_path: "/history",
        request_type: :post,
        payload: payload
      )
    end
  end
end
