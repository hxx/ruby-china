# coding: utf-8
class Node
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :name
  field :summary
  field :sort, type: Integer, default: 0
  field :topics_count, type: Integer, default: 0
  
  delegate :name, to: :section, prefix: true, allow_nil: true

  has_many :topics
  belongs_to :section

  index section_id: 1

  validates_presence_of :name, :summary, :section
  validates_uniqueness_of :name

  has_and_belongs_to_many :followers, class_name: 'User', inverse_of: :following_nodes

  scope :hots, -> { desc(:topics_count) }
  scope :sorted, -> { desc(:sort) }

  after_save :update_cache_version
  after_destroy :update_cache_version

  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now
  end

  # 热门节点给 select 用的
  def self.node_collection
    Rails.cache.fetch("node:node_collection:#{CacheVersion.section_node_updated_at}") do
      Node.all.collect { |n| [n.name,n.id] }
    end
  end
  
  def self.jobs_id
    25
  end
  
  # Markdown 转换过后的 HTML
  def summary_html
    Rails.cache.fetch("#{self.cache_key}/summary_html") do
      MarkdownConverter.convert(self.summary)
    end
  end
  
  # 是否为 jobs 节点
  def jobs?
    self.id == self.class.jobs_id
  end
end
