require "#{Rails.root}/lib/api_ingester"

class ApiController < ActionController::API

  def ingest
    list = params[:guids]
    options = {
      create_missing_collections: params[:create_missing_collections],
      force_reingest: params[:force_reingest]
    }
    ingester = APIIngester.new(list, options)
    ingester.run!

    output = build_response(ingester.records.map(&:uid), ingester.errors)
    render json: output
  end

  def build_response(success_uids, errors)
    {
      errors: errors,
      records: success_uids
    }
  end
end

# post list of guids to /ingest
# ingest htem a la ingest_guids rake
