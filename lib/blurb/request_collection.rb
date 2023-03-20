require 'blurb/request'
require 'blurb/base_class'
require 'blurb/errors/item_limit_exceded'

class Blurb
  class RequestCollection < BaseClass

    def initialize(resource:, headers:, base_url:, bulk_api_limit: 1000)
      @resource = resource
      @base_url = "#{base_url}/sp/#{resource.pluralize}"
      @api_limit = bulk_api_limit
      @headers = headers.merge(resource_headers)
    end

    def list(payload: {})
      execute_request(
        api_path: '/list',
        request_type: :post,
        payload: payload
      )
    end

    def retrieve(resource_id)
      payload = {}
      payload[resource_filter_key] = { include: [resource_id.to_s] }

      Array.wrap(list(payload: payload)[resource_response_key.underscore.to_sym]).first
    end

    def create_bulk(create_array)
      execute_bulk_request(
        request_type: :post,
        payload: create_array,
      )
    end

    def create(**create_params)
      response = create_bulk([create_params])

      handle_single_resource_response(response)
    end

    def update_bulk(update_array)
      execute_bulk_request(
        request_type: :put,
        payload: update_array,
      )
    end

    def update(**update_params)
      response = update_bulk([update_params])

      handle_single_resource_response(response)
    end

    def delete_bulk(resource_ids)
      verify_payload_size(resource_ids) 

      payload = {}
      payload[resource_filter_key] = { include: resource_ids.map(&:to_s) }

      execute_request(
        api_path: '/delete',
        request_type: :post,
        payload: payload
      )[resource_response_key.underscore.to_sym]
    end

    def delete(resource_id)
      response = delete_bulk([resource_id])

      handle_single_resource_response(response)
    end

    private

    def resource_headers
      case @resource
      when 'target'
        {
          'Content-Type' => "application/vnd.spTargetingClause.v3+json",
          'Accept' => "application/vnd.spTargetingClause.v3+json"
        }
      else
        {
          'Content-Type' => "application/vnd.sp#{@resource.upcase_first}.v3+json",
          'Accept' => "application/vnd.sp#{@resource.upcase_first}.v3+json"
        }
      end
    end

    def resource_response_key
      case @resource
      when 'target'
        'targetingClauses'
      else
        @resource.pluralize
      end
    end

    def resource_filter_key
      case @resource
      when 'productAd'
        'adIdFilter'
      else
        "#{@resource}IdFilter"
      end
    end

    def handle_single_resource_response(response)
      if response[:error].present?
        { status: :error, errors: response[:error].first[:errors] }
      else
        { status: :success, success: response[:success].first }
      end
    end

    def execute_request(api_path: "", request_type:, payload:)
      request = Request.new(
        url: "#{@base_url}#{api_path}",
        request_type: request_type,
        payload: payload,
        headers: @headers
      )

      request.make_request
    end

    def verify_payload_size(items)
      return if items.size <= @api_limit

      raise ItemLimitExceded, "max item limit for operation is #{@api_limit}"
    end

    def execute_bulk_request(**bulk_request_params)
      verify_payload_size(bulk_request_params[:payload])

      payload = {}
      payload[resource_response_key] = bulk_request_params[:payload]
      bulk_request_params[:payload] = payload

      execute_request(**bulk_request_params)[resource_response_key.underscore.to_sym]
    end
  end
end
