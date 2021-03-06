# frozen_string_literal: true

class Feed < ApplicationRecord
  enum action: { log_create: 0, value_create: 1, user_followed: 2, following_follow: 3 }

  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :followed, class_name: "User", foreign_key: "followed_id", optional: true
  belongs_to :log, optional: true

  validates :user_id, presence: true
  validates :sender_id, presence: true

  scope :default_order, -> { order(updated_at: :desc) }

  def self.create_log(target, log)
    feed = Feed.find_by(
      user_id: target.id,
      sender_id: log.user_id,
      log_id: log.id,
      action: :log_create
    )
    if feed
      feed.touch
    else
      Feed.create!(
        user_id: target.id,
        sender_id: log.user_id,
        log_id: log.id,
        action: :log_create
      )
    end
  end

  def self.create_value(target, log)
    feed = Feed.find_by(
      user_id: target.id,
      sender_id: log.user_id,
      log_id: log.id,
      action: :value_create
    )
    if feed
      feed.touch
    else
      Feed.create!(
        user_id: target.id,
        sender_id: log.user_id,
        log_id: log.id,
        action: :value_create
      )
    end
  end

  def self.user_followed(target, sender)
    feed = Feed.find_by(
      user_id: target.id,
      sender_id: sender.id,
      action: :user_followed
    )
    if feed
      feed.touch
    else
      Feed.create!(
        user_id: target.id,
        sender_id: sender.id,
        action: :user_followed
      )
    end
  end

  def self.following_user_follow(target, sender, follower)
    feed = Feed.find_by(
      user_id: target.id,
      sender_id: sender.id,
      followed_id: follower.id,
      action: :following_follow
    )
    if feed
      feed.touch
    else
      Feed.create!(
        user_id: target.id,
        sender_id: sender.id,
        followed_id: follower.id,
        action: :following_follow
      )
    end
  end

  def self.destroy_user_followed(target, sender)
    Feed.where(
      user_id: target.id,
      sender_id: sender.id,
      action: :user_followed
    ).destroy_all
  end

  def self.destroy_following_user_follow(sender, follower)
    Feed.where(
      sender_id: sender.id,
      followed_id: follower.id,
      action: :following_follow
    ).destroy_all
  end
end
