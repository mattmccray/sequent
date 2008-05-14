module Sequent

  def self.publisher
    @publishables = Asset.find(:all, :conditions=>['is_published = ? and published_on <= ?', false, Time.now])
    @publishables.each do |asset|
      asset.update_attribute('is_published', true)
      asset.reload
      asset.publish_files()
    end
    msg = "#{@publishables.length} assets published."
    puts msg
    msg
  end

end
