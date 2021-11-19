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

end
