class Collection < ActiveRecord::Base

  has_many :transcripts
  belongs_to :vendor

  def to_param
    uid
  end

  def self.getForHomepage
    Rails.cache.fetch("#{ENV['PROJECT_ID']}/collections", expires_in: 10.minutes) do
      Collection.where(project_uid: ENV['PROJECT_ID']).order("title").all
    end
  end

  def self.getForDownloadByVendor(vendor_uid, project_uid)
    vendor = Vendor.find_by_uid(vendor_uid)
    Collection.where("vendor_id = :vendor_id AND vendor_identifier != :empty AND project_uid = :project_uid",
      {vendor_id: vendor[:id], empty: "", project_uid: project_uid}).all
  end

  def self.getForUploadByVendor(vendor_uid, project_uid)
    vendor = Vendor.find_by_uid(vendor_uid)
    Collection.where("vendor_id = :vendor_id AND vendor_identifier = :empty AND project_uid = :project_uid",
      {vendor_id: vendor[:id], empty: "", project_uid: project_uid}).all
  end

  def self.percentCompleted(page)

    collections = Collection.order(title: :desc).offset(page * 8).limit(8)
    data = {
      total: Collection.count,
      collections: {}
    }
    collections.each do |collection|
      incomplete_transcripts = collection.transcripts.where("percent_completed >= 99")

      incomplete_count = incomplete_transcripts.count
      total_count = collection.transcripts.count

      data[:collections][collection.id] = {
        title: collection.title,
        percent_completed: %(#{ (incomplete_count / total_count * 100).round }% (#{incomplete_count}/#{total_count})),
        # only show the download link if there are incomplete ts
        show_guids_link: incomplete_count > 0
      }
    end

    data
  end

  def incompleteGuids
    ts = transcripts.where("percent_completed <= 99")

    if ts.count > 0
      ts.all.map(&:uid).join("\n") + "\n"
    else
      # none found!
      false
    end
  end
end
