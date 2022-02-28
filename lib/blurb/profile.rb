require "blurb/account"
require "blurb/campaign_requests"
require "blurb/snapshot_requests"
require "blurb/report_requests"
require "blurb/request_collection"
require "blurb/request_collection_with_campaign_type"
require "blurb/suggested_keyword_requests"
require "blurb/history_request"

class Blurb
  class Profile < BaseClass

    attr_accessor(
      :profile_id,
      :account,
      :portfolios,
      :history,
      :sp_snapshots,
      :sb_snapshots,
      :sp_reports,
      :sb_reports,
      :sd_reports,
      :sp_campaigns,
      :sb_campaigns,
      :sd_campaigns,
      :sp_campaign_negative_keywords,
      :sp_ad_groups,
      :sd_ad_groups,
      :sp_keywords,
      :sd_keywords,  
      :sp_product_ads,
      :sd_product_ads,
      :sp_negative_keywords,
      :sb_negative_keywords,
      :sp_targets,
      :sp_suggested_keywords
    )

    def initialize(profile_id:, account:)
      @profile_id = profile_id
      @account = account

      @portfolios = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/portfolios"
      )
      @history = HistoryRequest.new(
        headers: headers_hash,
        base_url: account.api_url
      )
      @sp_snapshots = SnapshotRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_snapshots = SnapshotRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sb]
      )
      @sp_reports = ReportRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_reports = ReportRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sb]
      )
      @sd_reports = ReportRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sd]
      )
      @sp_campaigns = CampaignRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: "campaigns",
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_campaigns = CampaignRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: "campaigns",
        campaign_type: CAMPAIGN_TYPE_CODES[:sb],
        bulk_api_limit: 10
      )
      @sd_campaigns = CampaignRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: "campaigns",
        campaign_type: CAMPAIGN_TYPE_CODES[:sd],
        bulk_api_limit: 10
      )
      @sp_campaign_negative_keywords = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/campaignNegativeKeywords"
      )
      @sp_ad_groups = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/adGroups"
      )
      @sd_ad_groups = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/sd/adGroups"
      )
      @sp_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: "keywords",
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: "keywords",
        campaign_type: CAMPAIGN_TYPE_CODES[:sb]
      )
      @sp_product_ads = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/productAds"
      )
      @sd_product_ads = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/sd/productAds"
      )
      @sp_negative_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'negativeKeywords',
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_negative_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'negativeKeywords',
        campaign_type: CAMPAIGN_TYPE_CODES[:sb]
      )
      @sp_targets = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/targets"
      )
      @sp_suggested_keywords = SuggestedKeywordRequests.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp"
      )
    end

    def snapshots(campaign_type)
      return sp_snapshots if campaign_type == :sp
      return sb_snapshots if campaign_type == :sb || campaign_type == :hsa
    end

    def reports(campaign_type)
      return sp_reports if campaign_type == :sp
      return sb_reports if campaign_type == :sb || campaign_type == :hsa
      return sd_reports if campaign_type == :sd
    end

    def campaigns(campaign_type)
      return sp_campaigns if campaign_type == :sp
      return sb_campaigns if campaign_type == :sb || campaign_type == :hsa
      return sd_campaigns if campaign_type == :sd
    end

    def campaign_negative_keywords(campaign_type)
      return sp_campaign_negative_keywords if campaign_type == :sp
    end

    def ad_groups(campaign_type)
      return sp_ad_groups if campaign_type == :sp
      return sb_ad_groups if campaign_type == :sb || campaign_type == :hsa
    end

    def keywords(campaign_type)
      return sp_keywords if campaign_type == :sp
      return sb_keywords if campaign_type == :sb || campaign_type == :hsa
    end

    def product_ads(campaign_type)
      return sp_product_ads if campaign_type == :sp
      return sd_product_ads if campaign_type == :sd
    end

    def negative_keywords(campaign_type)
      return sp_negative_keywords if campaign_type == :sp
      return sb_negative_keywords if campaign_type == :sb || campaign_type == :hsa
    end

    def suggested_keywords(campaign_type)
      return sp_suggested_keywords if campaign_type == :sp
    end

    def request(api_path: "",request_type: :get, payload: nil, url_params: nil, headers: headers_hash)
      base_url = account.api_url

      url = "#{base_url}#{api_path}"

      request = Request.new(
        url: url,
        url_params: url_params,
        request_type: request_type,
        payload: payload,
        headers: headers
      )

      request.make_request
    end

    def profile_details
      account.retrieve_profile(profile_id)
    end

    def headers_hash(opts = {})
      headers_hash = {
        "Authorization" => "Bearer #{account.retrieve_token()}",
        "Content-Type" => "application/json",
        "Amazon-Advertising-API-Scope" => profile_id,
        "Amazon-Advertising-API-ClientId" => account.client.client_id
      }

      headers_hash["Content-Encoding"] = "gzip" if opts[:gzip]

      return headers_hash
    end
  end
end
